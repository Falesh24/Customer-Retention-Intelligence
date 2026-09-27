CREATE TABLE accounts (
    account_id INTEGER PRIMARY KEY,
    company_name TEXT,
    industry TEXT,
    country TEXT,
    employee_count INTEGER,
    signup_date TIMESTAMP,
    plan TEXT
);

CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    account_id INTEGER REFERENCES accounts(account_id),
    full_name TEXT,
    role TEXT,
    email TEXT
);

CREATE TABLE subscriptions (
    subscription_id INTEGER PRIMARY KEY,
    account_id INTEGER REFERENCES accounts(account_id),
    seats INTEGER,
    status TEXT,
    mrr NUMERIC,
    started_on TIMESTAMP,
    ended_on TIMESTAMP
);

CREATE TABLE invoices (
    invoice_id INTEGER PRIMARY KEY,
    account_id INTEGER REFERENCES accounts(account_id),
    invoice_date TIMESTAMP,
    amount NUMERIC,
    status TEXT
);

CREATE TABLE support_tickets (
    ticket_id INTEGER PRIMARY KEY,
    account_id INTEGER REFERENCES accounts(account_id),
    opened_at TIMESTAMP,
    priority TEXT,
    category TEXT,
    satisfaction_score NUMERIC,
    resolution_hours NUMERIC,
    resolved_at TIMESTAMP
);

SELECT 'accounts' AS table_name, COUNT(*) AS row_count FROM accounts
UNION ALL
SELECT 'users', COUNT(*) FROM users
UNION ALL
SELECT 'subscriptions', COUNT(*) FROM subscriptions
UNION ALL
SELECT 'invoices', COUNT(*) FROM invoices
UNION ALL
SELECT 'support_tickets', COUNT(*) FROM support_tickets;