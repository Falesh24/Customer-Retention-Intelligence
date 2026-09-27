COPY accounts(account_id, company_name, industry, country, employee_count, signup_date, plan)
FROM '/Users/falesh/Data Science/Customer Retention Intelligence/saas-subscription-analytics/accounts.csv'
WITH (FORMAT csv, HEADER true);

COPY users(user_id, account_id, full_name, role, email)
FROM '/Users/falesh/Data Science/Customer Retention Intelligence/saas-subscription-analytics/users.csv'
WITH (FORMAT csv, HEADER true);

COPY subscriptions(subscription_id, account_id, seats, status, mrr, started_on, ended_on)
FROM '/Users/falesh/Data Science/Customer Retention Intelligence/saas-subscription-analytics/subscriptions.csv'
WITH (FORMAT csv, HEADER true);

COPY invoices(invoice_id, account_id, invoice_date, amount, status)
FROM '/Users/falesh/Data Science/Customer Retention Intelligence/saas-subscription-analytics/invoices.csv'
WITH (FORMAT csv, HEADER true);

COPY support_tickets(
    ticket_id,
    account_id,
    opened_at,
    priority,
    category,
    satisfaction_score,
    resolution_hours,
    resolved_at
)
FROM '/Users/falesh/Data Science/Customer Retention Intelligence/saas-subscription-analytics/support_tickets.csv'
WITH (FORMAT csv, HEADER true);