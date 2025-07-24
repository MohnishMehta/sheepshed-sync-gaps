#Make sure remotes is available
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes", repos = "https://cloud.r-project.org")
}

library(remotes)

#Make sure glatos is available
if (!requireNamespace("glatos", quietly = TRUE)) {
  install_github(
    "ocean-tracking-network/glatos",
    build_vignettes = FALSE,
    dependencies   = TRUE,
    upgrade        = "never"
  )
}

#Load all project packages
library(glatos)
library(dplyr)
library(lubridate)
library(ggplot2)
