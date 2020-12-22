##################################################################################################
# prepares NWIS, IDFG data for dashboard
# Jason Williams
# 9/13/19
#################################################################################################

# setup-----------------------------------------------------------------------------------------

# loads required R packages (8-6-19 versions from CRAN via checkpoint)
library(dataRetrieval)
library(tidyverse)
library(lubridate)
library(reshape2)

# use dataRetrieval to download temp data at ID USGS gauge sites------------------------------

# specify parameters, statistics of interest
pCode <-"00010" # Temperature, water C
stats <-c("00001", "00003") # daily max, daily average
start <-"2016-01-01"

# gets data
temp_ID <-readNWISdata(service = "dv",
                       stateCd = "ID",
                       parameterCd = pCode,
                       statCd = stats,
                       startDate = start)

# gets site info
sites <-levels(unique(as.factor(temp_ID$site_no)))
str(sites)

sites_ID <-
  readNWISsite(sites) %>%
  select(site_no, station_nm, site_tp_cd, dec_lat_va, dec_long_va, dec_coord_datum_cd) %>%
  mutate(source = "USGS (NWIS)")

# puts together, selects and renames relevant columns
temp_ID_formatted <-
  merge(sites_ID, temp_ID, by = "site_no", all.y = TRUE) %>%
  rename(daily_mean = X_00010_00003,
         daily_mean_code = X_00010_00003_cd,
         daily_max = X_00010_00001,
         daily_max_code =  X_00010_00001_cd) %>%
  select(agency_cd, site_no, site_no, station_nm, site_tp_cd, dec_lat_va, dec_long_va, dec_coord_datum_cd,
         dateTime, daily_mean, daily_mean_code, daily_max, daily_max_code)

str(temp_ID_formatted)

# data for dashboard--------------------------------------------------------------------------------

IDFG_sites <-
  read.csv("IDFG_sites.csv", header = TRUE) %>%
  select(-X)

IDFG_daily <-
  read.csv("IDFG_daily.csv", header = TRUE) %>%
  select(-X)

sites_for_dashboard <-
  rbind(sites_ID, IDFG_sites) %>%
  mutate(plot_title = paste(site_no, station_nm, sep = " "))

tempdata_for_dashboard <-
  rbind(temp_ID_formatted, IDFG_daily) %>%
  mutate(plot_title = paste(site_no, station_nm, sep = " "))

str(tempdata_for_dashboard)
