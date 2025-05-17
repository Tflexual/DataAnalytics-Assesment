-- Find accounts with no savings transactions in the last 365 days

-- Step 1: Determine the last transaction date per plan
WITH LastTransaction AS (
    SELECT 
        plan_id,
        MAX(transaction_date) AS last_transaction_date  -- Get the most recent transaction per plan
    FROM 
        savings_savingsaccount
    GROUP BY 
        plan_id
),

-- Step 2: Identify inactive plans and compute inactivity duration
Inactivity AS (
    SELECT 
        p.id AS plan_id,
        p.owner_id,

        -- Categorize each plan by type
        CASE 
            WHEN p.is_regular_savings = 1 THEN 'Savings'
            WHEN p.is_a_fund = 1 THEN 'Investment'
            ELSE 'Other'
        END AS type,

        lt.last_transaction_date,

        -- Calculate how many days have passed since the last transaction
        TIMESTAMPDIFF(DAY, lt.last_transaction_date, CURDATE()) AS inactivity_days

    FROM 
        plans_plan p

    -- Join with the last transaction date per plan (may be NULL if no transactions)
    LEFT JOIN 
        LastTransaction lt ON p.id = lt.plan_id

    -- Filter to include only savings and investment plans
    WHERE 
        p.is_regular_savings = 1 OR p.is_a_fund = 1
)

-- Step 3: Select plans that are inactive (no transactions or >365 days old)
SELECT 
    plan_id,
    owner_id,
    type,

    -- Format last_transaction_date to show only the date (exclude time)
    DATE(last_transaction_date) AS last_transaction_date,

    inactivity_days
FROM 
    Inactivity
WHERE 
    last_transaction_date IS NULL   -- Include plans with no transaction history
    OR inactivity_days > 365        -- Include plans with transactions older than 365 days
ORDER BY 
    inactivity_days DESC;           -- Sort by longest inactivity first
