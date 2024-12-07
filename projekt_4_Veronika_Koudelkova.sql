-- Potřebují k tomu od vás připravit robustní datové podklady, ve kterých bude možné vidět porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období.

SELECT * FROM czechia_payroll cp;
SELECT * FROM czechia_payroll_calculation cpc;
SELECT * FROM czechia_payroll_industry_branch cpib;
SELECT * FROM czechia_payroll_unit cpu;
SELECT * FROM czechia_payroll_value_type cpvt;
SELECT * FROM czechia_price cp;
SELECT * FROM czechia_price_category cpc;


-- propojeni tabulky czechia_price, tabulky czechia_price_category a tabulky czechia_payroll 

CREATE OR REPLACE TABLE t_Veronika_Koudelkova_project_SQL_primary_final
	SELECT
			cp.value AS price_value_CZK,
			cp.category_code AS price_category_code,
			cpc.name AS price_name,
			cpc.price_value,
			cpc.price_unit,
			substring(date_from, 1, 4) AS price_year,
			cpay.value as payroll_value,
			cpay.industry_branch_code,
			cpay.payroll_year,
			cpay.payroll_quarter		
		FROM (SELECT 
						*
		    		FROM czechia_price cp
				WHERE cp.region_code IS NULL   								-- na radku, kde je region_code = NULL, je uvedena prumerna cena potraviny ze vsech kraju v CR za vybrane obdobi 
			) cp
	LEFT JOIN czechia_price_category cpc ON cp.category_code = cpc.code
	LEFT JOIN	(SELECT *
					FROM czechia_payroll cpay
					WHERE value_type_code = '5958' AND calculation_code = '200' AND industry_branch_code IS NOT NULL
				) cpay
			ON substring(date_from, 1, 4) = cpay.payroll_year
	ORDER BY price_year
;

SELECT *
FROM t_Veronika_Koudelkova_project_SQL_primary_final;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.

SELECT * FROM countries;

SELECT * FROM economies;


CREATE OR REPLACE TABLE t_Veronika_Koudelkova_project_SQL_secondary_final
	SELECT
			c.country,
			e.year,
			e.gini,
			e.GDP,
			c.population,
			c.population_density,
			c.life_expectancy
	FROM countries c
	INNER JOIN economies e ON c.country = e.country
	WHERE c.continent = "Europe"
		AND e.year BETWEEN 2006 AND 2018
	ORDER BY c.country, year
;

SELECT * FROM t_Veronika_Koudelkova_project_SQL_secondary_final;


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
			LAG(avg_payroll_per_year, 1) OVER (PARTITION BY industry_branch_code ORDER BY payroll_year) AS lagged,
			payroll_year
		FROM base
	ORDER BY industry_branch_code ASC, payroll_year ASC
;

SELECT *
FROM t_trend_of_payroll_final;

-- ODPOVĚĎ NA VÝZKUMNOU OTÁZKU Č. 1
-- byly porovnavany prumerne platy kazdeho roku pro kazde odvetvi, sloupec "difference_in_payroll" predstavuje rozdil v platu oproti predchozimu roku
-- ve vsech odvetvich v letech 2000 - 2021 platy rostly, nicmene v kazdem odvetvi, krome C a Q, se nasel alespoň jeden rok, ve kterem byla prumerna mzda nizsi, nez v predchozim roce

SELECT 
		*,
		(avg_payroll_per_year - lagged) as difference_in_payroll
	FROM t_trend_of_payroll_final
WHERE payroll_year BETWEEN 2001 AND 2021
;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- VÝZKUMNÁ OTÁZKA Č. 2
-- Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?


CREATE OR REPLACE TABLE t_milk_and_bread 
	SELECT 	DISTINCT
			price_category_code,
			price_name,
			price_year,
			industry_branch_code,
			AVG(payroll_value) OVER (PARTITION BY industry_branch_code, payroll_year) AS avg_payroll_per_year,
			AVG(price_value_CZK) OVER (PARTITION BY price_category_code, price_year) AS avg_price_of_food_per_year,
			price_unit
		FROM t_Veronika_Koudelkova_project_SQL_primary_final
	WHERE price_category_code = 114201 OR price_category_code = 111301
	ORDER BY price_category_code, price_year, industry_branch_code
;

SELECT * FROM t_milk_and_bread;


CREATE OR REPLACE VIEW v_question_2 AS
	SELECT 	
			price_category_code,
			price_name,
			industry_branch_code,
			price_year,
			round(avg_payroll_per_year / avg_price_of_food_per_year, 0) AS unit_per_payroll,
			price_unit
		FROM t_milk_and_bread
;


-- ODPOVĚĎ NA VÝZKUMNOU OTÁZKU Č. 2
-- množství kilogramů chleba / litrů mléka, které je možné si koupit z průměrného ročního platu kazdeho odvetvi je uvedeno ve sloupci "unit_per_payroll"
-- v tabulce je uveden prvni rok 2006 a posledni rok 2018 srovnatelneho obdobi

SELECT *
FROM v_question_2
WHERE price_year = 2006 OR price_year = 2018
ORDER BY price_category_code, industry_branch_code, price_year
;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- VÝZKUMNÁ OTÁZKA Č. 3
-- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

SELECT *
FROM czechia_price;

CREATE OR REPLACE TABLE t_rise_price_1
	SELECT 
			cp.value AS value_in_CZK,
			AVG(cp.value) OVER (partition by category_code, year) AS average_price_per_year_CZK,
			cp.category_code,
			cpc.name,
			cpc.price_value,
			cpc.price_unit,
			substring(date_from, 1, 4) AS year
		FROM czechia_price cp 
	LEFT JOIN czechia_price_category cpc ON cp.category_code = cpc.code
	WHERE region_code IS NULL
	ORDER BY year, category_code
;

select * from t_rise_price_1;


CREATE OR REPLACE TABLE t_rise_price_2
	WITH base AS (
			SELECT DISTINCT 
					average_price_per_year_CZK,
					LAG(average_price_per_year_CZK) OVER (PARTITION BY category_code ORDER BY category_code, year) as lagged,
					category_code,
					name,
					year,
					(((average_price_per_year_CZK * 100) / LAG(average_price_per_year_CZK) OVER (PARTITION BY category_code ORDER BY category_code, year)) - 100) AS percentual_difference_in_food_between_years
				FROM t_rise_price_1
			ORDER BY category_code, year
	)
	SELECT 
			average_price_per_year_CZK,
			lagged,
			category_code,
			name,
			year,
			percentual_difference_in_food_between_years,
			sum(percentual_difference_in_food_between_years) over (partition by category_code order by category_code, year) as cumulative
		FROM base
	WHERE lagged IS NOT NULL AND percentual_difference_in_food_between_years != 0
;

SELECT *
FROM t_rise_price_2;

CREATE OR REPLACE view v_question_3 AS 
	SELECT
		 	category_code,
		 	name,
		 	year,
		 	average_price_per_year_CZK,
		 	percentual_difference_in_food_between_years,
		 	cumulative
	FROM t_rise_price_2
	order by category_code, year
;

SELECT * FROM v_question_3;

-- ODPOVĚĎ NA VÝZKUMNOU OTÁZKU Č. 3
-- "v_question_3" obsahuje sloupec "cumulative", kde je uveden kumulativni mezirocni narust cen v obdobi 2006 az 2018
-- nejpomaleji zdrazuje Cukr krystalovy, kumulativni narust u nej v roce 2018 cini -23,3 %, tzn. ze oproti roku 2006 cukr vyrazne zlevnil
-- pokud bych se zamerila na potravinu, ktera v prubehu let zdrazila nejmene, tak nejpomaleji zdrazuji banany, nebot jejich kumulativni narust ceny mezi roky 2006 a 2018 cinil 9.72 %
-- jakostni vino bile jsem neposuzovala, nebot jsou v tabulce czechia_price uvedena pouze data pro rok 2015 az 2018

SELECT
		name,
		year,
		cumulative
FROM v_question_3
WHERE year = 2018
;


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- VÝZKUMNÁ OTÁZKA Č. 4
-- Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

SELECT *
FROM czechia_price;

SELECT *
FROM czechia_payroll;


CREATE OR REPLACE TABLE t_question_4_food
	WITH base AS (
			SELECT 	
					round(AVG(cp.value) OVER (ORDER BY year), 2) AS avg_price_of_all_food_per_year,
					cp.category_code,
					cpc.name,
					cpc.price_value,
					cpc.price_unit,
					substring(date_from, 1, 4) AS year
				FROM czechia_price cp 
			LEFT JOIN czechia_price_category cpc ON cp.category_code = cpc.code
			WHERE region_code IS NULL
			ORDER BY YEAR, category_code
	)
	SELECT 	
			avg_price_of_all_food_per_year,
			lag(avg_price_of_all_food_per_year) OVER (ORDER BY year) AS lag_avg_price_of_all_food_per_year,
			year
	FROM base
;

SELECT DISTINCT * FROM t_question_4_food;

CREATE OR REPLACE TABLE t_question_4_payroll
	WITH base AS (
					SELECT
							round(avg(value) OVER (PARTITION BY payroll_year), 0) AS average_payroll_per_year,
							industry_branch_code,
							payroll_year
						FROM czechia_payroll cp 
					WHERE industry_branch_code IS NOT NULL AND calculation_code = 200 AND value_type_code = 5958 AND payroll_year BETWEEN 2006 AND 2018
	)
	SELECT 	
			industry_branch_code,
			payroll_year,
			average_payroll_per_year,
			lag(average_payroll_per_year) OVER (ORDER BY industry_branch_code, payroll_year) AS lag_average_payroll_per_year
		FROM base
	ORDER BY industry_branch_code, payroll_year
;

SELECT DISTINCT * FROM t_question_4_payroll;
	

CREATE OR REPLACE VIEW v_question_4 AS
	WITH base_food AS (
			SELECT 
					avg_price_of_all_food_per_year,
					lag_avg_price_of_all_food_per_year,
					year,
					ROUND(((avg_price_of_all_food_per_year * 100) / lag_avg_price_of_all_food_per_year) - 100, 2) AS percentual_difference_in_food		
				FROM t_question_4_food
			WHERE 1=1
				AND year BETWEEN 2007 AND 2018
				AND avg_price_of_all_food_per_year != lag_avg_price_of_all_food_per_year
	),
	base_payroll AS (
			SELECT 
					payroll_year,
					average_payroll_per_year,
					lag_average_payroll_per_year,
					round(((average_payroll_per_year * 100) / lag_average_payroll_per_year) - 100, 2) AS percentual_difference_in_payroll
				FROM t_question_4_payroll
			WHERE 1=1
				AND payroll_year BETWEEN 2007 AND 2018
				AND average_payroll_per_year != lag_average_payroll_per_year
	)
	SELECT 
		-- bf.avg_price_of_all_food_per_year,
		-- bf.lag_avg_price_of_all_food_per_year,
		bf.year,
		bf.percentual_difference_in_food,
		-- bp.average_payroll_per_year,
		-- bp.lag_average_payroll_per_year,
		bp.percentual_difference_in_payroll
	FROM base_food bf
	LEFT JOIN base_payroll bp ON bp.payroll_year = bf.year
;

-- ODPOVĚĎ NA VÝZKUMNOU OTÁZKU Č. 4
-- byla porovnavana prumerna cena vsech potravin dohromady a prumerny plat ze vsech odvetvi pro kazdy rok v intervalu 2007 az 2018
-- z vysledku ve sloupci "diff_between_payroll_and_food" vyplyva, ze rozdil v zadnem roce nedosahl hodnoty 10 %

SELECT DISTINCT 
			year,
			percentual_difference_in_food,
			percentual_difference_in_payroll,
			(percentual_difference_in_payroll - percentual_difference_in_food) AS diff_between_payroll_and_food
FROM v_question_4
;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- VÝZKUMNÁ OTÁZKA Č. 5
-- Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách 
-- ve stejném nebo následujícím roce výraznějším růstem?


SELECT *
FROM economies
WHERE country = 'Czech Republic' and year between 2006 and 2018
;

CREATE OR REPLACE TABLE t_question_5_GDP_vs_payroll
	WITH base_GDP AS (
						SELECT 
								country,
								year as economies_year,
								GDP,
								LAG(GDP) OVER (ORDER BY year) as lagged_GDP		
							FROM economies
						WHERE country = 'Czech Republic' AND year BETWEEN 2006 AND 2018
						ORDER BY year 
	),
		base_payroll as (
						SELECT	
								avg(value) OVER (PARTITION BY industry_branch_code, payroll_year) AS average_payroll_per_year,
								industry_branch_code,
								payroll_year
							FROM czechia_payroll cp 
						WHERE industry_branch_code IS NOT NULL AND calculation_code = 200 AND value_type_code = 5958 AND payroll_year BETWEEN 2006 AND 2018
						ORDER BY industry_branch_code ASC, payroll_year ASC
	)
	SELECT 
			bG.country,
			bG.GDP,
			bG.lagged_GDP,
			ROUND(((bG.GDP * 100) / bG.lagged_GDP) - 100, 2) AS percentual_difference_in_GDP_between_years,
			bG.economies_year,
			bp.industry_branch_code,
			bp.average_payroll_per_year,
			lag(bp.average_payroll_per_year) OVER (ORDER BY industry_branch_code, payroll_year) AS lagged_avg_payroll
	FROM base_GDP bG
	LEFT JOIN base_payroll bp ON bG.economies_year = bp.payroll_year
	WHERE economies_year BETWEEN 2006 AND 2018
;

SELECT DISTINCT * FROM t_question_5_GDP_vs_payroll;



CREATE OR REPLACE TABLE t_question_5_GDP_vs_food
	WITH base_GDP AS (
						SELECT 
								country,
								year AS economies_year,
								GDP,
								LAG(GDP) OVER (ORDER BY year) AS lagged_GDP		
							FROM economies
						WHERE country = 'Czech Republic' AND year BETWEEN 2006 AND 2018
						ORDER BY YEAR ASC
	),
		base_food AS (
						SELECT 
								cp.value AS value_in_CZK,
								round(AVG(cp.value) OVER(PARTITION BY category_code, year), 2) AS average_price_per_year_CZK,
								cp.category_code as category_code,
								cpc.name as food_name,
								cpc.price_value as food_value,
								cpc.price_unit as food_price_unit,
								substring(date_from, 1, 4) AS year
							FROM czechia_price cp 
						LEFT JOIN czechia_price_category cpc ON cp.category_code = cpc.code
						WHERE region_code IS NULL
						ORDER BY year, category_code
	)
	SELECT 
			bG.country,
			bG.GDP,
			bG.lagged_GDP,
			ROUND(((bG.GDP * 100) / bG.lagged_GDP) - 100, 2) AS percentual_difference_in_GDP_between_years,
			bG.economies_year,
			bf.category_code,
			bf.food_name,
			bf.year,
			bf.average_price_per_year_CZK,
			lag(bf.average_price_per_year_CZK) OVER (ORDER BY food_name, year) AS lagged_average_price_per_year_CZK
	FROM base_GDP bG
	LEFT JOIN base_food bf ON bG.economies_year = bf.year
	WHERE economies_year BETWEEN 2006 AND 2018
;

SELECT * FROM t_question_5_GDP_vs_food;

CREATE OR REPLACE VIEW v_question_5_GDP_vs_payroll AS
	SELECT 
			country,
			GDP,
			lagged_GDP,
			percentual_difference_in_GDP_between_years,
			economies_year,
			industry_branch_code,
			average_payroll_per_year,
			lagged_avg_payroll,
			round((average_payroll_per_year * 100) / lagged_avg_payroll - 100, 2) AS percentual_diff_of_payroll_between_years
	FROM t_question_5_GDP_vs_payroll
;

SELECT * FROM v_question_5_GDP_vs_payroll;

create or replace view V_QUESTIOn_5_GDP_vs_food AS
	SELECT 
			country,
			GDP,
			lagged_GDP,
			percentual_difference_in_GDP_between_years,
			economies_year,
			category_code,
			food_name,
			((average_price_per_year_CZK * 100) / lagged_average_price_per_year_CZK - 100) AS percentual_diff_in_food_between_years
		FROM t_question_5_GDP_vs_food
	WHERE average_price_per_year_CZK != lagged_average_price_per_year_CZK AND economies_year BETWEEN 2007 AND 2018
;

SELECT * FROM v_question_5_GDP_vs_food;

-- ODPOVĚĎ NA VÝZKUMNOU OTÁZKU Č. 5
-- k odpovědi 5 byla vytvořena 2 view pro lepší přehlednost, první porovnává změny HDP a cen potravin mezi jednotlivými roky, druhé view porovnává změny HDP a nárůst či pokles mezd mezi jednotlivými roky
-- z dat zahrnujicich mezirocni procentualni rozdil cen potravin a HDP byl v excelu zkonstruovan graf, ktery zobrazuje vyraznou zavislost zmen ceny potravin na zmenach HDP
-- k nejvyraznějsimu poklesu HDP došlo v roce 2009, z dat je viditelný pokles ceny potravin ještě v tomtéž roce a u nekterych potravin i v roce následujícím
-- mezi roky 2010 a 2012 dochazelo ke snizovani HDP, trend v cenach potravin byl vsak opacny, dochazelo k postupnemu zdrazovani 

-- pokud jde o prumerne mzdy v kazdem odvetvi, rok 2009 s poklesem HDP o -4,66 % vedl u temer vsech odvetvi k poklesu platu ci jen k jejich velmi mirnemu narustu oproti roku 2008
-- mezi roky 2010 a 2012 dochazelo ke snizovani HDP, coz se v roce 2013 pravdepodobne odrazilo v platech, kdy byl pokles mezd ci jen jejich nepatrny narust zaznamenan v kazdem odvetvi
-- od roku 2013 mzdy v kazdem odvetvi s mirnymi vykyvy rostou

SELECT 
		country,
		GDP,
		economies_year,
		food_name,
		percentual_difference_in_GDP_between_years,
		percentual_diff_in_food_between_years
FROM v_question_5_GDP_vs_food
;

SELECT 
		country,
		GDP,
		economies_year,
		industry_branch_code,
		percentual_difference_in_GDP_between_years,
		percentual_diff_of_payroll_between_years
FROM v_question_5_GDP_vs_payroll
WHERE percentual_diff_of_payroll_between_years != 0
	AND economies_year BETWEEN 2007 AND 2018
;
