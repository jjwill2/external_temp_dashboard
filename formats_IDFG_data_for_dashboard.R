##################################################################################################
# downloads IDFG temperature data from WQ Portal
# formats for use in dashboard
# Jason Williams
# 12/21/2020
#################################################################################################

# setup-----------------------------------------------------------------------------------------

# loads required R packages
#library(dataRetrieval)
library(tidyverse)
library(lubridate)
library(reshape2)

# gets IDFG temp data from WQ Portal------------------------------------------------------------
# direct load into R failed due to large amount results dataset, so downloaded csv via WQP web services to server folder

# temp results
# https://www.waterqualitydata.us/data/Result/search?organization=IIDFG&characteristicName=Temperature%2C%20water&startDateLo=01-01-2016&mimeType=csv&zip=no
IDFGtemp <-read.csv(unz("result (46).zip", "result (46).csv"), header = TRUE)

str(IDFGtemp)

# IDFG sites
# https://www.waterqualitydata.us/data/Station/search?organization=IIDFG&characteristicName=Temperature%2C%20water&startDateLo=01-01-2016&mimeType=csv&zip=no
IDFGsites <-read.csv("station.csv", header = TRUE)

# formats---------------------------------------------------------------------------------------

IDFGtemp_formatted <-
  merge(IDFGtemp, IDFGsites, by = "MonitoringLocationIdentifier", all.x = TRUE) %>%
  select(MonitoringLocationIdentifier, MonitoringLocationName, MonitoringLocationTypeName, 
         LatitudeMeasure, LongitudeMeasure,
         ActivityStartDate, ActivityStartTime.Time, ResultMeasureValue, ResultMeasure.MeasureUnitCode,
         OrganizationIdentifier.x, HorizontalCoordinateReferenceSystemDatumName)



# daily avlues

IDFG_daily <-
  IDFGtemp_formatted %>%
  select(OrganizationIdentifier.x, MonitoringLocationIdentifier, MonitoringLocationName,
         MonitoringLocationTypeName, LatitudeMeasure, LongitudeMeasure, HorizontalCoordinateReferenceSystemDatumName,
         ActivityStartDate, ActivityStartTime.Time, ResultMeasureValue) %>%
  rename(agency_cd = OrganizationIdentifier.x, site_no = MonitoringLocationIdentifier, 
         station_nm = MonitoringLocationName, site_tp_cd = MonitoringLocationTypeName, 
         dec_lat_va = LatitudeMeasure, dec_long_va = LongitudeMeasure, 
         dec_coord_datum_cd = HorizontalCoordinateReferenceSystemDatumName,
         dateTime = ActivityStartDate) %>%
  group_by(agency_cd, site_no, station_nm, site_tp_cd, dec_lat_va, dec_long_va, dec_coord_datum_cd,
           dateTime) %>%
  summarise(daily_mean = mean(ResultMeasureValue), daily_max = max(ResultMeasureValue)) %>%
  ungroup() %>%
  mutate(daily_mean_code = "", daily_max_code = "")

write.csv(IDFG_daily, "./IDFG_daily.csv")

# site data
sites_IDFG <-
  IDFGsites %>%
  rename(site_no = MonitoringLocationIdentifier, station_nm = MonitoringLocationName,
         site_tp_cd = MonitoringLocationTypeName, dec_lat_va = LatitudeMeasure, 
         dec_long_va = LongitudeMeasure, dec_coord_datum_cd = HorizontalCoordinateReferenceSystemDatumName) %>%
  select(site_no, station_nm, site_tp_cd, dec_lat_va, dec_long_va, dec_coord_datum_cd) %>%
  filter(site_no %in% IDFG_daily$site_no) %>%
  mutate(source = "IDFG (WQP)")

write.csv(sites_IDFG, "./IDFG_sites.csv")
