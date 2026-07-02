
create database Diabetes_DB ;

use Diabetes_DB 

-- Diabetes Risk Analysis & Patient Health Intelligence
-- Table name assumed: diabetes_prediction_dataset

-- 1. View dataset
SELECT TOP 10 *
FROM diabetes_prediction_dataset;

-- 2. Total patients
SELECT COUNT(*) AS Total_Patients
FROM diabetes_prediction_dataset;

--- Total Duplicate Rows 
SELECT
    SUM(Duplicate_Count - 1) AS Total_Duplicate_Rows
FROM
(
    SELECT
        COUNT(*) AS Duplicate_Count
    FROM diabetes_prediction_dataset
    GROUP BY
        gender,
        age,
        hypertension,
        heart_disease,
        smoking_history,
        bmi,
        HbA1c_level,
        blood_glucose_level,
        diabetes
    HAVING COUNT(*) > 1
) AS Duplicates; 

--- create a clean table with distinct rows 
SELECT DISTINCT *
INTO diabetes_prediction_dataset_clean
FROM diabetes_prediction_dataset; 

--- Check row count before and after: 
SELECT COUNT(*) AS Original_Row_Count
FROM diabetes_prediction_dataset;

SELECT COUNT(*) AS Clean_Row_Count
FROM diabetes_prediction_dataset_clean;

--- replace old table 
DROP TABLE diabetes_prediction_dataset;

EXEC sp_rename 
    'diabetes_prediction_dataset_clean',
    'diabetes_prediction_dataset';

--- verify duplicates are gone:
SELECT
    gender,
    age,
    hypertension,
    heart_disease,
    smoking_history,
    bmi,
    HbA1c_level,
    blood_glucose_level,
    diabetes,
    COUNT(*) AS Duplicate_Count
FROM diabetes_prediction_dataset
GROUP BY
    gender,
    age,
    hypertension,
    heart_disease,
    smoking_history,
    bmi,
    HbA1c_level,
    blood_glucose_level,
    diabetes
HAVING COUNT(*) > 1;

-- 3. Diabetes distribution
SELECT
    diabetes,
    COUNT(*) AS Total_Patients,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Percentage
FROM diabetes_prediction_dataset
GROUP BY diabetes;

-- 4. Overall diabetes rate
SELECT
    ROUND(AVG(CAST(diabetes AS FLOAT)) * 100, 2) AS Diabetes_Rate_Percent
FROM diabetes_prediction_dataset;

-- 5. Gender-wise diabetes rate
SELECT
    gender,
    COUNT(*) AS Total_Patients,
    ROUND(AVG(CAST(diabetes AS FLOAT)) * 100, 2) AS Diabetes_Rate_Percent
FROM diabetes_prediction_dataset
GROUP BY gender
ORDER BY Diabetes_Rate_Percent DESC;



-- 7. BMI category diabetes rate
SELECT
    CASE
        WHEN bmi < 18.5 THEN 'Underweight'
        WHEN bmi < 25 THEN 'Healthy'
        WHEN bmi < 30 THEN 'Overweight'
        ELSE 'Obese'
    END AS BMI_Category,
    COUNT(*) AS Total_Patients,
    ROUND(AVG(CAST(diabetes AS FLOAT)) * 100, 2) AS Diabetes_Rate_Percent
FROM diabetes_prediction_dataset
GROUP BY
    CASE
        WHEN bmi < 18.5 THEN 'Underweight'
        WHEN bmi < 25 THEN 'Healthy'
        WHEN bmi < 30 THEN 'Overweight'
        ELSE 'Obese'
    END
ORDER BY Diabetes_Rate_Percent DESC;

-- 8. Hypertension vs diabetes
SELECT
    hypertension,
    COUNT(*) AS Total_Patients,
    ROUND(AVG(CAST(diabetes AS FLOAT)) * 100, 2) AS Diabetes_Rate_Percent
FROM diabetes_prediction_dataset
GROUP BY hypertension
ORDER BY Diabetes_Rate_Percent DESC;

-- 9. Heart disease vs diabetes
SELECT
    heart_disease,
    COUNT(*) AS Total_Patients,
    ROUND(AVG(CAST(diabetes AS FLOAT)) * 100, 2) AS Diabetes_Rate_Percent
FROM diabetes_prediction_dataset
GROUP BY heart_disease
ORDER BY Diabetes_Rate_Percent DESC;

-- 10. Smoking history vs diabetes
SELECT
    smoking_history,
    COUNT(*) AS Total_Patients,
    ROUND(AVG(CAST(diabetes AS FLOAT)) * 100, 2) AS Diabetes_Rate_Percent
FROM diabetes_prediction_dataset
GROUP BY smoking_history
ORDER BY Diabetes_Rate_Percent DESC;

-- 11. Average BMI by diabetes status
SELECT
    diabetes,
    ROUND(AVG(bmi), 2) AS Avg_BMI
FROM diabetes_prediction_dataset
GROUP BY diabetes;

-- 12. Average blood glucose by diabetes status
SELECT
    diabetes,
    ROUND(AVG(blood_glucose_level), 2) AS Avg_Blood_Glucose
FROM diabetes_prediction_dataset
GROUP BY diabetes;

-- 13. Average HbA1c by diabetes status
SELECT
    diabetes,
    ROUND(AVG(HbA1c_level), 2) AS Avg_HbA1c
FROM diabetes_prediction_dataset
GROUP BY diabetes;

-- 14. Blood glucose category analysis
SELECT
    CASE
        WHEN blood_glucose_level < 100 THEN 'Normal'
        WHEN blood_glucose_level < 126 THEN 'Prediabetes'
        WHEN blood_glucose_level < 200 THEN 'High'
        ELSE 'Critical'
    END AS Glucose_Category,
    COUNT(*) AS Total_Patients,
    ROUND(AVG(CAST(diabetes AS FLOAT)) * 100, 2) AS Diabetes_Rate_Percent
FROM diabetes_prediction_dataset
GROUP BY
    CASE
        WHEN blood_glucose_level < 100 THEN 'Normal'
        WHEN blood_glucose_level < 126 THEN 'Prediabetes'
        WHEN blood_glucose_level < 200 THEN 'High'
        ELSE 'Critical'
    END
ORDER BY Diabetes_Rate_Percent DESC;

-- 15. HbA1c category analysis
SELECT
    CASE
        WHEN HbA1c_level < 5.7 THEN 'Normal'
        WHEN HbA1c_level < 6.5 THEN 'Prediabetic'
        ELSE 'Diabetic'
    END AS HbA1c_Category,
    COUNT(*) AS Total_Patients,
    ROUND(AVG(CAST(diabetes AS FLOAT)) * 100, 2) AS Diabetes_Rate_Percent
FROM diabetes_prediction_dataset
GROUP BY
    CASE
        WHEN HbA1c_level < 5.7 THEN 'Normal'
        WHEN HbA1c_level < 6.5 THEN 'Prediabetic'
        ELSE 'Diabetic'
    END
ORDER BY Diabetes_Rate_Percent DESC;

-- 16. High-risk patient flag
SELECT
    COUNT(*) AS High_Risk_Patients
FROM diabetes_prediction_dataset
WHERE age > 45
  AND bmi >= 30
  AND HbA1c_level >= 6.5
  AND blood_glucose_level >= 126;

-- 17. Risk group analysis
SELECT
    CASE
        WHEN
            (
                CASE WHEN age > 45 THEN 20 ELSE 0 END +
                CASE WHEN bmi >= 30 THEN 20 ELSE 0 END +
                CASE WHEN hypertension = 1 THEN 15 ELSE 0 END +
                CASE WHEN heart_disease = 1 THEN 15 ELSE 0 END +
                CASE WHEN HbA1c_level >= 6.5 THEN 15 ELSE 0 END +
                CASE WHEN blood_glucose_level >= 126 THEN 15 ELSE 0 END
            ) <= 25 THEN 'Low Risk'
        WHEN
            (
                CASE WHEN age > 45 THEN 20 ELSE 0 END +
                CASE WHEN bmi >= 30 THEN 20 ELSE 0 END +
                CASE WHEN hypertension = 1 THEN 15 ELSE 0 END +
                CASE WHEN heart_disease = 1 THEN 15 ELSE 0 END +
                CASE WHEN HbA1c_level >= 6.5 THEN 15 ELSE 0 END +
                CASE WHEN blood_glucose_level >= 126 THEN 15 ELSE 0 END
            ) <= 50 THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS Risk_Group,
    COUNT(*) AS Total_Patients,
    ROUND(AVG(CAST(diabetes AS FLOAT)) * 100, 2) AS Diabetes_Rate_Percent
FROM diabetes_prediction_dataset
GROUP BY
    CASE
        WHEN
            (
                CASE WHEN age > 45 THEN 20 ELSE 0 END +
                CASE WHEN bmi >= 30 THEN 20 ELSE 0 END +
                CASE WHEN hypertension = 1 THEN 15 ELSE 0 END +
                CASE WHEN heart_disease = 1 THEN 15 ELSE 0 END +
                CASE WHEN HbA1c_level >= 6.5 THEN 15 ELSE 0 END +
                CASE WHEN blood_glucose_level >= 126 THEN 15 ELSE 0 END
            ) <= 25 THEN 'Low Risk'
        WHEN
            (
                CASE WHEN age > 45 THEN 20 ELSE 0 END +
                CASE WHEN bmi >= 30 THEN 20 ELSE 0 END +
                CASE WHEN hypertension = 1 THEN 15 ELSE 0 END +
                CASE WHEN heart_disease = 1 THEN 15 ELSE 0 END +
                CASE WHEN HbA1c_level >= 6.5 THEN 15 ELSE 0 END +
                CASE WHEN blood_glucose_level >= 126 THEN 15 ELSE 0 END
            ) <= 50 THEN 'Medium Risk'
        ELSE 'High Risk'
    END
ORDER BY Diabetes_Rate_Percent DESC;

-- 18. Top high-risk patients
SELECT TOP 20
    gender,
    age,
    hypertension,
    heart_disease,
    smoking_history,
    bmi,
    HbA1c_level,
    blood_glucose_level,
    diabetes,
    (
        CASE WHEN age > 45 THEN 20 ELSE 0 END +
        CASE WHEN bmi >= 30 THEN 20 ELSE 0 END +
        CASE WHEN hypertension = 1 THEN 15 ELSE 0 END +
        CASE WHEN heart_disease = 1 THEN 15 ELSE 0 END +
        CASE WHEN HbA1c_level >= 6.5 THEN 15 ELSE 0 END +
        CASE WHEN blood_glucose_level >= 126 THEN 15 ELSE 0 END
    ) AS Risk_Score
FROM diabetes_prediction_dataset
ORDER BY Risk_Score DESC; 



