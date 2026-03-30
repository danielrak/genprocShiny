#' From example to function
#'
#' @description From a user exemple code (expr), get the corresponding function
#'
#' @param expr The expression user wants to transform to a function
#' @param env Working environment
#' @return Function 1L. Output function.
#'
#' @export
from_example_to_function <- function(expr, env = parent.frame()) {
  if (! (is.expression(expr) & length(expr) == 1)) stop ("expr must be an expression of length 1")

  key_to_param <- new.env(parent = emptyenv())
  params <- list()

  make_param <- function(key, default) {
    if (exists(key, envir = key_to_param, inherits = FALSE)) {
      get(key, envir = key_to_param, inherits = FALSE)
    } else {
      pname <- paste0("param_", length(params) + 1)
      assign(key, pname, envir = key_to_param)
      params[[pname]] <<- default
      pname
    }
  }

  is_missing_arg <- function(x) {
    identical(x, rlang::missing_arg()) ||
      (is.symbol(x) && length(as.character(x)) == 1 && as.character(x) == "")
  }

  # Detect x <- ..., x = ... (as assignment), x <<- ..., ... -> x, ... ->> x
  is_assignment_call <- function(x) {
    is.call(x) && is.symbol(x[[1]]) && as.character(x[[1]]) %in%
      c("<-", "=", "<<-", "->", "->>")
  }

  # Extract symbol bound by an assignment call (only if LHS is a bare symbol)
  assignment_lhs_symbol <- function(x) {
    if (!is_assignment_call(x)) return(NULL)
    op <- as.character(x[[1]])

    # For -> and ->>, the assigned symbol is the 3rd element
    lhs <- if (op %in% c("->", "->>")) x[[3]] else x[[2]]

    if (is.symbol(lhs)) {
      nm <- as.character(lhs)
      if (length(nm) == 1 && !is.na(nm) && nm != "") return(nm)
    }
    NULL
  }

  rewrite <- function(node, bound = character()) {
    # Strings -> params
    if (is.character(node) && length(node) == 1) {
      key <- paste0("chr:", node)
      pname <- make_param(key, node)
      return(rlang::sym(pname))
    }

    # Symbols: keep local/bound; capture external non-functions
    if (is.symbol(node)) {
      s <- as.character(node)
      if (length(s) != 1 || is.na(s) || s == "") return(node)
      if (s %in% bound) return(node)

      if (exists(s, envir = env, inherits = TRUE)) {
        val <- get(s, envir = env, inherits = TRUE)
        if (!is.function(val)) {
          key <- paste0("sym:", s)
          pname <- make_param(key, val)
          return(rlang::sym(pname))
        }
      }
      return(node)
    }

    # Expression vectors
    if (is.expression(node)) {
      out <- lapply(as.list(node), rewrite, bound = bound)
      return(as.expression(out))
    }

    # Calls
    if (is.call(node)) {
      head <- node[[1]]
      head_name <- if (is.symbol(head)) as.character(head) else NULL

      # Handle { ... } as a sequential block with growing bound vars
      if (!is.null(head_name) && head_name == "{") {
        args <- as.list(node)
        # args[[1]] is "{"
        cur_bound <- bound

        if (length(args) >= 2) {
          for (i in seq.int(2, length(args))) {
            stmt <- args[[i]]

            # Rewrite statement with current bound
            args[[i]] <- rewrite(stmt, bound = cur_bound)

            # If original statement binds a new symbol, extend bound for following statements
            new_nm <- assignment_lhs_symbol(stmt)
            if (!is.null(new_nm)) {
              cur_bound <- unique(c(cur_bound, new_nm))
            }
          }
        }
        return(as.call(args))
      }

      # Nested function definitions: function(...) { ... } and \(...) { ... }
      if (!is.null(head_name) && head_name %in% c("function", "\\")) {
        formals_pl <- node[[2]]
        nms <- names(formals_pl)
        nms <- if (is.null(nms)) character() else nms
        nms <- nms[nms != "" & !is.na(nms) & nms != "..."]
        new_bound <- unique(c(bound, nms))
        new_body <- rewrite(node[[3]], bound = new_bound)
        return(as.call(list(head, formals_pl, new_body)))
      }

      # Assignments: rewrite RHS only, and treat LHS symbol as local thereafter (handled in `{`)
      if (!is.null(head_name) && head_name %in% c("<-", "=", "<<-")) {
        lhs <- node[[2]]
        rhs <- node[[3]]
        rhs2 <- rewrite(rhs, bound = bound)
        return(as.call(list(rlang::sym(head_name), lhs, rhs2)))
      }
      if (!is.null(head_name) && head_name %in% c("->", "->>")) {
        rhs <- node[[2]]
        lhs <- node[[3]]
        rhs2 <- rewrite(rhs, bound = bound)
        return(as.call(list(rlang::sym(head_name), rhs2, lhs)))
      }

      # Generic call: rewrite arguments (not head)
      args <- as.list(node)
      if (length(args) >= 2) {
        for (i in seq.int(2, length(args))) {
          if (!is_missing_arg(args[[i]])) {
            args[[i]] <- rewrite(args[[i]], bound = bound)
          }
        }
      }
      return(as.call(args))
    }

    node
  }

  new_body <- rewrite(expr[[1]], bound = character())
  fmls <- rlang::pairlist2(!!!params)
  rlang::new_function(args = fmls, body = new_body, env = env)
}

