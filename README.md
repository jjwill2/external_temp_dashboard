# external_temp_dashboard
draft dashboard for viewing USGS and IDFG stream temperature data in Idaho

'formats_IDFG_data_for_dashboard.R' used 'station.csv' and 'result (46).zip' to create IDFG_daily.csv, and IDFG_sites.csv

'preps_data_for_dashboard.R' uses dataRetrieval R package to download NWIS data, and combines with IDFG data for use in the dashboard.

'NWIS_temp_data_viewer' is code for the dashboard itself.

idhodeq.shinyapps.io/dashboard
