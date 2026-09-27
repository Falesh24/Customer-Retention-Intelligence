-- Churn Baseline
psql -d postgres -c "
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE subscription_status = 'churned') AS churned_customers,
    COUNT(*) FILTER (WHERE subscription_status = 'active') AS active_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE subscription_status = 'churned')
        / COUNT(*),
        2
    ) AS churn_rate
FROM customer_360;
"

-- Churn by Plan 
psql -d postgres -c "
SELECT
    plan,
    COUNT(*) AS customers,
    COUNT(*) FILTER (
        WHERE subscription_status = 'churned'
    ) AS churned_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE subscription_status = 'churned'
        ) / COUNT(*),
        2
    ) AS churn_rate
FROM customer_360
GROUP BY plan
ORDER BY churn_rate DESC;
"

-- Churn by company size 
psql -d postgres -c "
SELECT
    subscription_status,
    COUNT(*) AS customers,
    ROUND(AVG(employee_count), 2) AS avg_employees,
    MIN(employee_count) AS min_employees,
    MAX(employee_count) AS max_employees
FROM customer_360
GROUP BY subscription_status
ORDER BY subscription_status;
"

-- Churn by industry 
psql -d postgres -c "
SELECT
    industry,
    COUNT(*) AS customers,
    COUNT(*) FILTER (
        WHERE subscription_status = 'churned'
    ) AS churned_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE subscription_status = 'churned'
        ) / COUNT(*),
        2
    ) AS churn_rate
FROM customer_360
GROUP BY industry
ORDER BY churn_rate DESC;
"

-- Churned by Country
psql -d postgres -c "
SELECT
    country,
    COUNT(*) AS customers,
    COUNT(*) FILTER (
        WHERE subscription_status = 'churned'
    ) AS churned_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE subscription_status = 'churned'
        ) / COUNT(*),
        2
    ) AS churn_rate
FROM customer_360
GROUP BY country
ORDER BY churn_rate DESC;
"

-- Product engagement
psql -d postgres -c "
SELECT
    subscription_status,
    COUNT(*) AS customers,
    ROUND(AVG(user_count), 2) AS avg_users,
    ROUND(AVG(users_per_seat), 2) AS avg_users_per_seat
FROM customer_360
WHERE subscription_status IN ('active', 'churned')
GROUP BY subscription_status
ORDER BY subscription_status;
"

-- a Revenue & subscription behaviour
psql -d postgres -c "
SELECT
    subscription_status,
    COUNT(*) AS customers,
    ROUND(AVG(mrr), 2) AS avg_mrr,
    ROUND(AVG(seats), 2) AS avg_seats,
    ROUND(AVG(subscription_duration), 2) AS avg_subscription_days,
    ROUND(AVG(total_invoiced), 2) AS avg_total_invoiced
FROM customer_360
WHERE subscription_status IN ('active', 'churned')
GROUP BY subscription_status
ORDER BY subscription_status;
"

-- Support Behaviour
psql -d postgres -c "
SELECT
    subscription_status,
    COUNT(*) AS customers,
    ROUND(AVG(ticket_count), 2) AS avg_tickets,
    ROUND(AVG(high_priority_tickets), 2) AS avg_high_priority,
    ROUND(AVG(urgent_tickets), 2) AS avg_urgent,
    ROUND(AVG(avg_satisfaction), 2) AS avg_satisfaction,
    ROUND(AVG(avg_resolution_hours), 2) AS avg_resolution_hours,
    ROUND(AVG(unresolved_tickets), 2) AS avg_unresolved
FROM customer_360
WHERE subscription_status IN ('active', 'churned')
GROUP BY subscription_status
ORDER BY subscription_status;
"
-- User-count churn bands
psql -d postgres -c "
SELECT
    CASE
        WHEN user_count <= 10 THEN '0-10'
        WHEN user_count <= 25 THEN '11-25'
        WHEN user_count <= 50 THEN '26-50'
        ELSE '51+'
    END AS user_band,
    COUNT(*) AS customers,
    COUNT(*) FILTER (
        WHERE subscription_status = 'churned'
    ) AS churned_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE subscription_status = 'churned'
        ) / COUNT(*),
        2
    ) AS churn_rate
FROM customer_360
GROUP BY user_band
ORDER BY
    CASE user_band
        WHEN '0-10' THEN 1
        WHEN '11-25' THEN 2
        WHEN '26-50' THEN 3
        WHEN '51+' THEN 4
    END;
"


psql -d postgres -c "
SELECT
    CASE
        WHEN mrr <= 300 THEN '0-300'
        WHEN mrr <= 750 THEN '301-750'
        WHEN mrr <= 1500 THEN '751-1500'
        ELSE '1501+'
    END AS mrr_band,
    COUNT(*) AS customers,
    COUNT(*) FILTER (
        WHERE subscription_status = 'churned'
    ) AS churned_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE subscription_status = 'churned'
        ) / COUNT(*),
        2
    ) AS churn_rate
FROM customer_360
GROUP BY
    CASE
        WHEN mrr <= 300 THEN '0-300'
        WHEN mrr <= 750 THEN '301-750'
        WHEN mrr <= 1500 THEN '751-1500'
        ELSE '1501+'
    END
ORDER BY MIN(mrr);
"

-- Seats
psql -d postgres -c "
SELECT
    CASE
        WHEN seats <= 10 THEN '1-10'
        WHEN seats <= 25 THEN '11-25'
        WHEN seats <= 50 THEN '26-50'
        ELSE '51+'
    END AS seat_band,
    COUNT(*) AS customers,
    COUNT(*) FILTER (
        WHERE subscription_status = 'churned'
    ) AS churned_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE subscription_status = 'churned'
        ) / COUNT(*),
        2
    ) AS churn_rate
FROM customer_360
GROUP BY
    CASE
        WHEN seats <= 10 THEN '1-10'
        WHEN seats <= 25 THEN '11-25'
        WHEN seats <= 50 THEN '26-50'
        ELSE '51+'
    END
ORDER BY MIN(seats);
"
-- Total invoiced
psql -d postgres -c "
SELECT
    CASE
        WHEN total_invoiced <= 3000 THEN '0-3000'
        WHEN total_invoiced <= 7500 THEN '3001-7500'
        WHEN total_invoiced <= 15000 THEN '7501-15000'
        ELSE '15001+'
    END AS invoiced_band,
    COUNT(*) AS customers,
    COUNT(*) FILTER (
        WHERE subscription_status = 'churned'
    ) AS churned_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE subscription_status = 'churned'
        ) / COUNT(*),
        2
    ) AS churn_rate
FROM customer_360
GROUP BY
    CASE
        WHEN total_invoiced <= 3000 THEN '0-3000'
        WHEN total_invoiced <= 7500 THEN '3001-7500'
        WHEN total_invoiced <= 15000 THEN '7501-15000'
        ELSE '15001+'
    END
ORDER BY MIN(total_invoiced);
"

