-- -- VÝZKUMNÁ OTÁZKA Č. 1
-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

CREATE OR REPLACE TABLE t_trend_of_payroll_final
	WITH base AS (
		SELECT DISTINCT
				industry_branch_code,
				AVG(value) OVER (PARTITION BY industry_branch_code, payroll_year ORDER BY payroll_year) AS avg_payroll_per_year,
				payroll_year
			FROM czechia_payroll cp 
		WHERE industry_branch_code IS NOT NULL AND calculation_code = 200 AND value_type_code = 5958
		)
	SELECT	
			industry_branch_code,
			avg_payroll_per_year,
			LAG(avg_payroll_per_year, 1) OVER (PARTITION BY industry_branch_code ORDER BY payroll_year) AS avg_payroll_preceding_year,
			payroll_year
		FROM base
	ORDER BY industry_branch_code ASC, payroll_year ASC
;

SELECT *
FROM t_trend_of_payroll_final;


-- ODPOVĚĎ NA VÝZKUMNOU OTÁZKU Č. 1
-- byly porovnavany prumerne platy kazdeho roku pro kazde odvetvi, sloupec "difference_in_payroll" predstavuje rozdil v platu oproti predchozimu roku
-- ve vsech odvetvich v letech 2001 - 2021 platy rostly, nicmene v kazdem odvetvi, krome C a Q, se nasel alespoň jeden rok, ve kterem byla prumerna mzda nizsi, nez v predchozim roce

WITH base AS (
	SELECT *,
		CASE 
			WHEN avg_payroll_per_year > avg_payroll_preceding_year THEN 'increasing'
			ELSE 'decreasing'
		END AS difference_in_payroll_between_years			
	FROM t_trend_of_payroll_final
)
SELECT 
	industry_branch_code,
	payroll_year,
	difference_in_payroll_between_years
FROM base
WHERE difference_in_payroll_between_years = 'decreasing'
	AND payroll_year BETWEEN 2001 AND 2021
;

