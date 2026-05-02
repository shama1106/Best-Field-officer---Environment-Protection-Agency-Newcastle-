/*
Author: Rashik Maharjan
Date: 2024-09/23
Description: Bekow queries create fact, dimension tables and views.
*/



--create database INFO6090_Assignment

use INFO6090_Assignment
go
create table dbo.SourceData(
ID int identity(1,1) not null,
Monitoring_Date date not null,
Officer_ID int not null,
Officer_Name varchar(50) not null,
Site_ID int not null,
Site_Name varchar(100) not null,
Site_Location varchar(100) not null,
Activity_ID int not null,
Activity_Type varchar(100) not null,
Activity_Description varchar(100) not null,
Activity_Duration decimal(16,4) not null,
Equipment_Used varchar(50) not null,
Pollution_Level_Detected decimal(16,4) not null,
Compliance_Status varchar(50) not null,
Community_Feedback_Rating int not null,
Transaction_ID int not null
)

go
--drop table fact_performace

CREATE TABLE [dbo].[fact_performace](
	[Performance_ID] [int] IDENTITY(1,1) NOT NULL,
	[Time_ID] [int] NOT NULL,
	[Officer_ID] [int] NOT NULL,
	[Site_ID] [int] NOT NULL,
	[Activity_ID] [int] NOT NULL,
	[Activity_Type_ID] [int] NOT NULL,
	[Activity_Description] [varchar](100) NOT NULL,
	[Pollution_Level_Detected] [decimal](16, 4) NOT NULL,
	[Compliance_Status_ID] [int] NOT NULL,
	[Community_Feedback_Rating] [int] NOT NULL,
	[Equipment_ID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Performance_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[fact_performace]  WITH CHECK ADD FOREIGN KEY([Activity_Type_ID])
REFERENCES [dbo].[dim_activity_type] ([Activity_Type_ID])
GO

ALTER TABLE [dbo].[fact_performace]  WITH CHECK ADD FOREIGN KEY([Compliance_Status_ID])
REFERENCES [dbo].[dim_compliance_status] ([Status_ID])
GO

ALTER TABLE [dbo].[fact_performace]  WITH CHECK ADD FOREIGN KEY([Equipment_ID])
REFERENCES [dbo].[dim_equipment_details] ([Equipment_ID])
GO

ALTER TABLE [dbo].[fact_performace]  WITH CHECK ADD FOREIGN KEY([Officer_ID])
REFERENCES [dbo].[dim_officer] ([Officer_ID])
GO

ALTER TABLE [dbo].[fact_performace]  WITH CHECK ADD FOREIGN KEY([Site_ID])
REFERENCES [dbo].[dim_site] ([Site_ID])
GO

ALTER TABLE [dbo].[fact_performace]  WITH CHECK ADD FOREIGN KEY([Time_ID])
REFERENCES [dbo].[dim_time] ([Time_ID])

go

create table dbo.dim_officer(
ID int identity(1,1) not null,
Officer_ID int primary key not null,
Officer_Name varchar(50) not null 
)

go

create table dbo.dim_site(
ID int identity(1,1) not null,
Site_ID int primary key not null,
Site_Name varchar(100) null,
Site_Location varchar(100) null
)

go
--drop table dim_activity_type
create table dbo.dim_activity_type(
Activity_Type_ID int identity(1,1) primary key not null,
Activity_Type varchar(100) not null
)

go

GO

CREATE TABLE [dbo].[dim_time](
	[Time_ID] [int] IDENTITY(1,1) NOT NULL,
	[Monitoring_Date] [date] NOT NULL,
	[Year] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[Transaction_ID] [int] NOT NULL,
	[Activity_Duration] [decimal](16, 4) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Time_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


go

CREATE TABLE [dbo].[dim_equipment_details](
	[Equipment_ID] [int] IDENTITY(1,1) NOT NULL,
	[Equipment_Used] [varchar](50) NULL,
	[Assumed_Cost_Per_Unit] [decimal](16, 4) NULL,
	EffectiveDate date null
PRIMARY KEY CLUSTERED 
(
	[Equipment_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

go

CREATE TABLE [dbo].[dim_compliance_status](
	[Status_ID] [int] IDENTITY(1,1) NOT NULL,
	[compliance_status] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[Status_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE view [dbo].[vw_performance_details_all]
as
select dt.Monitoring_Date,o.Officer_ID,Officer_Name,s.Site_ID,s.Site_Name,s.Site_Location, p.Activity_ID,p.Activity_Type_ID,
a.Activity_Type,p.Activity_Description, dt.Activity_Duration,ed.Equipment_Used,p.Pollution_Level_Detected, cs.compliance_status,p.Community_Feedback_Rating,
dt.Transaction_ID
from fact_performace p inner join dim_time dt
on p.Time_ID = dt.Time_ID
inner join dim_officer o on p.Officer_ID = o.Officer_ID
inner join dim_site s on p.Site_ID = s.Site_ID
inner join dim_activity_type a on a.Activity_Type_ID = p.Activity_Type_ID
inner join dim_equipment_details ed on p.Equipment_ID = ed.Equipment_ID
inner join dim_compliance_status cs on p.Compliance_Status_ID = cs.Status_ID
GO

CREATE view [dbo].[vw_performance_metric_collection]
as
select qry.*,tc.TotalCostByOfficer from (
SELECT Officer_ID,max(officer_name) as Officer_Name,
       COUNT(Activity_ID) AS TotalActivities,
       AVG(Activity_Duration) AS AvgDuration,
       AVG(Community_Feedback_Rating) AS AvgFeedback,
       SUM(CASE WHEN compliance_status = 'Compliant' THEN 1 ELSE 0 END) * 1.0 / COUNT(Activity_ID) * 100 AS ComplianceRate,
	   avg(a.Pollution_Level_Detected) avg_pollution_level
	   
FROM [vw_performance_details_all] a 
GROUP BY Officer_ID
) qry inner join vw_TotalCostByOfficer tc on qry.Officer_ID = tc.officer_id
;
GO

create view [dbo].[vw_TotalCostByOfficer]
as
select officer_id,sum(TotalCostByOfficerInEachEquipment) as TotalCostByOfficer from (
select a.*, total_equipment_used * ed.Assumed_Cost_Per_Unit as TotalCostByOfficerInEachEquipment from (
select Officer_ID,equipment_used,count(1) as total_equipment_used from vw_performance_details_all group by Officer_ID,equipment_used
) a inner join dim_equipment_details ed
on a.Equipment_Used = ed.Equipment_Used
) b
group by Officer_ID
GO

create view [dbo].[vw_bestOfficerCalculation]
as

WITH RankedOfficers AS (
    SELECT 
        Officer_ID,
        Officer_Name,
        TotalActivities,
        AvgDuration,
        AvgFeedback,
        ComplianceRate,
        avg_pollution_level,
        TotalCostByOfficer,
        RANK() OVER (ORDER BY TotalActivities DESC) AS ActivityRank, -- higher is better
        RANK() OVER (ORDER BY AvgDuration ASC) AS DurationRank, -- lower is better
        RANK() OVER (ORDER BY AvgFeedback DESC) AS FeedbackRank, -- higher is better
        RANK() OVER (ORDER BY ComplianceRate DESC) AS ComplianceRank, -- higher is better
        RANK() OVER (ORDER BY avg_pollution_level ASC) AS PollutionRank, -- lower is better
        RANK() OVER (ORDER BY TotalCostByOfficer ASC) AS CostRank -- lower is better
    FROM vw_performance_metric_collection
)

-- Step 4: Calculate total points based on ranks
SELECT  
    Officer_ID,
    Officer_Name,
    (ActivityRank + DurationRank + FeedbackRank + ComplianceRank + PollutionRank + CostRank) AS TotalPoints,
	ROW_NUMBER()over(order by (ActivityRank + DurationRank + FeedbackRank + ComplianceRank + PollutionRank + CostRank)) Rankk

	--into #temp
FROM RankedOfficers

GO

create view [dbo].[vw_bestOfficerCalculation_all]
as
WITH RankedOfficers AS (
    SELECT 
        Officer_ID,
        Officer_Name,
        TotalActivities,
        AvgDuration,
        AvgFeedback,
        ComplianceRate,
        avg_pollution_level,
        TotalCostByOfficer,
        RANK() OVER (ORDER BY TotalActivities DESC) AS ActivityRank,
        RANK() OVER (ORDER BY AvgDuration ASC) AS DurationRank,
        RANK() OVER (ORDER BY AvgFeedback DESC) AS FeedbackRank,
        RANK() OVER (ORDER BY ComplianceRate DESC) AS ComplianceRank,
        RANK() OVER (ORDER BY avg_pollution_level ASC) AS PollutionRank,
        RANK() OVER (ORDER BY TotalCostByOfficer ASC) AS CostRank
    FROM vw_performance_metric_collection
),
TotalPoints AS (
    SELECT  
        *,
        (ActivityRank + DurationRank + FeedbackRank + ComplianceRank + PollutionRank + CostRank) AS TotalPoints,
        ROW_NUMBER() OVER (ORDER BY (ActivityRank + DurationRank + FeedbackRank + ComplianceRank + PollutionRank + CostRank)) AS Rankk
    FROM RankedOfficers
)

SELECT 
    a.Officer_ID,
    a.Officer_Name,
    a.TotalActivities,
    a.AvgDuration,
    a.AvgFeedback,
    a.ComplianceRate,
    a.avg_pollution_level,
    a.TotalCostByOfficer,
    a.ActivityRank,
    a.DurationRank,
    a.FeedbackRank,
    a.ComplianceRank,
    a.PollutionRank,
    a.CostRank,
    b.Rankk
FROM RankedOfficers a
JOIN TotalPoints b ON a.Officer_ID = b.Officer_ID
--ORDER BY b.Rankk;
GO


