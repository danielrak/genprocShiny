# Deploy the app to shinyapps.io.
#
# Used by .github/workflows/deploy-shinyapps.yaml, where the account is read
# from the SHINYAPPS_NAME, SHINYAPPS_TOKEN and SHINYAPPS_SECRET secrets.
# Can also be run locally after a one-off rsconnect::setAccountInfo(), in
# which case the registered account is used.
#
# The bundle is the package sources plus app.R; .rscignore lists what is
# excluded. Dependencies come from DESCRIPTION, so genproc is installed from
# CRAN on the server.

account <- Sys.getenv("SHINYAPPS_NAME")
token <- Sys.getenv("SHINYAPPS_TOKEN")
secret <- Sys.getenv("SHINYAPPS_SECRET")

if (nzchar(account) && nzchar(token) && nzchar(secret)) {
  rsconnect::setAccountInfo(name = account, token = token, secret = secret)
} else if (nrow(rsconnect::accounts()) == 0L) {
  stop(
    "No shinyapps.io account available. Either set SHINYAPPS_NAME, ",
    "SHINYAPPS_TOKEN and SHINYAPPS_SECRET, or run rsconnect::setAccountInfo().",
    call. = FALSE
  )
}

rsconnect::deployApp(
  appDir = ".",
  appName = "genprocshiny",
  appTitle = "genprocShiny",
  account = if (nzchar(account)) account else NULL,
  server = if (nzchar(account)) "shinyapps.io" else NULL,
  lint = FALSE,
  forceUpdate = TRUE,
  logLevel = "normal"
)
