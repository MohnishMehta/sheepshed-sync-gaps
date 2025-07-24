#loads needed packages from 00_packages.R file
source("R/00_packages.R")  

#reads all detections and creates dataframe
vdat <- read_vdat_csv(
  "data/raw/NexTrak-R1 801633 2025-06-17 101059 DETECTS.csv",
  record_types = "DET"
)

det_df <- vdat$DET

# 2) keeps only PPM detections as those indicate when the LSH6 reciver picks up the LSH7 reciever
ppm_df <- det_df %>%
  filter(`Detection Type` == "PPM")




