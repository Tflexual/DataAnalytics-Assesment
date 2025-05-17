-- Identify customers who have both savings and investment plans
SELECT 
    u.id AS owner_id,

    -- Concatenate first and last name into a full name
    CONCAT(u.first_name, ' ', u.last_name) AS name,

    -- Count distinct savings plans for each user (is_regular_savings = 1)
    COUNT(DISTINCT CASE 
        WHEN p.is_regular_savings = 1 THEN p.id 
    END) AS savings_count,

    -- Count distinct investment plans for each user (is_a_fund = 1)
    COUNT(DISTINCT CASE 
        WHEN p.is_a_fund = 1 THEN p.id 
    END) AS investment_count,

    -- Sum all confirmed deposit amounts (stored in kobo, so divide by 100)
    -- COALESCE prevents NULL when there's no deposit
    -- Roundup the decimal numbers to 2
    ROUND(COALESCE(SUM(s.confirmed_amount) / 100.0, 0), 2) AS total_deposits
FROM 
    users_customuser u

-- Join the plans table to get access to each user's plans
LEFT JOIN 
    plans_plan p ON u.id = p.owner_id

-- Join the savings table to get confirmed deposit amounts per plan
LEFT JOIN 
    savings_savingsaccount s ON p.id = s.plan_id

-- Group by user to aggregate per customer
GROUP BY 
    u.id, u.first_name, u.last_name

-- Filter users who have BOTH at least one savings AND one investment plan
HAVING 
    COUNT(DISTINCT CASE 
        WHEN p.is_regular_savings = 1 THEN p.id 
    END) > 0
    AND 
    COUNT(DISTINCT CASE 
        WHEN p.is_a_fund = 1 THEN p.id 
    END) > 0

-- Order result by total deposits in descending order (highest to lowest)
ORDER BY 
    total_deposits DESC;
