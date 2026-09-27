psql -d postgres -c "
SELECT
    COUNT(*) AS total_tickets,
    COUNT(satisfaction_score) AS tickets_with_satisfaction,
    COUNT(resolution_hours) AS tickets_with_resolution,
    COUNT(resolved_at) AS tickets_with_resolved_at
FROM support_tickets;
"


psql -d postgres -c "
SELECT
    (SELECT COUNT(*) FROM accounts) - (SELECT COUNT(DISTINCT account_id) FROM accounts) AS duplicate_accounts,
    (SELECT COUNT(*) FROM users) - (SELECT COUNT(DISTINCT user_id) FROM users) AS duplicate_users,
    (SELECT COUNT(*) FROM subscriptions) - (SELECT COUNT(DISTINCT subscription_id) FROM subscriptions) AS duplicate_subscriptions,
    (SELECT COUNT(*) FROM invoices) - (SELECT COUNT(DISTINCT invoice_id) FROM invoices) AS duplicate_invoices,
    (SELECT COUNT(*) FROM support_tickets) - (SELECT COUNT(DISTINCT ticket_id) FROM support_tickets) AS duplicate_tickets;
"


psql -d postgres -c "
SELECT 'users' AS table_name, COUNT(*) AS invalid_account_ids
FROM users
WHERE account_id NOT IN (SELECT account_id FROM accounts)

UNION ALL

SELECT 'subscriptions', COUNT(*)
FROM subscriptions
WHERE account_id NOT IN (SELECT account_id FROM accounts)

UNION ALL

SELECT 'invoices', COUNT(*)
FROM invoices
WHERE account_id NOT IN (SELECT account_id FROM accounts)

UNION ALL

SELECT 'support_tickets', COUNT(*)
FROM support_tickets
WHERE account_id NOT IN (SELECT account_id FROM accounts);
"


psql -d postgres -c "
SELECT status, COUNT(*) AS invoices
FROM invoices
GROUP BY status
ORDER BY invoices DESC;
"
psql -d postgres -c "
SELECT priority, COUNT(*) AS tickets
FROM support_tickets
GROUP BY priority
ORDER BY tickets DESC;

SELECT category, COUNT(*) AS tickets
FROM support_tickets
GROUP BY category
ORDER BY tickets DESC;
"


psql -d postgres -c "
SELECT
    MIN(mrr) AS minimum_mrr,
    MAX(mrr) AS maximum_mrr,
    COUNT(*) FILTER (WHERE mrr < 0) AS negative_mrr
FROM subscriptions;

SELECT
    MIN(amount) AS minimum_invoice_amount,
    MAX(amount) AS maximum_invoice_amount,
    COUNT(*) FILTER (WHERE amount < 0) AS negative_invoice_amounts
FROM invoices;
"

psql -d postgres -c "
SELECT
    MIN(employee_count) AS min_employees,
    MAX(employee_count) AS max_employees,
    COUNT(*) FILTER (WHERE employee_count <= 0) AS invalid_employee_counts
FROM accounts;

SELECT
    MIN(seats) AS min_seats,
    MAX(seats) AS max_seats,
    COUNT(*) FILTER (WHERE seats <= 0) AS invalid_seats
FROM subscriptions;

SELECT
    MIN(satisfaction_score) AS min_satisfaction,
    MAX(satisfaction_score) AS max_satisfaction,
    COUNT(*) FILTER (WHERE satisfaction_score < 0 OR satisfaction_score > 5) AS invalid_satisfaction
FROM support_tickets;

SELECT
    MIN(resolution_hours) AS min_resolution_hours,
    MAX(resolution_hours) AS max_resolution_hours,
    COUNT(*) FILTER (WHERE resolution_hours < 0) AS negative_resolution_hours
FROM support_tickets;
"

psql -d postgres -c "
SELECT
    COUNT(*) FILTER (WHERE ended_on < started_on) AS invalid_subscription_dates
FROM subscriptions;

SELECT
    COUNT(*) FILTER (WHERE resolved_at < opened_at) AS invalid_ticket_dates
FROM support_tickets;
"
