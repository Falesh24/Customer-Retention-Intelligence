SELECT
    COUNT(*) AS churned_customers,
    COUNT(*) FILTER (
        WHERE ended_on - started_on >= INTERVAL '90 days'
    ) AS churned_with_90d_history,
    COUNT(*) FILTER (
        WHERE ended_on - started_on >= INTERVAL '180 days'
    ) AS churned_with_180d_history
FROM subscriptions
WHERE status = 'churned';

SELECT
    COUNT(DISTINCT account_id) AS accounts_with_invoices,
    MIN(invoice_date) AS first_invoice,
    MAX(invoice_date) AS last_invoice
FROM invoices;


SELECT
    COUNT(DISTINCT account_id) AS accounts_with_tickets,
    MIN(opened_at) AS first_ticket,
    MAX(opened_at) AS last_ticket
FROM support_tickets;

