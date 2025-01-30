-- VÝZKUMNÁ OTÁZKA Č. 2
-- Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?


CREATE OR REPLACE TABLE t_milk_and_bread 
	SELECT 	DISTINCT
			price_category_code,
			price_name,
			price_year,
			industry_branch_code,
			AVG(payroll_value) OVER (PARTITION BY industry_branch_code) AS avg_payroll_per_year,
			AVG(price_value_CZK) OVER (PARTITION BY price_category_code) AS avg_price_of_food_per_year,
			price_unit
		FROM t_Veronika_Koudelkova_project_SQL_primary_final
	WHERE price_category_code = 114201 OR price_category_code = 111301
	ORDER BY price_category_code, price_year, industry_branch_code
;

SELECT * FROM t_milk_and_bread;


-- ODPOVĚĎ NA VÝZKUMNOU OTÁZKU Č. 2
-- množství kilogramů chleba / litrů mléka, které je možné si koupit z průměrného ročního platu kazdeho odvetvi je uvedeno ve sloupci "unit_per_payroll"
-- v tabulce je uveden prvni rok 2006 a posledni rok 2018 srovnatelneho obdobi

SELECT 
	price_category_code,
	price_name,
	industry_branch_code,
	price_year,
	ROUND(avg_payroll_per_year / avg_price_of_food_per_year, 0) AS unit_per_payroll,
	price_unit
FROM t_milk_and_bread
WHERE price_year = 2006 OR price_year = 2018
ORDER BY price_category_code, industry_branch_code, price_year
;
