insert into [SourceData]
(Monitoring_Date, Officer_ID, Officer_Name, Site_ID, Site_Name, Site_Location, Activity_ID, Activity_Type, Activity_Description,
Activity_Duration, Equipment_Used, Pollution_Level_Detected, Compliance_Status, Community_Feedback_Rating, Transaction_ID)
SELECT
Monitoring_Date = convert(date,[Monitoring Date]),
Officer_ID = convert(int,[Officer ID]),
Officer_Name = convert(varchar(100),[Officer Name]),
Site_ID = convert(int,[Site ID]),
Site_Name = convert(varchar(100),[Site Name]),
Site_Location = convert(varchar(100),[Site Location]),
Activity_ID = convert(int,[Activity ID]),
Activity_Type = convert(varchar(100),[Activity Type]),
Activity_Description = convert(varchar(100),[Activity Description]),
Activity_Duration = convert(decimal(16,4),[Activity Duration (hours)]),
Equipment_Used = convert(varchar(100),[Equipment Used]),
Pollution_Level_Detected = convert(decimal(16,4),[Pollution Level Detected]),
Compliance_Status = convert(varchar(100),[Compliance Status]),
Community_Feedback_Rating = convert(int,[Community Feedback Rating]),
Transaction_ID = convert(int,[Transaction ID])
  FROM [INFO6090_Assignment].[dbo].[INFO6090 Assignment 1 - Dataset]
