-- =============================================
-- PROJECT: Field Officer Performance Analytics
-- DESCRIPTION: End-to-End SQL (ETL + KPI + Ranking)
-- AUTHOR: Shama
-- =============================================


-- =============================================
-- 1. CREATE STAGING TABLE
-- =============================================

CREATE TABLE SourceData (
    Monitoring_Date DATE,
    Officer_ID INT,
    Officer_Name VARCHAR(100),
    Site_ID INT,
    Site_Name VARCHAR(100),
    Site_Location VARCHAR(100),
    Activity_ID INT,
    Activity_Type VARCHAR(100),
    Activity_Description VARCHAR(100),
    Activity_Duration DECIMAL(16,4),
    Equipment_Used VARCHAR(100),
    Pollution_Level_Detected DECIMAL(16,4),
    Compliance_Status VARCHAR(50),
    Community_Feedback_Rating INT,
    Transaction_ID INT
);


-- =============================================
-- 2. CREATE DIMENSION TABLES
-- =============================================

CREATE TABLE dim_officer (
    Officer_ID INT PRIMARY KEY,
    Officer_Name VARCHAR(100)
);

CREATE TABLE dim_site (
    Site_ID INT PRIMARY KEY,
    Site_Name VARCHAR(100),
    Site_Location VARCHAR(100)
);

CREATE TABLE dim_activity_type (
    Activity_Type_ID INT IDENTITY(1,1) PRIMARY KEY,
    Activity_Type VARCHAR(100)
);

CREATE TABLE dim_compliance_status (
    Status_ID INT IDENTITY(1,1) PRIMARY KEY,
    Compliance_Status VARCHAR(50)
);

CREATE TABLE dim_equipment_details (
    Equipment_ID INT IDENTITY(1,1) PRIMARY KEY,
    Equipment_Used VARCHAR(100),
    Assumed_Cost_Per_Unit DECIMAL(10,2)
);

CREATE TABLE dim_time (
    Time_ID INT IDENTITY(1,1) PRIMARY KEY,
    Monitoring_Date DATE,
    Year INT,
    Month INT
);


-- =============================================
-- 3. CREATE FACT TABLE
-- =============================================

CREATE TABLE fact_performance (
    Performance_ID INT IDENTITY(1,1) PRIMARY KEY,
    Time_ID INT,
    Officer_ID INT,
    Site_ID INT,
    Activity_Type_ID INT,
    Status_ID INT,
    Equipment_ID INT,
    Activity_Duration DECIMAL(16,4),
    Pollution_Level_Detected DECIMAL(16,4),
    Community_Feedback_Rating INT,
    Transaction_ID INT
);


-- =============================================
-- 4. LOAD DIMENSION TABLES
-- =============================================

-- Officer
INSERT INTO dim_officer
SELECT DISTINCT Officer_ID, Officer_Name
FROM SourceData;

-- Site
INSERT INTO dim_site
SELECT DISTINCT Site_ID, Site_Name, Site_Location
FROM SourceData;

-- Activity Type
INSERT INTO dim_activity_type (Activity_Type)
SELECT DISTINCT Activity_Type
FROM SourceData;

-- Compliance Status
INSERT INTO dim_compliance_status (Compliance_Status)
SELECT DISTINCT Compliance_Status
FROM SourceData;

-- Equipment
INSERT INTO dim_equipment_details (Equipment_Used, Assumed_Cost_Per_Unit)
SELECT DISTINCT Equipment_Used, 0.05  -- assumed cost
FROM SourceData;

-- Time
INSERT INTO dim_time (Monitoring_Date, Year, Month)
SELECT DISTINCT 
    Monitoring_Date,
    YEAR(Monitoring_Date),
    MONTH(Monitoring_Date)
FROM SourceData;


-- =============================================
-- 5. LOAD FACT TABLE
-- =============================================

INSERT INTO fact_performance (
    Time_ID,
    Officer_ID,
    Site_ID,
    Activity_Type_ID,
    Status_ID,
    Equipment_ID,
    Activity_Duration,
    Pollution_Level_Detected,
    Community_Feedback_Rating,
    Transaction_ID
)
SELECT 
    t.Time_ID,
    s.Officer_ID,
    s.Site_ID,
    at.Activity_Type_ID,
    cs.Status_ID,
    e.Equipment_ID,
    s.Activity_Duration,
    s.Pollution_Level_Detected,
    s.Community_Feedback_Rating,
    s.Transaction_ID
FROM SourceData s
JOIN dim_time t ON s.Monitoring_Date = t.Monitoring_Date
JOIN dim_activity_type at ON s.Activity_Type = at.Activity_Type
JOIN dim_compliance_status cs ON s.Compliance_Status = cs.Compliance_Status
JOIN dim_equipment_details e ON s.Equipment_Used = e.Equipment_Used;


-- =============================================
-- 6. KPI VIEW
-- =============================================

CREATE VIEW vw_performance_metrics AS
SELECT 
    f.Officer_ID,
    o.Officer_Name,
    COUNT(*) AS Total_Activities,
    AVG(f.Activity_Duration) AS Avg_Duration,
    AVG(f.Community_Feedback_Rating) AS Avg_Feedback,
    SUM(CASE WHEN cs.Compliance_Status = 'Compliant' THEN 1 ELSE 0 END) * 1.0 
        / COUNT(*) * 100 AS Compliance_Rate,
    AVG(f.Pollution_Level_Detected) AS Avg_Pollution
FROM fact_performance f
JOIN dim_officer o ON f.Officer_ID = o.Officer_ID
JOIN dim_compliance_status cs ON f.Status_ID = cs.Status_ID
GROUP BY f.Officer_ID, o.Officer_Name;


-- =============================================
-- 7. ADVANCED ANALYSIS (RANKING)
-- =============================================

WITH RankedOfficers AS (
    SELECT *,
        RANK() OVER (ORDER BY Total_Activities DESC) AS ActivityRank,
        RANK() OVER (ORDER BY Avg_Duration ASC) AS DurationRank,
        RANK() OVER (ORDER BY Avg_Feedback DESC) AS FeedbackRank,
        RANK() OVER (ORDER BY Compliance_Rate DESC) AS ComplianceRank,
        RANK() OVER (ORDER BY Avg_Pollution ASC) AS PollutionRank
    FROM vw_performance_metrics
),

FinalRanking AS (
    SELECT *,
        (ActivityRank + DurationRank + FeedbackRank + ComplianceRank + PollutionRank) AS TotalScore,
        ROW_NUMBER() OVER (
            ORDER BY (ActivityRank + DurationRank + FeedbackRank + ComplianceRank + PollutionRank)
        ) AS FinalRank
    FROM RankedOfficers
)

SELECT * FROM FinalRanking
ORDER BY FinalRank;


-- =============================================
-- 8. SAMPLE ANALYSIS QUERIES
-- =============================================

-- Compliance Rate by Location
SELECT 
    s.Site_Location,
    SUM(CASE WHEN cs.Compliance_Status = 'Compliant' THEN 1 ELSE 0 END) * 1.0 
    / COUNT(*) * 100 AS Compliance_Rate
FROM fact_performance f
JOIN dim_site s ON f.Site_ID = s.Site_ID
JOIN dim_compliance_status cs ON f.Status_ID = cs.Status_ID
GROUP BY s.Site_Location;


-- Average Activity Duration by Type
SELECT 
    at.Activity_Type,
    AVG(f.Activity_Duration) AS Avg_Duration
FROM fact_performance f
JOIN dim_activity_type at ON f.Activity_Type_ID = at.Activity_Type_ID
GROUP BY at.Activity_Type;
