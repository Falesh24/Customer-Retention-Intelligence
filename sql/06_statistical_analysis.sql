-- the contingency table
psql -d postgres -c "
SELECT
    plan,
    COUNT(*) AS customers,
    COUNT(*) FILTER (
        WHERE subscription_status = 'churned'
    ) AS churned_customers,
    COUNT(*) FILTER (
        WHERE subscription_status <> 'churned'
    ) AS not_churned_customers
FROM customer_360
GROUP BY plan
ORDER BY plan;
"

-- Industry → Churn
psql -d postgres -c "
SELECT
    industry,
    COUNT(*) AS customers,
    COUNT(*) FILTER (
        WHERE subscription_status = 'churned'
    ) AS churned_customers,
    COUNT(*) FILTER (
        WHERE subscription_status <> 'churned'
    ) AS not_churned_customers
FROM customer_360
GROUP BY industry
ORDER BY industry;
"

--  country count 

psql -d postgres -c "
SELECT
    country,
    COUNT(*) AS customers,
    COUNT(*) FILTER (
        WHERE subscription_status = 'churned'
    ) AS churned_customers,
    COUNT(*) FILTER (
        WHERE subscription_status <> 'churned'
    ) AS not_churned_customers
FROM customer_360
GROUP BY country
ORDER BY country;
"

-- 