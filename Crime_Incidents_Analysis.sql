/*
Project: Crime Data Analysis

Objective:
- Perform Exploratory Data Analysis (EDA) on  Crime incidents dataset.

Dataset used:
-Crime Incidents in 2024 (https://catalog.data.gov/dataset/crime-incidents-in-2024)

Tools Used:
- MySQL Server 9.2
- Python (Pandas) for Date preprocessing
- Power BI for data visualization

Key Outcomes:
- Districts 3, 2, and 5 were identified as the most vulnerable to crimes.
- Crimes occurred more frequently during the evening shift.
- "Other(Non-Specific)", "Gun", and "Knife" were the top three crime methods recorded.

Visuals:
-Visual Insights were shown in power BI Dashboard.
*/

/* Step 1: Data Aggregation (Post preprocessing with pandas python library)  */
DROP TABLE IF EXISTS Crime_Incidents;
CREATE TABLE Crime_Incidents (
    CCN TEXT,
    REPORT_DAT TEXT,
    SHIFT TEXT,
    METHOD TEXT,
    OFFENSE TEXT,
    `BLOCK` TEXT,
    XBLOCK DOUBLE,
    YBLOCK DOUBLE,
    WARD TEXT,
    ANC TEXT,
    DISTRICT TEXT,
    PSA TEXT,
    NEIGHBORHOOD_CLUSTER TEXT,
    BLOCK_GROUP TEXT,
    CENSUS_TRACT TEXT,
    VOTING_PRECINCT TEXT,
    LATITUDE DOUBLE,
    LONGITUDE DOUBLE,
    START_DATE TEXT,
    END_DATE TEXT,
    OBJECTID TEXT
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 9.2/Uploads/Crime_Incidents_in_2024_cleaned.csv"
INTO TABLE Crime_Incidents
FIELDS TERMINATED BY ","
LINES TERMINATED BY "\n"
IGNORE 1 ROWS;

/* Step 2: Data Formatting */

SELECT * FROM Crime_Incidents LIMIT 10;
UPDATE Crime_Incidents SET END_DATE = NULL WHERE END_DATE = "";
UPDATE Crime_Incidents SET START_DATE = NULL WHERE START_DATE = "";
UPDATE Crime_Incidents SET PSA = NULL WHERE PSA = "";
UPDATE Crime_Incidents SET NEIGHBORHOOD_CLUSTER = NULL WHERE NEIGHBORHOOD_CLUSTER = "";
UPDATE Crime_Incidents SET CENSUS_TRACT = NULL WHERE CENSUS_TRACT = "";

ALTER TABLE Crime_Incidents
MODIFY COLUMN REPORT_DAT DATETIME,
MODIFY COLUMN START_DATE DATETIME,
MODIFY COLUMN END_DATE DATETIME;

/* Step 3: Crime Type Analysis */

#Most reported Crime Types
SELECT OFFENSE, COUNT(OFFENSE) AS OFFENSE_COUNT,SHIFT,
RANK() OVER (PARTITION BY SHIFT ORDER BY COUNT(OFFENSE) DESC) AS `SHIFT WISE RANK`
FROM Crime_Incidents
GROUP BY OFFENSE, SHIFT;
-- Observation: Most Reported Crimes in all time shifts were THEFT/Other, Theft F/Auto, Motor Vehicle Theft.

#Distribution of Crime methods used
SELECT COUNT(OFFENSE) AS OFFENSE_COUNT, METHOD,
DENSE_RANK() OVER (ORDER BY COUNT(OFFENSE) DESC) AS `RANK OF METHODS RECORDED`
FROM Crime_Incidents
GROUP BY METHOD;
-- Observation: Top three Crime methods recorded are 'Other', 'Gun', and 'Knife'
 
/* Step 4: Location & Time Based Analysis */
#Identifying Most Crime-Vulnerable Districts
SELECT COUNT(OFFENSE) AS CRIME_COUNT,DISTRICT,
RANK() OVER (ORDER BY COUNT(OFFENSE) DESC) AS `RANK OF CRIME HOTSPOT DISTRICTS`
FROM Crime_Incidents
GROUP BY DISTRICT;
-- Observation: Districts 3, 2, and 5 most vulnerable to crime as compared to others

#Identifying Most Crime-Vulnerable Blocks
SELECT COUNT(*) AS TOTAL_INCIDENTS,`BLOCK`,DISTRICT,
RANK() OVER (ORDER BY COUNT(*) DESC) AS `CRIME VULNERABILITY RANK`
FROM Crime_Incidents
GROUP BY `BLOCK`, DISTRICT
ORDER BY TOTAL_INCIDENTS DESC;
-- Top crime-prone blocks are:
   #- 3100-3299 Block of 14th Street NW (District 3)
   #- 2000-2099 Block of 8th Street NW (District 3)
   #- 1400-1499 Block of P Street NW (District 2)
   #- 812-899 Block of Bladensburg Road NE (District 5)
   #- 1737-1776 Block of Columbia Road NW (District 3)

SELECT REPORT_DAT,SHIFT,METHOD,START_DATE,END_DATE
FROM Crime_Incidents
LIMIT 100;

#Distribution of Crime occurrence by Time
SELECT COUNT(*) AS TOTAL_INCIDENTS,SHIFT
FROM Crime_Incidents
GROUP BY SHIFT
ORDER BY TOTAL_INCIDENTS DESC;
-- Observation: Most of the crimes happened during evening , followed by daytime and midnight being least.



