#loads needed packages from 00_packages.R file
source("R/00_packages.R")  

#reads all detections and creates dataframe
vdat <- read_vdat_csv(
  "data/raw/NexTrak-R1 801633 2025-06-17 101059 DETECTS.csv",
  record_types = "DET"
)

det_df <- vdat$DET

#keeps only PPM detections as those indicate when the LSH6 receiver picks up the LSH7 receiver and gets rid of columns with no data
ppm_df <- det_df %>%
  filter(`Detection Type` == "PPM") %>%
  filter(`ID` == "15236") %>%
  select(where(~ !any(is.na(.))))

#sets time to right format incase it is not already 
ppm_df <- ppm_df %>%
  mutate(Time = lubridate::ymd_hms(Time, tz = "America/New_York"))

#arranges time in order and adds a lag_sec column for time difference between detections
intervals_df <- ppm_df %>% 
  arrange(Time) %>%                           
  mutate(
    lag_sec = as.numeric(                        
      difftime(Time, dplyr::lag(Time), units = "secs")
    )
  ) %>% 
  filter(!is.na(lag_sec))                        

#creates histogram to show distribution
hist_plot <- ggplot(intervals_df, aes(lag_sec)) +
  geom_histogram(binwidth = 30, colour = "black", fill = "steelblue") +
  geom_vline(xintercept = c(540, 660), linetype = "dashed") +
  geom_vline(xintercept = 600,      linetype = "dotted") +
  coord_cartesian(xlim = c(0, 1200)) +                 
  scale_x_continuous(breaks = seq(0, 1200, 200)) +    
  labs(
    title = "Inter-ping gap distribution (0 – 1200 s window)",
    x     = "Gap between successive detections (s)",
    y     = "Count"
  ) +
  theme_minimal()

#saves histogram to plots folder within outputs folder
dir.create("output/plots", recursive = TRUE, showWarnings = FALSE)   # make folder if absent
ggsave("output/plots/gap_histogram_15236.png",
       plot   = hist_plot,
       width  = 7, height = 4, dpi = 300)

#calculates how many gaps are within 540s - 660s 
n_total   <- nrow(intervals_df)                              
n_in_band <- sum(between(intervals_df$lag_sec, 540, 660))    
pct_in    <- 100 * n_in_band / n_total                       

cat(sprintf(
  "\nSync-gap performance (ID 15236):\n  %d of %d gaps (%.2f %%) lie between 540 and 660 seconds\n\n",
  n_in_band, n_total, pct_in
))

# makes new column with TRUE or FALSE values based on reciever gap times
intervals_df <- intervals_df %>%
  mutate(hit = lag_sec >= 540 & lag_sec <= 660)

# save for downstream modelling
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
saveRDS(intervals_df, "data/processed/intervals_df_with_hit.rds")
