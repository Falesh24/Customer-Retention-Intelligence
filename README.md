# Customer Retention Intelligence

An end-to-end SaaS customer analytics and retention decision-support project.

The project analyses customer behaviour, subscriptions, revenue and support activity to understand churn patterns and translate them into actionable retention insights.

## 📊 ML Feasibility Analysis & Strategic Pivot

During the development lifecycle, machine learning feasibility was rigorously tested using Logistic Regression and Random Forest classifiers. However, the production deployment of an ML model was **strategically rejected** due to specific data limitations that threatened business metrics.

### 📉 Experimental Metrics & Evaluation
The dataset presents a highly realistic but challenging **7.17% baseline churn rate** (severe class imbalance) across 1,200 total records. 

| Model Variant | Precision | Recall (Sensitivity) | ROC-AUC | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Logistic Regression (Baseline)** | 0.51 | 0.38 | 0.56 | ❌ Rejected |
| **Random Forest (Tuned)** | 0.58 | 0.34 | 0.59 | ❌ Rejected |

### 🔍 Engineering Rationale for Non-Deployment
1. **High Cost of False Negatives:** With a low Recall score (~0.34), the models failed to detect nearly 66% of actual churning customers. In a live environment, this would cause the customer success team to miss the majority of at-risk users, defeating the purpose of a proactive retention program.
2. **Data Sparsity & Imbalance:** The volume of positive churn instances (86 records) was insufficient for the models to learn complex, non-linear feature interactions without overfitting to the majority class.
3. **The "Glass Box" Requirement:** Because retention interventions require direct human outreach by account managers, a highly explainable, transparent framework was prioritized over a weak, black-box statistical model.

---

## 🛠️ The Solution: Deterministic Decision-Support Framework

To deliver immediate business value despite data constraints, the project pivoted to a **transparent, rule-based Customer Health Scoring engine**. This framework leverages the insights verified during statistical hypothesis testing:

* **Categorical Drivers (Chi-Square Test):** Validated that geographic origin and contract structures share a statistically significant association with customer churn ($p < 0.05$).
* **Continuous Drivers (Mann-Whitney U Test):** Proved that the distributions of active usage metrics and support ticket volumes differ significantly between retaining and churning customer cohorts.

### 📈 Business Impact & Dashboard
The statistical signals were mapped directly into a deterministic scoring matrix ($0$ to $100$) that flags high-risk accounts. This decision layer continuously feeds an interactive **Tableau Retention Analytics Dashboard**, enabling the business team to isolate at-risk customer cohorts in real-time.

## Dashboard

📊 **[View the Interactive Tableau Dashboard](https://public.tableau.com/app/profile/falesh.sahu/viz/SaaSCustomerAnalyticsRetentionOverview/SaaSCustomerAnalyticsRetentionOverview?publish=yes&utm_source=chatgpt.com)** 

## What I Built

- **Data Pipeline Integrity** — Implemented strict runtime data validation using **Pydantic V2** schemas to isolate structural anomalies, data drift, and negative metrics prior to statistical calculations.
- **PostgreSQL + SQL** — Data modelling, Validation and Customer 360
- **Python** — Exploratory and Statistical analysis
- **Statistical Testing** — Chi-square and Mann–Whitney U tests
- **ML Feasibility** — Logistic Regression and Random Forest experiments
- **Decision Layer** — Transparent Rule-based customer health scoring
- **Tableau** — Interactive retention analytics dashboard

## Tech Stack

`Python` · `SQL` · `PostgreSQL` · `Pandas` · `SciPy` · `Scikit-learn` · `Tableau` · `Git`

## Project Structure

```text
Customer-Retention-Intelligence/
├── Outputs/
├── saas-subscription-analytics/
├── source_code/
├── sql/
├── .gitignore
└── README.md
```
