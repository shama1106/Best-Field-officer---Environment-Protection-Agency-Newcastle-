/*
Author: Rashik Maharjan
Date: 2024-09-25
Description: This query inserts data into fact and dim tables.
*/

-- SourceData contains the original data provided by the client

-- A. officer details - DIM table
/*assumption:

1. Officer ID and Officer Name has inconsistancies.
2. Data has 25 Officer Name and 25 Officer ID.
3. Assigning Officer ID in ascending order to Officer Name in alphabetical order.

*/

WITH OfficerData AS (
    SELECT DISTINCT 
        Officer_Name,
        ROW_NUMBER() OVER (ORDER BY Officer_Name) AS AutoIncrementID
    FROM 
        (SELECT DISTINCT Officer_Name 
         FROM SourceData) AS o
),
OfficerIDs AS (
    SELECT DISTINCT 
        Officer_ID,
        ROW_NUMBER() OVER (ORDER BY Officer_ID) AS AutoIncrementID
    FROM 
        (SELECT DISTINCT Officer_ID 
         FROM SourceData) AS i
)
Insert into [dbo].[dim_officer] (Officer_ID, Officer_Name)
select b.Officer_ID,a.Officer_Name from OfficerData a inner join OfficerIDs b
on a.AutoIncrementID = b.AutoIncrementID  -- 25

-- B. Activity Details - DIM table

insert into dim_activity_type(Activity_Type)
select distinct Activity_Type from SourceData where Activity_Type is not null or Activity_Type <> ''

-- C. Equipment Details - DIM table

insert into dim_equipment_details(Equipment_Used)
select Equipment_Used from (
select distinct Equipment_Used, 
cast(SUBSTRING(Equipment_Used, PATINDEX('%[0-9]%', Equipment_Used), LEN(Equipment_Used)) as int) abc
 from SourceData 
 
 ) a where Equipment_Used is not null or Equipment_Used <> ''
 order by abc

-- D. site details - DIM table
/*
Assumption:
1. There is inconsistency in site details.
2. While checking on distinct values, there are 24 site id and 23 site name. Therefore, for 1 site id there is no site name which is null
3. Mapping 24 site id to random site name rather than sorting
*/

--select distinct Site_ID, IDENTITY(int,1,1) sn into #temp_SiteID from SourceData -- 24
--select distinct Site_Name,Site_Location, IDENTITY(int,1,1) sn into #temp_SiteName from SourceData  -- 23

Insert into [dbo].[dim_site](Site_ID, Site_Name, Site_Location)
select a.Site_ID,b.site_name,b.site_location from #temp_siteid a 
left join #temp_SiteName b
on a.sn = b.sn
order by site_id

-- E. Time Details - DIM table
insert into [dim_time] (Monitoring_Date, Year, Month, Transaction_ID, Activity_Duration)
select distinct Monitoring_Date, year(Monitoring_Date), MONTH(Monitoring_Date),Transaction_ID,Activity_Duration 
from SourceData

-- F. Compliance Status
insert into dim_compliance_status(compliance_status)
select distinct Compliance_Status from SourceData where Compliance_Status != ''


-- G. Performance Details - FACT table
insert into fact_performace(Time_ID, Officer_ID, Site_ID, Activity_ID, Activity_Type_ID, Activity_Description,
Pollution_Level_Detected, Compliance_Status_ID, Community_Feedback_Rating, Equipment_ID)
select 
t.Time_ID,o.Officer_ID, s.Site_ID,a.Activity_ID,act.Activity_Type_ID,a.Activity_Description,
a.Pollution_Level_Detected,cs.Status_ID,a.Community_Feedback_Rating, ed.Equipment_ID
from SourceData a inner join dim_time t
on a.Monitoring_Date = t.Monitoring_Date
and a.Transaction_ID = t.Transaction_ID
and a.Activity_Duration = t.Activity_Duration
inner join dim_officer o
on a.Officer_Name = o.Officer_Name
inner join dim_site s
on a.Site_Name = s.Site_Name
inner join dim_activity_type act
on a.activity_type = act.Activity_Type
inner join dim_compliance_status cs
on a.Compliance_Status = cs.compliance_status
inner join dim_equipment_details ed
on a.Equipment_Used = ed.Equipment_Used
order by Time_ID
