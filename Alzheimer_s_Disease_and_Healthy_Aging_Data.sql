
--Data Cleaning--
	UPDATE dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
SET Low_Confidence_Limit = (
    SELECT CAST(ROUND(AVG(CAST(Low_Confidence_Limit AS FLOAT)),0) AS INT)
    FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
    WHERE ISNUMERIC(Low_Confidence_Limit) = 1 AND Low_Confidence_Limit IS NOT NULL
);
--Replacing the null value in Data_Value --- 
UPDATE dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
SET Data_Value = (
    SELECT ROUND(AVG(Data_Value),1)
    FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
    WHERE Data_Value IS NOT NULL)
WHERE Data_Value IS NULL;

UPDATE dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
SET High_Confidence_Limit = ROUND(CAST(High_Confidence_Limit AS FLOAT), 1);

--Replacing the null values in Data_Value_Alt --
UPDATE dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
SET Data_Value_Alt = (
    SELECT ROUND(AVG(Data_Value_Alt),1)
    FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
    WHERE Data_Value_Alt IS NOT NULL)
WHERE Data_Value_Alt IS NULL;

--Replacing the null values in High_Confidence_Limit--
UPDATE dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
SET High_Confidence_Limit = (
    SELECT ROUND(AVG(High_Confidence_Limit),1)
    FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
    WHERE High_Confidence_Limit IS NOT NULL)
WHERE High_Confidence_Limit IS NULL;

--Replacing the null values in StratificationCategory2--
UPDATE dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
SET StratificationCategory2 = COALESCE(StratificationCategory2, 'Unknown')
WHERE StratificationCategory2 IS NULL;

--Analysis--
--Geographic Analysis

--How does the prevalence of Alzheimer's disease vary between different locations (LocationDesc)?--
SELECT 
    LocationDesc, 
    ROUND(AVG(Data_Value),1) AS Avg_Prevalence
FROM 
    dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
WHERE 
    Data_Value IS NOT NULL
GROUP BY 
    LocationDesc
ORDER BY 
    Avg_Prevalence DESC;

--What are the distinct locations (LocationDesc) and their corresponding abbreviations (LocationAbbr)?--
SELECT  DISTINCT LocationDesc AS Location, LocationAbbr
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data

--How does the data value (Data_Value) distribution vary by geolocation (Geolocation)?--
SELECT Geolocation, 
 ROUND(SUM(Data_Value),0) AS Total_Data_Value,
 ROUND(AVG(Data_Value),1) AS Avg_Data_Value,
 ROUND(MIN(Data_Value),1) AS Min_Data_Value,
 ROUND(MAX(Data_Value),1) AS Max_Data_Value,
 COUNT(*) AS Data_Value_Count
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
WHERE Geolocation IS NOT NULL
GROUP BY Geolocation
ORDER BY Total_Data_Value DESC;

--How does the confidence interval (Low_Confidence_Limit, High_Confidence_Limit) vary by location (LocationDesc)?--
SELECT LocationDesc, 
ROUND(AVG(Low_Confidence_Limit),1) AS Low_Confidence_Limit, 
ROUND(AVG(High_Confidence_Limit),1) AS High_Confidence_Limit
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
GROUP BY LocationDesc
ORDER BY  High_Confidence_Limit DESC;


-- How does the data value (Data_Value) compare between different geolocations (Geolocation)?
SELECT 
    Geolocation,
    COUNT(*) AS count_values,
    ROUND(AVG(Data_Value),1) AS avg_data_value,
    MIN(Data_Value) AS min_data_value,
    MAX(Data_Value) AS max_data_value
FROM 
    dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data

GROUP BY 
    Geolocation
ORDER BY 
    avg_data_value DESC;

--What is the distribution of high confidence limits (High_Confidence_Limit) across different locations (LocationDesc)?--

SELECT LocationDesc, 
 ROUND(SUM(High_Confidence_Limit),0) AS Total_High_Confidence_Limit,
 ROUND(AVG(High_Confidence_Limit),1) AS Avg_High_Confidence_Limit,
 ROUND(MIN(High_Confidence_Limit),1) AS Min_High_Confidence_Limit,
 ROUND(MAX(High_Confidence_Limit),1) AS Max_High_Confidence_Limit,
 COUNT(*) AS Data_Value_Count
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
GROUP BY LocationDesc
ORDER BY Total_High_Confidence_Limit DESC;

--Temporal Analysis--

-- How does the data value (Data_Value) change over time between YearStart and YearEnd? --
SELECT 
    YearStart, 
    YearEnd, 
    ROUND(AVG(Data_Value),1) AS Avg_Data_Value,
    (YearEnd - YearStart) AS Year_Difference
FROM 
    dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
WHERE 
    Data_Value IS NOT NULL
GROUP BY 
    YearStart, YearEnd
ORDER BY 
    YearStart, YearEnd;

--How does the data value (Data_Value) change across different years for the same location (LocationDesc)?--
SELECT 
LocationDesc,
(YearEnd- YearStart) AS Year_difference,
ROUND(AVG(Data_Value),1) AS Data_Value
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
GROUP BY LocationDesc, YearEnd, YearStart
ORDER BY Year_difference DESC;

-- How does the data value (Data_Value) compare across different years for the same topic (TopicID)? --
WITH TopicCounts AS (
    SELECT 
        Topic,
        COUNT(DISTINCT TopicID) AS TopicIDCount
    FROM 
        dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
    GROUP BY 
        Topic
)
SELECT 
    a.TopicID,
    a.Topic,
    ROUND(AVG(CAST(a.Data_Value AS FLOAT)), 1) AS Avg_Data_Value
FROM 
    dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data a
JOIN 
    TopicCounts tc ON a.Topic = tc.Topic
WHERE 
    tc.TopicIDCount > 1
    AND a.Data_Value IS NOT NULL
GROUP BY 
    a.TopicID, a.Topic
ORDER BY 
    Avg_Data_Value DESC;

Data Source and Value Analysis

--What is the average data value (Data_Value) for each data source (Datasource)?--
SELECT Datasource, AVG(Data_Value) AS Data_Value
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
GROUP BY Datasource;

--What is the distribution of data values (Data_Value) for each data source (Datasource)?--
SELECT Datasource, 
ROUND(MAX(Data_Value),1) AS Max_Data_value,
ROUND(MIN(Data_Value),1) AS Min_Data_Value,
ROUND(SUM(Data_Value),0) AS Total_Data_value
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
GROUP BY Datasource;

--Data Type and Value Analysis
--What are the most common data value types (Data_Value_Type) recorded in the dataset?
SELECT Data_Value_Type, 
COUNT ( Data_Value_Type) Num_recorded
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
GROUP BY Data_Value_Type;

---How does the data value (Data_Value) vary between different data value types (Data_Value_Type)?
SELECT Data_Value_Type, 
ROUND(SUM( Data_Value),0) Data_value
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
GROUP BY Data_Value_Type;

--Confidence Intervals Analysis
--How does the low confidence limit (Low_Confidence_Limit) compare to the high confidence limit (High_Confidence_Limit) for each topic (Topic)?
SELECT Topic, 
ROUND(AVG(Low_Confidence_Limit),1) AS avg_Low_Confidence_Limit,
ROUND(AVG(High_Confidence_Limit),1) AS avg_High_Confidence_Limit
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
GROUP BY Topic;

What is the correlation between data values (Data_Value) and their corresponding confidence intervals (Low_Confidence_Limit, High_Confidence_Limit)?
SELECT 
ROUND(AVG(Low_Confidence_Limit),1) AS avg_Low_Confidence_Limit,
ROUND(AVG(High_Confidence_Limit),1) AS avg_High_Confidence_Limit,
ROUND(AVG(Data_Value),1) AS avg_Data_Value
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data;


--Stratification Analysis
--What is the distribution of data values (Data_Value) across different stratification categories (StratificationCategory1)?
SELECT StratificationCategory1, 
ROUND(MAX(Data_Value),1) AS Max_Data_value,
ROUND(MIN(Data_Value),1) AS Min_Data_Value,
ROUND(SUM(Data_Value),0) AS Total_Data_value
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
GROUP BY StratificationCategory1;

--How does the data value (Data_Value) vary between different stratifications (Stratification2)?
SELECT Stratification2, 
ROUND(AVG(Data_Value),1) AS avg_Data_Value
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
GROUP BY Stratification2;

--What is the frequency of different stratification categories (StratificationCategory1, StratificationCategory2)?
SELECT StratificationCategory1,
StratificationCategory2, 
COUNT(*) AS Frequency
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
GROUP BY StratificationCategory1, StratificationCategory2 
ORDER BY StratificationCategory1, StratificationCategory2 DESC;

--How does the data value (Data_Value) vary between different stratification categories (StratificationCategoryID1)?
SELECT StratificationCategoryID1, 
ROUND(AVG(Data_Value),1) AS avg_Data_Value
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
GROUP BY StratificationCategoryID1;

--What is the distribution of data values (Data_Value) for each stratification (StratificationID1)?
SELECT StratificationCategoryID1, 
ROUND(AVG(Data_Value),1) AS avg_Data_Value,
ROUND(MIN(Data_Value),1) AS Min_Data_Value,
ROUND(MAX(Data_Value),1) AS Max_Data_Value,
COUNT(*) AS Num_values
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
GROUP BY StratificationCategoryID1;

--Topic and Class Analysis
--What are the distinct classes (Class) and topics (Topic) covered in the dataset?
SELECT DISTINCT Class, Topic
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data;

--What is the average data value (Data_Value) for each class (Class)?
SELECT Class,
ROUND(AVG(Data_Value),1) AS avg_Data_Value
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
GROUP BY Class
ORDER BY avg_Data_Value DESC;

--What is the range of data values (Data_Value) for each topic (Topic)?
SELECT Topic,
ROUND(AVG(Data_Value),1) AS avg_Data_Value
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
GROUP BY Topic
ORDER BY avg_Data_Value DESC;

--How does the data value (Data_Value) vary between different questions (QuestionID)?
SELECT QuestionID, Question,
ROUND(AVG(Data_Value),1) AS avg_Data_Value
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data
GROUP BY Question,QuestionID
ORDER BY avg_Data_Value DESC;

--How many unique classes (ClassID) and topics (TopicID) are included in the dataset?
SELECT   
COUNT(DISTINCT ClassID) AS unique_classes,
COUNT(DISTINCT TopicID) AS unique_topics
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data;

--How many unique questions (QuestionID) are included in the dataset?
SELECT   
COUNT(DISTINCT QuestionID) AS unique_questions
FROM dbo.Alzheimer_s_Disease_and_Healthy_Aging_Data;



