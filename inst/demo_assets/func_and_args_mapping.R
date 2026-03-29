# func
function (param_1 = "./r_built_in_datasets", param_2 = "airquality.rds",
          param_3 = "./out", param_4 = "airquality.csv")
{
  data <- readr::read_rds(file.path(param_1, param_2))
  data %>% readr::write_csv(file.path(param_3, param_4))
}

# args map
c("param_1" = "input_dir",
  "param_2" = "input_file",
  "param_3" = "output_dir",
  "param_4" = "output_file")
