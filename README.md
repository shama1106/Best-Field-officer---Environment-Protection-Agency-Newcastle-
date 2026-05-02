
# 🌍 Field Officer Performance & Environmental Compliance Analytics

<img width="1345" height="751" alt="Screenshot 2026-05-02 142028" src="https://github.com/user-attachments/assets/ccdb9505-efa5-4035-985c-2e5a53694bf7" />


## 📊 Project Overview
This project analyzes environmental monitoring data to evaluate **field officer performance, compliance levels, and operational efficiency** using a **data warehouse and business intelligence approach**.

---

## 🧠 Solution Approach

- Data Cleaning using Python & SQL  
- ETL Pipeline (Raw → Staging → Warehouse)  
- Star Schema Data Model  
- SQL Analytics (KPIs & Ranking)  
- Power BI Dashboard  

---

## 🏗️ Data Model (Star Schema)

<img width="790" height="513" alt="Star Diagram" src="https://github.com/user-attachments/assets/a0b2097c-4867-4062-b2a0-6d2a6884ceec" />


- Fact Table: `fact_performance`  
- Dimension Tables:
  - dim_officer  
  - dim_site  
  - dim_activity_type  
  - dim_time  
  - dim_compliance_status  
  - dim_equipment_details  

---

## ⚙️ ETL Process

1. Raw Excel → Converted to CSV  
2. Loaded into SQL Server (Staging Table)  
3. Data Cleaning:
   - Removed duplicates  
   - Standardized IDs  
   - Converted data types  
4. Loaded into Fact & Dimension tables  

---

## 🧪 SQL Analysis

Key metrics calculated:

- Compliance Rate  
- Average Activity Duration  
- Community Feedback  
- Pollution Detection  
- Cost Efficiency  

Advanced SQL used:
- Window Functions (`RANK()`, `ROW_NUMBER()`)

---

## 📈 Dashboard Insights

- High-performing officer identified  
- Compliance trends analyzed  
- Resource utilization evaluated  
- Cost efficiency compared  

---

## 🏆 Key Result

**Best Officer: Jane White**
- Compliance Rate: 95%  
- Feedback: 4.8 / 5  
- Highest performance score  
- Most cost-efficient  

---


## 🛠️ Tools & Technologies

- SQL Server  
- Python (Pandas)  
- Power BI  
- Data Warehouse (Star Schema)  

---

## 💼 Business Impact

- Improved decision-making  
- Identified top performers  
- Optimized resource allocation  
- Enhanced compliance monitoring  

---

## 🚀 Future Improvements

- Real-time data pipeline  
- Predictive analytics  
- Cloud integration (AWS/Azure)  

---

## ⭐ Final Note

This project demonstrates **end-to-end data analytics workflow** from raw data to business insights.



