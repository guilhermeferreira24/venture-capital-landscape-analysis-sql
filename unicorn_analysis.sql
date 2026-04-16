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

-- Step 2: Yearly rankings — breaks down unicorn count and average valuation per year (top 3 industries)
yearly_rankings AS (

    SELECT
        i.industry,
        EXTRACT(YEAR FROM d.date_joined) AS year,
        COUNT(*) AS num_unicorns,                    -- counts unicorns per industry per year
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

-- Step 3: Final result — ordered by year and number of unicorns (both descending)
SELECT
    industry,
    year::INT,
    num_unicorns,
    average_valuation_billions
FROM yearly_rankings
ORDER BY year DESC, num_unicorns DESC;
