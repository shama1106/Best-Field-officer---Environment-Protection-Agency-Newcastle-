select Officer_ID, max(Officer_Name) OfficerName,count(1) as [Number_Activity_Each_officer] from [dbo].[vw_performance_details_all]
where Monitoring_Date is not null or Monitoring_Date <> ''
group by Officer_ID
order by 3 desc

-- Jane White has highest number of activities (601)

select Officer_ID,max(Officer_Name) OfficerName,AVG(Activity_Duration) Avg_Activity_Duration from [vw_performance_details_all]
group by Officer_ID
order by 3 desc

-- Fiona Wilson has high average activity duration (4.643761)

select Officer_ID,max(Officer_Name) OfficerName, count(1) [TotalNumberOfRating(for 5)] from [vw_performance_details_all]
where Community_Feedback_Rating = 5
group by Officer_ID
order by 3 desc

-- Samantha Wright has highest rating of 5 with 135 counts

select Officer_ID,max(Officer_Name) OfficerName, count(1) [TotalNumberNonCompliant] from [vw_performance_details_all] 
where compliance_status = 'Compliant'
group by Officer_ID
order by 3 desc

-- Kate Harris has highest non compliants with 300 counts

--create view [vw_performance_metric_collection]
--as
--SELECT Officer_ID,max(officer_name) as Officer_Name,
--       COUNT(Activity_ID) AS TotalActivities,
--       AVG(Activity_Duration) AS AvgDuration,
--       AVG(Community_Feedback_Rating) AS AvgFeedback,
--       SUM(CASE WHEN compliance_status = 'Compliant' THEN 1 ELSE 0 END) * 1.0 / COUNT(Activity_ID) * 100 AS ComplianceRate
--FROM [vw_performance_details_all]
--GROUP BY Officer_ID;
------- To calculate complianceRate, (no of compliant activities / total activities) * 100

--identify the officer with the highest total activities, the best average feedback rating, and a high compliance rate
select * from vw_performance_metric_collection order by 3 desc,4 desc,5 desc,6 desc

select * from vw_performance_metric_collection order by avgduration desc