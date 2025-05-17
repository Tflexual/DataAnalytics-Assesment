-- Calculate transaction frequency per customer

WITH TransactionStats AS (
    SELECT 
        u.id,

        -- Count total savings transactions for each user
        COUNT(s.id) AS total_transactions,

        -- Calculate active months: difference between the first and last transaction month + 1
        TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)) + 1 AS active_months,

        -- Calculate average transactions per month
        -- If all transactions are in the same month (zero-month difference), just return the count
        -- Else, divide total transactions by number of months
        CASE 
            WHEN TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)) = 0 
            THEN COUNT(s.id) 
            ELSE COUNT(s.id) * 1.0 / (TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)) + 1) 
        END AS avg_transactions_per_month

    FROM 
        users_customuser u

    -- Join savings transactions by user
    LEFT JOIN 
        savings_savingsaccount s ON u.id = s.owner_id

    -- Group by user ID to calculate metrics per user
    GROUP BY 
        u.id
),

-- Categorize customers based on average monthly transaction frequency
FrequencyCategories AS (
    SELECT 

        -- Use CASE to classify into frequency bands
        CASE 
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,

        -- Count how many users fall into each frequency category
        COUNT(*) AS customer_count,

        -- Calculate average transaction frequency in each category (rounded to 1 decimal)
        ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month

    FROM 
        TransactionStats

    -- Group by category to get counts and average values
    GROUP BY 
        frequency_category
)

-- Final output: show category, customer count, and average transactions
SELECT 
    frequency_category,
    customer_count,
    avg_transactions_per_month
FROM 
    FrequencyCategories

-- Show categories in descending order of activity
ORDER BY 
    avg_transactions_per_month DESC;
