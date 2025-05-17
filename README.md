# DataAnalytics-Assessment

This repository contains solutions to the SQL Proficiency Assessment, addressing the four business problems using optimized MySQL queries. Each query is designed to be accurate, efficient, readable, and complete according to the evaluation criteria.

---

## Repository Structure

DataAnalytics-Assessment/
│
├── Assessment_Q1.sql
├── Assessment_Q2.sql
├── Assessment_Q3.sql
├── Assessment_Q4.sql
│
└── README.md


---

## Per-Question Explanations

### Question 1: High-Value Customers with Multiple Products

**Objective:**  
Identify customers with both funded savings and investment plans, sorted by total deposits.

**Approach:**  
- Joined `users_customuser`, `plans_plan`, and `savings_savingsaccount` to access customer and transaction data.  
- Used conditional aggregation to count savings (`is_regular_savings = 1`) and investment (`is_a_fund = 1`) plans.  
- Summed `confirmed_amount` (converted from kobo to NGN) for total deposits.  
- Filtered for customers with at least one of each plan type using `HAVING`.  
- Sorted by total deposits descending for prioritization.  

**Key Considerations:**  
- Ensured only funded plans (`confirmed_amount > 0`) are counted.  
- Handled potential nulls with `COALESCE`.  
- Concatenated first and last name into a full name

---

### Question 2: Transaction Frequency Analysis

**Objective:**  
Categorize customers by average transactions per month.

**Approach:**  
- Calculated active months per customer using `TIMESTAMPDIFF(MONTH, ...)` between first and last transaction.  
- Computed average transactions per month, handling single-month cases.  
- Categorized into High (≥10), Medium (3-9), and Low (≤2) frequency using `CASE`.  
- Aggregated by category to show customer count and average transactions.  

**Key Considerations:**  
- Added 1 to `TIMESTAMPDIFF` to avoid division by zero for single-month users.  
- Rounded averages for readability.  

---

### Question 3: Account Inactivity Alert

**Objective:**  
Flag accounts with no transactions in the last 365 days.

**Approach:**  
- Combined `savings_savingsaccount` and `withdrawals_withdrawal` to find the last transaction date per plan.  
- Joined with `plans_plan` to get plan type and owner.  
- Calculated inactivity days using `TIMESTAMPDIFF(DAY, ...)` from last transaction till present.  
- Filtered for inactivity > 365 days or no transactions.  
- Filtered the last_transaction_date to show only the date (exclude time)

**Key Considerations:**  
- Used `UNION` to merge transaction types.  
- Handled null transaction dates for completely inactive plans.  

---

### Question 4: Customer Lifetime Value (CLV) Estimation

**Objective:**  
Estimate CLV based on tenure, transaction count, and profit per transaction.

**Approach:**  
- Calculated tenure (months) from `date_joined` to present, using `TIMESTAMPDIFF(MONTH, ...)`.  
- Counted transactions and computed average profit (0.1% of `confirmed_amount` in NGN).  
- Computed CLV as `(total_transactions / tenure) * 12 * avg_profit_per_transaction`.  
- Ordered by CLV descending.  

**Key Considerations:**  
- Handled zero tenure with a `CASE` statement to avoid division errors.  
- Converted amounts from kobo to NGN for profit calculation.  

---

## Challenges and Resolutions

| Challenge                          | Resolution                                                                                  |

| MySQL Syntax Limitation           | Used `TIMESTAMPDIFF` instead of unsupported `DATEDIFF(MONTH, ...)` functions.              |
| Kobo to NGN Conversion            | Consistently divided amounts by 100 to convert kobo to NGN (e.g., `confirmed_amount / 100`).|
| Edge Cases                       | Handled zero tenure and single-month activity to avoid division by zero.                   |
| No Transactions                  | Included plans with null transaction dates in inactivity check.                            |
| Performance                     | Added early filtering and checked query execution plans to optimize for large datasets.    |

---

## Notes

- Queries are properly formatted with clear indentation
- Queries Include comments for complex sections
- All date calculations reference **May 17, 2025** as the current date for consistency.  
- Monetary values are converted from kobo (smallest currency unit) to Nigerian Naira (NGN) for clarity.  
 



