psql -d postgres -c "
SELECT
    account_id,
    company_name,
    industry,
    country,
    employee_count,
    signup_date,
    plan
FROM accounts
LIMIT 10;
"

psql -d postgres -c "
SELECT
    account_id,
    COUNT(*) AS user_count
FROM users
GROUP BY account_id
ORDER BY user_count DESC
LIMIT 10;
"

psql -d postgres -c "
SELECT
    COUNT(DISTINCT account_id) AS accounts_with_users,
    COUNT(*) AS total_users
FROM users;
"

psql -d postgres -c "
SELECT
    account_id,
    role,
    COUNT(*) AS user_count
FROM users
GROUP BY account_id, role
ORDER BY account_id, role
LIMIT 20;
"

psql -d postgres -c "
SELECT
    account_id,
    COUNT(*) FILTER (WHERE role = 'admin') AS admin_count,
    COUNT(*) FILTER (WHERE role = 'member') AS member_count,
    COUNT(*) FILTER (WHERE role = 'viewer') AS viewer_count
FROM users
GROUP BY account_id
ORDER BY account_id
LIMIT 10;
"

psql -d postgres -c "
SELECT
    account_id,
    COUNT(*) AS user_count,
    COUNT(*) FILTER (WHERE role = 'admin')
      + COUNT(*) FILTER (WHERE role = 'member')
      + COUNT(*) FILTER (WHERE role = 'viewer') AS role_total
FROM users
GROUP BY account_id
HAVING COUNT(*) <>
       COUNT(*) FILTER (WHERE role = 'admin')
       + COUNT(*) FILTER (WHERE role = 'member')
       + COUNT(*) FILTER (WHERE role = 'viewer');
"

psql -d postgres -c "
SELECT
    status,
    COUNT(*) AS subscription_count
FROM subscriptions
GROUP BY status
ORDER BY subscription_count DESC;
"

psql -d postgres -c "
SELECT
    account_id,
    mrr
FROM subscriptions
ORDER BY mrr DESC
LIMIT 10;
"

psql -d postgres -c "
SELECT
    account_id,
    seats,
    status,
    mrr,
    started_on,
    ended_on
FROM subscriptions
LIMIT 10;
"

psql -d postgres -c "
SELECT
    s.account_id,
    COUNT(u.user_id) AS user_count,
    s.seats,
    ROUND(COUNT(u.user_id)::NUMERIC / NULLIF(s.seats, 0), 2) AS users_per_seat
FROM subscriptions s
JOIN users u
    ON s.account_id = u.account_id
GROUP BY
    s.account_id,
    s.seats
ORDER BY users_per_seat DESC
LIMIT 10;
"

psql -d postgres -c "
SELECT
    COUNT(*) AS accounts,
    MIN(users_per_seat) AS min_users_per_seat,
    MAX(users_per_seat) AS max_users_per_seat,
    ROUND(AVG(users_per_seat), 2) AS avg_users_per_seat
FROM (
    SELECT
        s.account_id,
        COUNT(u.user_id)::NUMERIC / NULLIF(s.seats, 0) AS users_per_seat
    FROM subscriptions s
    JOIN users u
        ON s.account_id = u.account_id
    GROUP BY s.account_id, s.seats
) x;
"
psql -d postgres -c "
SELECT
    account_id,
    started_on,
    ended_on,
    ended_on - started_on AS subscription_duration
FROM subscriptions
WHERE ended_on IS NOT NULL
LIMIT 10;
"

psql -d postgres -c "
SELECT
    ROUND(
        AVG(EXTRACT(EPOCH FROM (ended_on - started_on)) / 86400),
        2
    ) AS avg_subscription_days
FROM subscriptions
WHERE ended_on IS NOT NULL;
"

psql -d postgres -c "
SELECT
    account_id,
    COUNT(*) AS invoice_count
FROM invoices
GROUP BY account_id
ORDER BY invoice_count DESC
LIMIT 10;
"

psql -d postgres -c "
SELECT
    COUNT(DISTINCT account_id) AS accounts_with_invoices,
    COUNT(*) AS total_invoices
FROM invoices;
"

psql -d postgres -c "
SELECT
    account_id,
    SUM(amount) AS total_invoiced
FROM invoices
GROUP BY account_id
ORDER BY total_invoiced DESC
LIMIT 10;
"

psql -d postgres -c "
SELECT
    account_id,
    ROUND(AVG(amount), 2) AS avg_invoice_amount
FROM invoices
GROUP BY account_id
ORDER BY avg_invoice_amount DESC
LIMIT 10;
"

psql -d postgres -c "
SELECT
    status,
    COUNT(*) AS invoice_count,
    SUM(amount) AS total_amount
FROM invoices
GROUP BY status
ORDER BY total_amount DESC;
"

psql -d postgres -c "
SELECT
    account_id,
    SUM(amount) FILTER (WHERE status = 'paid') AS paid_amount
FROM invoices
GROUP BY account_id
ORDER BY paid_amount DESC
LIMIT 10;
"

psql -d postgres -c "
SELECT
    account_id,
    COALESCE(
        SUM(amount) FILTER (WHERE status = 'open'),
        0
    ) AS open_amount
FROM invoices
GROUP BY account_id
ORDER BY open_amount DESC
LIMIT 10;
"

psql -d postgres -c "
SELECT
    account_id,
    COALESCE(
        SUM(amount) FILTER (WHERE status = 'uncollectible'),
        0
    ) AS uncollectible_amount
FROM invoices
GROUP BY account_id
ORDER BY uncollectible_amount DESC
LIMIT 10;
"

psql -d postgres -c "
SELECT
    account_id,
    COUNT(*) AS ticket_count
FROM support_tickets
GROUP BY account_id
ORDER BY ticket_count DESC
LIMIT 10;
"

psql -d postgres -c "
SELECT
    account_id,
    COUNT(*) FILTER (WHERE priority = 'high') AS high_priority_tickets,
    COUNT(*) FILTER (WHERE priority = 'urgent') AS urgent_tickets
FROM support_tickets
GROUP BY account_id
ORDER BY urgent_tickets DESC, high_priority_tickets DESC
LIMIT 10;
"

psql -d postgres -c "
SELECT
    account_id,
    ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction
FROM support_tickets
WHERE satisfaction_score IS NOT NULL
GROUP BY account_id
ORDER BY avg_satisfaction
LIMIT 10;
"

psql -d postgres -c "
SELECT
    account_id,
    ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours
FROM support_tickets
WHERE resolution_hours IS NOT NULL
GROUP BY account_id
ORDER BY avg_resolution_hours DESC
LIMIT 10;
"

psql -d postgres -c "
SELECT
    account_id,

    COUNT(*) AS ticket_count,

    COUNT(*) FILTER (
        WHERE priority = 'high'
    ) AS high_priority_tickets,

    COUNT(*) FILTER (
        WHERE priority = 'urgent'
    ) AS urgent_tickets,

    ROUND(
        AVG(satisfaction_score),
        2
    ) AS avg_satisfaction,

    ROUND(
        AVG(resolution_hours),
        2
    ) AS avg_resolution_hours,

    COUNT(*) FILTER (
        WHERE resolved_at IS NULL
    ) AS unresolved_tickets

FROM support_tickets

GROUP BY account_id

ORDER BY ticket_count DESC
LIMIT 10;
"

psql -d postgres -c "
SELECT
    COUNT(DISTINCT account_id) AS accounts_with_support_data
FROM support_tickets;
"

--  aggregating 

psql -d postgres -c "
CREATE TABLE customer_360 AS
WITH user_metrics AS (
    SELECT
        account_id,
        COUNT(*) AS user_count,
        COUNT(*) FILTER (WHERE role = 'admin') AS admin_count,
        COUNT(*) FILTER (WHERE role = 'member') AS member_count,
        COUNT(*) FILTER (WHERE role = 'viewer') AS viewer_count
    FROM users
    GROUP BY account_id
),
invoice_metrics AS (
    SELECT
        account_id,
        COUNT(*) AS invoice_count,
        SUM(amount) AS total_invoiced,
        ROUND(AVG(amount), 2) AS avg_invoice_amount,
        COALESCE(SUM(amount) FILTER (WHERE status = 'paid'), 0) AS paid_amount,
        COALESCE(SUM(amount) FILTER (WHERE status = 'open'), 0) AS open_amount,
        COALESCE(SUM(amount) FILTER (WHERE status = 'uncollectible'), 0) AS uncollectible_amount
    FROM invoices
    GROUP BY account_id
),
support_metrics AS (
    SELECT
        account_id,
        COUNT(*) AS ticket_count,
        COUNT(*) FILTER (WHERE priority = 'high') AS high_priority_tickets,
        COUNT(*) FILTER (WHERE priority = 'urgent') AS urgent_tickets,
        ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction,
        ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours,
        COUNT(*) FILTER (WHERE resolved_at IS NULL) AS unresolved_tickets
    FROM support_tickets
    GROUP BY account_id
)
SELECT
    a.account_id,
    a.company_name,
    a.industry,
    a.country,
    a.employee_count,
    a.signup_date,
    a.plan,

    u.user_count,
    u.admin_count,
    u.member_count,
    u.viewer_count,

    s.seats,
    s.status AS subscription_status,
    s.mrr,
    s.started_on,
    s.ended_on,

    ROUND(
        u.user_count::NUMERIC / NULLIF(s.seats, 0),
        2
    ) AS users_per_seat,

    CASE
        WHEN s.ended_on IS NOT NULL
        THEN ROUND(
            EXTRACT(EPOCH FROM (s.ended_on - s.started_on)) / 86400,
            2
        )
    END AS subscription_duration,

    i.invoice_count,
    i.total_invoiced,
    i.avg_invoice_amount,
    i.paid_amount,
    i.open_amount,
    i.uncollectible_amount,

    sm.ticket_count,
    sm.high_priority_tickets,
    sm.urgent_tickets,
    sm.avg_satisfaction,
    sm.avg_resolution_hours,
    sm.unresolved_tickets

FROM accounts a
LEFT JOIN user_metrics u
    ON a.account_id = u.account_id
LEFT JOIN subscriptions s
    ON a.account_id = s.account_id
LEFT JOIN invoice_metrics i
    ON a.account_id = i.account_id
LEFT JOIN support_metrics sm
    ON a.account_id = sm.account_id;
"

-- final check 
psql -d postgres -c "
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT account_id) AS unique_accounts
FROM customer_360;
"