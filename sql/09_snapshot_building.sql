CREATE TABLE churn_model_snapshots AS

WITH observation_cutoff AS (
    SELECT
        GREATEST(
            (SELECT MAX(invoice_date) FROM invoices),
            (SELECT MAX(opened_at) FROM support_tickets),
            (SELECT MAX(ended_on) FROM subscriptions)
        ) AS cutoff_date
),

snapshot_dates AS (
    SELECT
        s.account_id,
        gs::timestamp AS snapshot_date,
        s.started_on,
        s.ended_on
    FROM subscriptions s
    CROSS JOIN observation_cutoff o
    CROSS JOIN LATERAL generate_series(
        date_trunc('month', s.started_on + INTERVAL '90 days'),
        date_trunc('month', o.cutoff_date - INTERVAL '90 days'),
        INTERVAL '1 month'
    ) gs
    WHERE
        -- Customer must have existed for at least 90 days
        gs >= s.started_on + INTERVAL '90 days'

        -- Never create a snapshot after churn
        AND (
            s.ended_on IS NULL
            OR gs < s.ended_on
        )
),

features AS (
    SELECT
        sd.account_id,
        sd.snapshot_date,

        -- Static customer attributes
        a.industry,
        a.country,
        a.employee_count,
        a.plan,

        -- Subscription information
        s.seats,
        s.mrr,

        -- User structure
        COUNT(DISTINCT u.user_id) AS user_count,

        COUNT(DISTINCT u.user_id)
            FILTER (WHERE u.role = 'admin') AS admin_count,

        COUNT(DISTINCT u.user_id)
            FILTER (WHERE u.role = 'member') AS member_count,

        COUNT(DISTINCT u.user_id)
            FILTER (WHERE u.role = 'viewer') AS viewer_count,

        -- Previous 90-day invoice behaviour
        COUNT(DISTINCT i.invoice_id) AS invoice_count_90d,

        COALESCE(
            SUM(i.amount),
            0
        ) AS total_invoiced_90d,

        ROUND(
            AVG(i.amount),
            2
        ) AS avg_invoice_amount_90d,

        COALESCE(
            SUM(i.amount) FILTER (WHERE i.status = 'paid'),
            0
        ) AS paid_amount_90d,

        COALESCE(
            SUM(i.amount) FILTER (WHERE i.status = 'open'),
            0
        ) AS open_amount_90d,

        COALESCE(
            SUM(i.amount) FILTER (WHERE i.status = 'uncollectible'),
            0
        ) AS uncollectible_amount_90d,

        -- Previous 90-day support behaviour
        COUNT(DISTINCT t.ticket_id) AS ticket_count_90d,

        COUNT(DISTINCT t.ticket_id)
            FILTER (WHERE t.priority = 'high')
            AS high_priority_tickets_90d,

        COUNT(DISTINCT t.ticket_id)
            FILTER (WHERE t.priority = 'urgent')
            AS urgent_tickets_90d,

        ROUND(
            AVG(t.satisfaction_score),
            2
        ) AS avg_satisfaction_90d,

        ROUND(
            AVG(t.resolution_hours),
            2
        ) AS avg_resolution_hours_90d,

        COUNT(DISTINCT t.ticket_id)
            FILTER (WHERE t.resolved_at IS NULL)
            AS unresolved_tickets_90d,

        -- Future churn label
        CASE
            WHEN sd.ended_on > sd.snapshot_date
             AND sd.ended_on <= sd.snapshot_date + INTERVAL '90 days'
            THEN 1
            ELSE 0
        END AS churn_within_90d

    FROM snapshot_dates sd

    JOIN accounts a
        ON sd.account_id = a.account_id

    JOIN subscriptions s
        ON sd.account_id = s.account_id

    LEFT JOIN users u
        ON sd.account_id = u.account_id

    LEFT JOIN invoices i
        ON sd.account_id = i.account_id
        AND i.invoice_date <= sd.snapshot_date
        AND i.invoice_date > sd.snapshot_date - INTERVAL '90 days'

    LEFT JOIN support_tickets t
        ON sd.account_id = t.account_id
        AND t.opened_at <= sd.snapshot_date
        AND t.opened_at > sd.snapshot_date - INTERVAL '90 days'

    GROUP BY
        sd.account_id,
        sd.snapshot_date,
        sd.ended_on,
        a.industry,
        a.country,
        a.employee_count,
        a.plan,
        s.seats,
        s.mrr
)

SELECT *
FROM features
ORDER BY account_id, snapshot_date;

SELECT COUNT(*) AS total_snapshots
FROM churn_model_snapshots;

SELECT
    churn_within_90d,
    COUNT(*) AS snapshots
FROM churn_model_snapshots
GROUP BY churn_within_90d
ORDER BY churn_within_90d;

SELECT
    COUNT(DISTINCT account_id) AS unique_customers,
    COUNT(*) AS total_snapshots,
    COUNT(*) FILTER (WHERE churn_within_90d = 1) AS positive_snapshots
FROM churn_model_snapshots;

SELECT
    MIN(snapshot_date) AS first_snapshot,
    MAX(snapshot_date) AS last_snapshot,
    COUNT(DISTINCT snapshot_date) AS snapshot_dates
FROM churn_model_snapshots;

DROP TABLE IF EXISTS churn_train;
DROP TABLE IF EXISTS churn_test;

CREATE TABLE churn_train AS
SELECT *
FROM churn_model_snapshots
WHERE snapshot_date < (
    SELECT percentile_disc(0.80)
    WITHIN GROUP (ORDER BY snapshot_date)
    FROM churn_model_snapshots
);

CREATE TABLE churn_test AS
SELECT *
FROM churn_model_snapshots
WHERE snapshot_date >= (
    SELECT percentile_disc(0.80)
    WITHIN GROUP (ORDER BY snapshot_date)
    FROM churn_model_snapshots
);
SELECT
    'train' AS dataset,
    COUNT(*) AS snapshots,
    COUNT(DISTINCT account_id) AS customers,
    SUM(churn_within_90d) AS positive
FROM churn_train

UNION ALL

SELECT
    'test',
    COUNT(*),
    COUNT(DISTINCT account_id),
    SUM(churn_within_90d)
FROM churn_test;

SELECT
    COUNT(DISTINCT t.account_id) AS test_customers_seen_in_train
FROM churn_test t
JOIN churn_train tr
    ON t.account_id = tr.account_id;

SELECT
    COUNT(*) AS positive_snapshots,
    COUNT(DISTINCT account_id) AS customers_with_positive_snapshots,
    MAX(snapshot_count) AS max_positive_snapshots_per_customer
FROM (
    SELECT
        account_id,
        COUNT(*) AS snapshot_count
    FROM churn_model_snapshots
    WHERE churn_within_90d = 1
    GROUP BY account_id
) x;