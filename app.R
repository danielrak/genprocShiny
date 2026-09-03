# Launch the Shiny app (do not remove this comment)
#
# Entry point used by shinyapps.io / Posit Connect. Deploy with
# `Rscript dev/deploy_shinyapps.R` or the Publish button in RStudio.

pkgload::load_all(export_all = FALSE, helpers = FALSE, attach_testthat = FALSE)
options("golem.app.prod" = TRUE)
genprocShiny::run_app()
