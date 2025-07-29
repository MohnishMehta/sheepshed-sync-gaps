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


ppm_df <- ppm_df %>%
  mutate(Time = lubridate::ymd_hms(Time, tz = "America/New_York"))

intervals_df <- ppm_df %>% 
  arrange(Time) %>%                           # chronological order
  mutate(
    lag_sec = as.numeric(                        # gap in seconds
      difftime(Time, dplyr::lag(Time), units = "secs")
    )
  ) %>% 
  filter(!is.na(lag_sec))                        # drop the first NA gap


hist_plot <- ggplot(intervals_df, aes(lag_sec)) +
  geom_histogram(binwidth = 30, colour = "black", fill = "steelblue") +
  geom_vline(xintercept = c(540, 660), linetype = "dashed") +
  geom_vline(xintercept = 600,      linetype = "dotted") +
  coord_cartesian(xlim = c(0, 1200)) +                 # ⬅ zoom to 0–1200 s
  scale_x_continuous(breaks = seq(0, 1200, 200)) +     # ⬅ ticks every 200 s
  labs(
    title = "Inter-ping gap distribution (0 – 1200 s window)",
    x     = "Gap between successive detections (s)",
    y     = "Count"
  ) +
  theme_minimal()

print(hist_plot)   # shows in Plots tab

n_total   <- nrow(intervals_df)                              # total gaps
n_in_band <- sum(between(intervals_df$lag_sec, 540, 660))    # gaps in spec
pct_in    <- 100 * n_in_band / n_total                       # percentage

cat(sprintf(
  "\nSync-gap performance (ID 15236):\n  %d of %d gaps (%.2f %%) lie between 540 and 660 seconds\n\n",
  n_in_band, n_total, pct_in
))
