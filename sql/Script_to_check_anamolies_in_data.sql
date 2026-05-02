---- Query to identify single officer has multiple officer IDs
select Officer_ID,Officer_Name,count(1) ccount from SourceData group by Officer_ID,Officer_Name order by Officer_Name

---- Query to check monitoring date has correct date format date values
select convert(date,monitoring_date) MonitoringDate from SourceData

---- Query to identify a site name has multiple site IDs
select Site_ID,Site_Name,count(1) from SourceData group by Site_ID, Site_Name order by Site_Name

---- Query to check the format of duration 
select * from SourceData where Activity_Duration is null or ISNUMERIC(Activity_Duration) = 0

---- Query to check the format of Pollution_Level_Detected 
select * from SourceData where Pollution_Level_Detected is null or ISNUMERIC(Pollution_Level_Detected) = 0

---- Query to check unique compliance status and feedback rating
select distinct Compliance_Status from SourceData
select distinct Community_Feedback_Rating from SourceData order by 1 
