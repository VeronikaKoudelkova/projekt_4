-- VÝZKUMNÁ OTÁZKA Č. 5
-- Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách 
-- ve stejném nebo následujícím roce výraznějším růstem?


SELECT *
FROM economies
WHERE country = 'Czech Republic' and year between 2006 and 2018
;

CREATE OR REPLACE TABLE t_question_5_gdp_vs_payroll
	WITH base_gdp AS (
						SELECT 
								country,
								year as economies_year,
								GDP,
								LAG(GDP) OVER (ORDER BY year) as gdp_preceding_year		
							FROM economies
						WHERE country = 'Czech Republic' AND year BETWEEN 2006 AND 2018
						ORDER BY year 
	),
		base_payroll as (
						SELECT	
								AVG(value) OVER (PARTITION BY industry_branch_code, payroll_year) AS average_payroll_per_year,
								industry_branch_code,
								payroll_year
							FROM czechia_payroll cp 
						WHERE industry_branch_code IS NOT NULL AND calculation_code = 200 AND value_type_code = 5958 AND payroll_year BETWEEN 2006 AND 2018
						ORDER BY industry_branch_code ASC, payroll_year ASC
	)
	SELECT 
			bg.country,
			bg.GDP,
			bg.gdp_preceding_year,
			ROUND(((bg.GDP * 100) / bg.GDP_preceding_year) - 100, 2) AS percentual_difference_in_gdp_between_years,
			bg.economies_year,
			bp.industry_branch_code,
			bp.average_payroll_per_year,
			LAG(bp.average_payroll_per_year) OVER (ORDER BY industry_branch_code, payroll_year) AS avg_payroll_preceding_year
	FROM base_gdp bg
	LEFT JOIN base_payroll bp ON bg.economies_year = bp.payroll_year
	WHERE economies_year BETWEEN 2006 AND 2018
;

SELECT DISTINCT * FROM t_question_5_gdp_vs_payroll;



CREATE OR REPLACE TABLE t_question_5_gdp_vs_food
	WITH base_gdp AS (
						SELECT 
								country,
								year AS economies_year,
								GDP,
								LAG(GDP) OVER (ORDER BY year) AS gdp_preceding_year		
							FROM economies
						WHERE country = 'Czech Republic' AND year BETWEEN 2006 AND 2018
						ORDER BY YEAR ASC
	),
		base_food AS (
						SELECT 
								cp.value AS value_in_CZK,
								ROUND(AVG(cp.value) OVER(PARTITION BY category_code, year), 2) AS average_price_per_year_CZK,
								cp.category_code as category_code,
								cpc.name as food_name,
								cpc.price_value as food_value,
								cpc.price_unit as food_price_unit,
								EXTRACT(YEAR FROM date_from) as year
							FROM czechia_price cp 
						LEFT JOIN czechia_price_category cpc ON cp.category_code = cpc.code
						WHERE region_code IS NULL
						ORDER BY year, category_code
	)
	SELECT 
			bg.country,
			bg.GDP,
			bg.GDP_preceding_year,
			ROUND(((bg.GDP * 100) / bg.GDP_preceding_year) - 100, 2) AS percentual_difference_in_gdp_between_years,
			bg.economies_year,
			bf.category_code,
			bf.food_name,
			bf.year,
			bf.average_price_per_year_CZK,
			LAG(bf.average_price_per_year_CZK) OVER (ORDER BY food_name, year) AS average_price_preceding_year_CZK
	FROM base_gdp bg
	LEFT JOIN base_food bf ON bg.economies_year = bf.year
	WHERE economies_year BETWEEN 2006 AND 2018
;

SELECT * FROM t_question_5_gdp_vs_food;



-- ODPOVĚĎ NA VÝZKUMNOU OTÁZKU Č. 5
-- k odpovědi 5 byly vytvořeny 2 skripty pro lepší přehlednost, první porovnává změny HDP a cen potravin mezi jednotlivými roky, druhý skript porovnává změny HDP a nárůst či pokles mezd mezi jednotlivými roky
-- z dat zahrnujících meziroční procentuální rozdíl cen potravin a HDP byl v excelu zkonstruován graf, který zobrazuje výraznou závislost změn ceny potravin na změnách HDP
-- k nejvýraznějšímu poklesu HDP došlo v roce 2009, z dat je viditelný pokles ceny potravin ještě v tomtéž roce a u některých potravin i v roce následujícím
-- mezi roky 2010 a 2012 docházelo ke snižování HDP, trend v cenách potravin byl však opačný, docházelo k postupnému zdražování 

-- pokud jde o průměrné mzdy v každém odvětví, rok 2009 s poklesem HDP o -4,66 % vedl u téměř všech odvětví k poklesu platu či jen k jejich velmi mírnému nárůstu oproti roku 2008
-- mezi roky 2010 a 2012 docházelo ke snižování HDP, což se v roce 2013 pravděpodobně odrazilo v platech, kdy byl pokles mezd či jen jejich nepatrný nárůst zaznamenán v každém odvětví
-- od roku 2013 mzdy v každém odvětví s mírnými výkyvy rostou


WITH base_food AS (
	SELECT 
		country,
		GDP,
		economies_year,
		food_name,
		percentual_difference_in_GDP_between_years,
		((average_price_per_year_CZK * 100) / average_price_preceding_year_CZK - 100) AS percentual_diff_in_food_between_years
	FROM t_question_5_gdp_vs_food
) 
SELECT 
		*
FROM base_food
WHERE economies_year BETWEEN 2007 AND 2018
	AND percentual_diff_in_food_between_years != 0
;


WITH base_payroll AS (
	SELECT
        country,
		GDP,
		economies_year,
		industry_branch_code,
		percentual_difference_in_GDP_between_years,
		ROUND((average_payroll_per_year * 100) / avg_payroll_preceding_year - 100, 2) AS percentual_diff_of_payroll_between_years
	FROM t_question_5_gdp_vs_payroll
)
SELECT *
FROM base_payroll
WHERE percentual_diff_of_payroll_between_years != 0
	AND economies_year BETWEEN 2007 AND 2018
;
