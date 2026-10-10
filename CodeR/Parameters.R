# Heatwave mortality in France from 1990 to 2025 in high spatiotemporal resolution
# Hans-Aloys Wischmann, Institute for Public Health, Charité - Universitätsmedizin Berlin
# Rewritten: 2026-05-16 to 2026-08-28

# ensure consistency across systems, define presets, set default figure size
Sys.setlocale("LC_ALL", 'en_US.UTF-8')
Sys.setenv(LANG = "en_US.UTF-8")
knitr::opts_chunk$set(echo = FALSE, fig.width = 6, fig.height = 6, dpi = 600, comment = NA)
knitr::opts_knit$set(root.dir = getwd())
start_time <- proc.time();
set.seed(314159)

# load required libraries, start the clock
library(tidyverse)
library(flextable)
library(foreach)
library(doParallel)
library(RhpcBLASctl)
library(sf)

# configurable parameters: seasonal range (summer)
SUMMER_START  <- "%04d-04-15" # April 15 of each year
SUMMER_END    <- "%04d-10-15" # October 15 of each year

# configurable parameters: years to analyze, and years to exclude (one year with reporting artefacts and two years with COVID waves in summer)
YEARS_ANALYZE <- 1990:2025
YEARS_EXCLUDE <- c(1997, 2020, 2022)

#configurable parameters: 15-year age brackets
AGE_BRACKETS <- data.frame(age_from = c(0, 20, 40, 60, 80, 90), age_to = c(19, 39, 59, 79, 89, 99)) %>% mutate(age = fct_inorder(str_replace(sprintf("%02d-%02d", age_from, age_to), "-99$", "+")))

# consistent factorization with configurable labels
factor_age     <- function(v) { return(factor(v, ordered = TRUE,  levels = rev(AGE_BRACKETS$age))) }
factor_fm      <- function(v) { return(factor(v, ordered = FALSE, levels = c("F", "M"),           labels = c("Female", "Male"))) }
factor_sex     <- function(v) { return(factor(v, ordered = FALSE, levels = c("Femmes", "Hommes"), labels = c("Female", "Male"))) }
factor_climat  <- function(v) { return(factor(v, ordered = TRUE,  levels = c("Océanique", "Océanique altéré", "Semi-continental", "Montagnard", "Méditerranéen"))) }
factor_densite <- function(v) { return(factor(v, ordered = TRUE,  levels = c("Rural", "Urbain intermédiaire", "Urbain dense"))) }

# configurable styles: color palettes for categorical data with 12 entries, heatmap, projection
safe_colorblind_palette <- c("#88CCEE", "#CC6677", "#DDCC77", "#117733", "#332288", "#AA4499", "#44AA99", "#999933", "#882255", "#661100", "#6699CC", "#888888")
safe_heatmap_palette    <- c("#0066FF", "#00CCFF", "#66FF00", "#FFFF00", "#FF7F00", "#FF0000", "#CF00FF", "#9F00FF")
safe_humidity_palette   <- c("#05192C", "#D0AE8B", "#E8E4E2", "#73CCD8", "#52B1D2")
safe_climate_palette    <- c("#88CCEE", "#44AA99", "#E8E4E2", "#CC6677", "#DDCC77")
CRS_SF                  <- "+proj=laea +lat_0=45 +lon_0=2"

# administrative info: new year and mid year tick marks for multi-year plots, axis labels
MID_YEAR_DATES <- seq(as.Date(sprintf("%d-07-01", min(YEARS_ANALYZE))), as.Date(sprintf("%d-07-01", max(YEARS_ANALYZE)    )), by = "year")
NEW_YEAR_DATES <- seq(as.Date(sprintf("%d-01-01", min(YEARS_ANALYZE))), as.Date(sprintf("%d-01-01", max(YEARS_ANALYZE) + 1)), by = "year")
YEAR_BREAKS <- c(MID_YEAR_DATES, NEW_YEAR_DATES)
YEAR_LABELS <- c(min(YEARS_ANALYZE):max(YEARS_ANALYZE), rep("|", length(NEW_YEAR_DATES)))

# utility function to use all physical cores for threads, up to max_threads, and to limit parallelization of BLAS per thread
config_parallel <- function(max_threads = NA, max_BLAS = NA) {
  registerDoParallel(  cores   = min(get_num_cores(), max_threads, na.rm = TRUE))
  blas_set_num_threads(threads = min(get_num_cores(), max_BLAS,    na.rm = TRUE))
  print(sprintf("Configured %d workers (%s), BLAS = %d threads", getDoParWorkers(), getDoParName(), blas_get_num_procs()))
}
config_parallel()
  
# utility function to plot to *.pdf and *.png file and inline
ggplot_font_size = 10 # font size for all texts except for geom_text, in points
plot_pdf_png <- function(file_name, aspect_ratio, plot_object, plot_width = 6.25, plot_res = 600) {
  themed_object <- plot_object + theme(text = element_text(size = ggplot_font_size), plot.title = element_text(size = ggplot_font_size))
  png(sprintf("../Plots/%s.png", file_name), width = plot_width, height = plot_width * aspect_ratio, units = "in", res = plot_res)
  print(themed_object)
  ignore <- dev.off()
  pdf(sprintf("../Plots/%s.pdf", file_name), plot_width, plot_width * aspect_ratio, paper = "a4")
  print(themed_object)
  ignore <- dev.off()
  print(themed_object)
}

# create a standard theme
std_theme <- function() {
  theme(
    panel.border     = element_rect(colour = "black", fill = NA),
    panel.background = element_rect(fill   = "white"),
    panel.grid.major = element_line(colour = "gray80", linewidth = 0.2),
    axis.text  = element_text(colour = "black"),
    axis.title = element_text(colour = "black"),
    axis.ticks = element_line(colour = "black"),
    legend.position = "right"
  )
}

# utility functions to log elapsed, system, and user times
time_log <- data.frame()
simple_time_log <- function(tag) {
  p <- as.data.frame(proc.time() - start_time)
  return(data.frame(tag, elapsed = p["elapsed",], user = p["user.self",] + p["user.child",], sys = p["sys.self",] + p["sys.child",]) %>% reframe(tag, across(!tag, ~round(.x, 1))))
}
append_time_log <- function(tag) {
  time_log <<- rbind(time_log, simple_time_log(tag))
}
