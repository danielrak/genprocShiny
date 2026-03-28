#' rename_function_params
#'
#' @description Rename arguments of a function
#'
#' @param f The function which arguments need to be renamed
#' @param mapping Named vector. Arguments names mapping.
#'  Names are initial args and values are renamed args.
#' @return function 1L. The argument-renamed function.
#'
#' @noRd
rename_function_params <- function(f, mapping) {
  stopifnot(is.function(f))
  stopifnot(is.character(mapping), !is.null(names(mapping)))
  stopifnot(all(nzchar(names(mapping))))
  stopifnot(all(nzchar(unname(mapping))))

  old_names <- names(mapping)
  new_names <- unname(mapping)

  # checks on formals
  fmls <- formals(f)
  fml_names <- names(fmls)

  missing_old <- setdiff(old_names, fml_names)
  if (length(missing_old) > 0) {
    stop("These names are not function parameters: ",
         paste(missing_old, collapse = ", "))
  }

  if (any(duplicated(new_names))) {
    stop("New parameter names must be unique.")
  }

  untouched <- setdiff(fml_names, old_names)
  collisions <- intersect(new_names, untouched)
  if (length(collisions) > 0) {
    stop("These new names already exist as other parameters: ",
         paste(collisions, collapse = ", "))
  }

  # rename formals
  names(fmls) <- vapply(fml_names, function(x)
    if (x %in% old_names)
      unname(mapping[[x]])
    else
      x, character(1))
  formals(f) <- fmls

  # recursive body rewrite
  rewrite <- function(expr) {
    if (is.symbol(expr)) {
      sym_name <- as.character(expr)
      if (sym_name %in% old_names) {
        return(as.name(unname(mapping[[sym_name]])))
      }
      return(expr)
    }

    if (is.pairlist(expr)) {
      out <- as.pairlist(lapply(as.list(expr), rewrite))
      names(out) <- names(expr)
      return(out)
    }

    if (is.call(expr)) {
      expr_list <- as.list(expr)

      # if this is an inner function(...) ..., do not rewrite its formal args
      if (identical(expr_list[[1]], as.name("function"))) {
        new_call <- expr_list
        if (length(new_call) >= 2) {
          new_call[[2]] <- expr_list[[2]]
        }
        if (length(new_call) >= 3) {
          new_call[[3]] <- rewrite(expr_list[[3]])
        }
        return(as.call(new_call))
      }

      return(as.call(lapply(expr_list, rewrite)))
    }

    expr
  }

  body(f) <- rewrite(body(f))
  f
}
