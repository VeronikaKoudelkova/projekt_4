
-- VÝZKUMNÁ OTÁZKA Č. 4
-- Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

SELECT *
FROM czechia_price;

SELECT *
FROM czechia_payroll;


CREATE OR REPLACE TABLE t_question_4_food
	WITH base AS (
			SELECT 	
					ROUND(AVG(cp.value) OVER (ORDER BY year), 2) AS avg_price_of_all_food_per_year,
					cp.category_code,
					cpc.name,
					cpc.price_value,
					cpc.price_unit,
					EXTRACT(YEAR FROM date_from) as year
				FROM czechia_price cp 
			LEFT JOIN czechia_price_category cpc ON cp.category_code = cpc.code
			WHERE region_code IS NULL
			ORDER BY YEAR, category_code
	)
	SELECT 	
			avg_price_of_all_food_per_year,
			LAG(avg_price_of_all_food_per_year) OVER (ORDER BY year) AS avg_price_of_all_food_preceding_year,
			year
	FROM base
;

SELECT DISTINCT * FROM t_question_4_food;

CREATE OR REPLACE TABLE t_question_4_payroll
	WITH base AS (
					SELECT
							ROUND(AVG(value) OVER (PARTITION BY payroll_year), 0) AS average_payroll_per_year,
							industry_branch_code,
							payroll_year
						FROM czechia_payroll cp 
					WHERE industry_branch_code IS NOT NULL AND calculation_code = 200 AND value_type_code = 5958 AND payroll_year BETWEEN 2006 AND 2018
	)
	SELECT 	
			industry_branch_code,
			payroll_year,
			average_payroll_per_year,
			LAG(average_payroll_per_year) OVER (ORDER BY industry_branch_code, payroll_year) AS average_payroll_preceding_year
		FROM base
	ORDER BY industry_branch_code, payroll_year
;

SELECT DISTINCT * FROM t_question_4_payroll;
	

CREATE OR REPLACE TABLE t_question_4_final AS
	WITH base_food AS (
			SELECT 
					avg_price_of_all_food_per_year,
					avg_price_of_all_food_preceding_year,
					year,
					ROUND(((avg_price_of_all_food_per_year * 100) / avg_price_of_all_food_preceding_year) - 100, 2) AS percentual_difference_in_food		
				FROM t_question_4_food
			WHERE 1=1
				AND year BETWEEN 2007 AND 2018
				AND avg_price_of_all_food_per_year != avg_price_of_all_food_preceding_year
	),
	base_payroll AS (
			SELECT 
					payroll_year,
					average_payroll_per_year,
					average_payroll_preceding_year,
					ROUND(((average_payroll_per_year * 100) / average_payroll_preceding_year) - 100, 2) AS percentual_difference_in_payroll
				FROM t_question_4_payroll
			WHERE 1=1
				AND payroll_year BETWEEN 2007 AND 2018
				AND average_payroll_per_year != average_payroll_preceding_year
	)
	SELECT 
		-- bf.avg_price_of_all_food_per_year,
		-- bf.avg_price_of_all_food_preceding_year,
		bf.year,
		bf.percentual_difference_in_food,
		-- bp.average_payroll_per_year,
		-- bp.average_payroll_preceding_year,
		bp.percentual_difference_in_payroll
	FROM base_food bf
	LEFT JOIN base_payroll bp ON bp.payroll_year = bf.year
;

select *
from t_question_4_final;

-- ODPOVĚĎ NA VÝZKUMNOU OTÁZKU Č. 4
-- byla porovnavana prumerna cena vsech potravin dohromady a prumerny plat ze vsech odvetvi pro kazdy rok v intervalu 2007 az 2018
-- z vysledku ve sloupci "diff_between_payroll_and_food" vyplyva, ze rozdil v zadnem roce nedosahl hodnoty 10 %

SELECT DISTINCT 
			year,
			percentual_difference_in_food,
			percentual_difference_in_payroll,
			(percentual_difference_in_payroll - percentual_difference_in_food) AS diff_between_payroll_and_food
FROM t_question_4_final
;