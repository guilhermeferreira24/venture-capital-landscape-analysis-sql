# SQL Case Study: Venture Capital Landscape Analysis

## Overview

This case study supports an **angel investment firm** by identifying the top 3 performing industries in terms of the highest number of **unicorn companies** created between **2019 and 2021**, and analysing their average valuations over time.

> *In the world of finance, a "unicorn" refers to a privately held startup company with a value of over $1 billion.*

***

## Objective

The firm requested a data-driven analysis to:

- Identify the **3 best-performing industries** by unicorn creation (2019–2021 combined)
- Break down the **number of unicorns per industry per year**
- Calculate the **average valuation in billions** for each industry per year
- Return results sorted by **year** and **number of unicorns** (both descending)

***

## Database Schema

The `unicorns` database used in this project is hosted on DataCamp's proprietary servers and contains the following tables:

| Table | Column | Description |
|---|---|---|
| `companies` | `company_id` | Unique company identifier |
| | `company` | Company name |
| | `city` | Headquarters city |
| | `country` | Headquarters country |
| | `continent` | Headquarters continent |
| `dates` | `company_id` | Unique company identifier |
| | `date_joined` | Date the company became a unicorn |
| | `year_founded` | Year the company was founded |
| `funding` | `company_id` | Unique company identifier |
| | `valuation` | Company value in US dollars |
| | `funding` | Amount of funding raised in US dollars |
| | `select_investors` | Key investors in the company |
| `industries` | `company_id` | Unique company identifier |
| | `industry` | Industry the company operates in |

***

## Approach

The most critical insight in this project was recognising that **without first identifying the top 3 industry names**, it would be impossible to filter the yearly breakdown correctly.

The solution was structured in **3 steps using CTEs (Common Table Expressions)**:

### Step 1 — Identify the Top 3 Industries

```sql
-- Identifying the 3 industries that produced the most unicorns between 2019 and 2021
WITH top_industries AS (

    SELECT
        i.industry,
        COUNT(*) AS total_unicorns  -- counts total unicorns per industry

    FROM industries AS i

    -- join to get the date each company became a unicorn
    INNER JOIN dates AS d ON i.company_id = d.company_id

    -- filter only companies that became unicorns between 2019 and 2021
    WHERE d.date_joined BETWEEN '2019-01-01' AND '2021-12-31'

    GROUP BY i.industry           -- group results by industry
    ORDER BY total_unicorns DESC  -- rank from highest to lowest
    LIMIT 3                       -- keep only the top 3

),
```

### Step 2 — Yearly Breakdown for the Top 3 Industries

```sql
-- Yearly rankings: breaks down unicorn count and average valuation per year (top 3 industries)
yearly_rankings AS (

    SELECT
        i.industry,
        EXTRACT(YEAR FROM d.date_joined) AS year,
        COUNT(*) AS num_unicorns,                   -- counts unicorns per industry per year
        ROUND(AVG(f.valuation / 1e9)::NUMERIC, 2) AS average_valuation_billions
        -- divides valuation by 1 billion, averages it and rounds to 2 decimal places

    FROM industries AS i

    -- join to get the date each company became a unicorn
    INNER JOIN dates AS d ON i.company_id = d.company_id

    -- join to get the valuation of each company
    INNER JOIN funding AS f ON i.company_id = f.company_id

    -- same date filter as CTE 1
    WHERE d.date_joined BETWEEN '2019-01-01' AND '2021-12-31'

    -- only include the top 3 industries identified in CTE 1
    AND i.industry IN (SELECT industry FROM top_industries)

    GROUP BY i.industry, year  -- group by industry AND year

)
```

### Step 3 — Final Output

```sql
-- Final result: ordered by year and number of unicorns (both descending)
SELECT
    industry,
    year::INT,
    num_unicorns,
    average_valuation_billions
FROM yearly_rankings
ORDER BY year DESC, num_unicorns DESC;
```

***

## Results

| industry | year | num_unicorns | average_valuation_billions |
|---|---|---|---|
| Fintech | 2021 | 138 | 2.75 |
| Internet software & services | 2021 | 119 | 2.15 |
| E-commerce & direct-to-consumer | 2021 | 47 | 2.47 |
| Internet software & services | 2020 | 20 | 4.35 |
| E-commerce & direct-to-consumer | 2020 | 16 | 4.00 |
| Fintech | 2020 | 15 | 4.33 |
| Fintech | 2019 | 20 | 6.80 |
| Internet software & services | 2019 | 13 | 4.23 |
| E-commerce & direct-to-consumer | 2019 | 12 | 2.58 |

***

## Key Insights

- **Fintech dominates** — growing from 20 unicorns in 2019 to 138 in 2021, a near 7× increase driven by the pandemic-era boom in digital payments, neobanks, and crypto.
- **Valuations decline as volume increases** — in 2019, fewer unicorns meant higher average valuations ($6.80B for Fintech). By 2021, the surge of new entrants pulled the average down to $2.75B, indicating a more accessible but more competitive market.
- **Internet software & services** is the most consistent performer, maintaining a stable presence across all three years — a reliable sector for long-term portfolio allocation.

***

## Tools & Skills

- **PostgreSQL** — CTEs, INNER JOINs, aggregations, subqueries
- **DataCamp DataLab** — project environment

---

## What I Learned

- **CTEs make complex problems readable** — breaking the query into `top_industries` → `yearly_rankings` made each step clear and easy to debug
  **CTE (Common Table Expression)** — a temporary, named result set created with the `WITH` keyword that acts as a building block for the main query, making complex SQL easier to read and debug.
- **Order of operations matters in SQL** — I had to identify the top 3 industries *first* before filtering the yearly breakdown, which is where CTEs shine
- **JOINs don't carry over between CTEs** — each CTE queries the original tables independently
- **Valuation conversion in PostgreSQL** — `ROUND(AVG(f.valuation / 1e9)::NUMERIC, 2)` was a useful pattern to handle decimal precision cleanly

---

## What I Would Recommend

- **Fintech** — highest growth (20 → 138 unicorns) but declining valuations suggest a crowded market; focus on early-stage companies before they reach unicorn status
- **Internet software & services** — most consistent across all three years; the safest long-term holding in the portfolio
- **E-commerce** — strong 2021 numbers driven by pandemic tailwinds; worth monitoring whether momentum held post-2021 before increasing exposure
***

## Source

DataCamp Project — *Analyzing Unicorn Companies*  
Data sourced from DataCamp's proprietary `unicorns` database.
