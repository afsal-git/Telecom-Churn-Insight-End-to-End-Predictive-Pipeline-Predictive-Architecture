USE telecom_analytics;

-- 1. Populate Customer Profiles
INSERT INTO customers (state, area_code, account_length, international_plan, voice_mail_plan)
SELECT 
    state, area_code, account_length,
    CASE WHEN international_plan = 'Yes' THEN 1 ELSE 0 END,
    CASE WHEN voice_mail_plan = 'Yes' THEN 1 ELSE 0 END
FROM raw_churn_staging;

-- 2. Populate Facts using direct sequential row generation
SET @row_num = 0;
INSERT INTO customer_usage_fact (customer_id, total_minutes, total_calls, total_charge, service_complaints, churn_status, customer_segment)
SELECT 
    (@row_num:=@row_num + 1) AS customer_id,
    (total_day_minutes + total_eve_minutes + total_night_minutes + total_intl_minutes) AS total_minutes,
    (total_day_calls + total_eve_calls + total_night_calls + total_intl_calls) AS total_calls,
    (total_day_charge + total_eve_charge + total_night_charge + total_intl_charge) AS total_charge,
    customer_service_calls,
    CASE WHEN churn = 'True' THEN 1 ELSE 0 END,
    CASE 
        WHEN customer_service_calls >= 3 OR total_day_minutes > 280 THEN 'At Risk'
        WHEN account_length > 120 AND churn = 'False' THEN 'Loyal'
        ELSE 'Active Standard'
    END AS customer_segment
FROM raw_churn_staging;

USE telecom_analytics;

SELECT * FROM customers LIMIT 10;





