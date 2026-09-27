SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'customer_360'
ORDER BY ordinal_position;


SELECT
    MIN(invoice_date) AS first_invoice,
    MAX(invoice_date) AS last_invoice
FROM invoices;

SELECT
    MIN(started_on) AS first_subscription,
    MAX(started_on) AS last_subscription,
    MIN(ended_on) AS first_churn,
    MAX(ended_on) AS last_churn
FROM subscriptions
WHERE status = 'churned';

ELECT
    MIN(opened_at) AS first_ticket,
    MAX(opened_at) AS last_ticket
FROM support_tickets;