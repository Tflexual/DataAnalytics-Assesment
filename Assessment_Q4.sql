-- Calculate Customer Lifetime Value (CLV) for each customer

-- Step 1: Generate metrics per customer
WITH CustomerMetrics AS (
    SELECT 
        u.id AS customer_id,
        -- Combine first and last name for better display
        CONCAT(u.first_name, ' ', u.last_name) AS name,

        -- Calculate how long the customer has been active (in months)
        TIMESTAMPDIFF(MONTH, u.date_joined, '2025-05-17') AS tenure_months,

        -- Count total number of savings transactions
        COUNT(s.id) AS total_transactions,

        -- Estimate average profit per transaction (scaled down using assumed 0.001 profit rate)
        -- Divide confirmed_amount by 100 to convert from kobo to naira (assuming NGN minor units)
        -- COALESCE handles nulls by defaulting to 0
        COALESCE(AVG(s.confirmed_amount / 100.0) * 0.001, 0) AS avg_profit_per_transaction

    FROM 
        users_customuser u

    -- Join with savings transactions to gather relevant financial data
    LEFT JOIN 
        savings_savingsaccount s ON u.id = s.owner_id

    -- Group by user ID and joining date to ensure accurate aggregation
    GROUP BY 
        u.id, u.name, u.date_joined
)

-- Step 2: Calculate estimated CLV per customer
SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,

    -- CLV formula: (transactions/month) * 12 months * average profit per transaction
    -- If tenure = 0 months, return 0 to avoid division by zero
    ROUND(
        IF(tenure_months = 0, 
           0, 
           (total_transactions / tenure_months) * 12 * avg_profit_per_transaction),
        2 -- Round to 2 decimal places
    ) AS estimated_clv

FROM 
    CustomerMetrics

-- Show highest value customers first
ORDER BY 
    estimated_clv DESC;
