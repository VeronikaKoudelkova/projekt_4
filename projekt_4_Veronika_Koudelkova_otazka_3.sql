
-- VÝZKUMNÁ OTÁZKA Č. 3
-- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

SELECT *
FROM czechia_price;

CREATE OR REPLACE TABLE t_rise_price_1
	SELECT 
			cp.value AS value_in_CZK,
			AVG(cp.value) OVER (PARTITION BY category_code, year) AS average_price_per_year_CZK,
			cp.category_code,
			cpc.name,
			cpc.price_value,
			cpc.price_unit,
			EXTRACT(YEAR FROM date_from) as year
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
					LAG(average_price_per_year_CZK) OVER (PARTITION BY category_code ORDER BY category_code, year) as avg_price_preceding_year_CZK,
					category_code,
					name,
					year,
					(((average_price_per_year_CZK * 100) / LAG(average_price_per_year_CZK) OVER (PARTITION BY category_code ORDER BY category_code, year)) - 100) AS percentual_difference_in_food_between_years
				FROM t_rise_price_1
			ORDER BY category_code, year
	)
	SELECT 
			average_price_per_year_CZK,
			avg_price_preceding_year_CZK,
			category_code,
			name,
			year,
			percentual_difference_in_food_between_years,
			SUM(percentual_difference_in_food_between_years) OVER (PARTITION BY category_code ORDER BY category_code, year) AS cumulative
		FROM base
	WHERE avg_price_preceding_year_CZK IS NOT NULL AND percentual_difference_in_food_between_years != 0
;

SELECT *
FROM t_rise_price_2;


-- ODPOVĚĎ NA VÝZKUMNOU OTÁZKU Č. 3
-- "v_question_3" obsahuje sloupec "cumulative", kde je uveden kumulativni mezirocni narust cen v obdobi 2006 az 2018
-- nejpomaleji zdrazuje Cukr krystalovy, kumulativni narust u nej v roce 2018 cini -23,3 %, tzn. ze oproti roku 2006 cukr vyrazne zlevnil
-- pokud bych se zamerila na potravinu, ktera v prubehu let zdrazila nejmene, tak nejpomaleji zdrazuji banany, nebot jejich kumulativni narust ceny mezi roky 2006 a 2018 cinil 9.72 %
-- jakostni vino bile jsem neposuzovala, nebot jsou v tabulce czechia_price uvedena pouze data pro rok 2015 az 2018

SELECT
		name,
		year,
		cumulative
FROM t_rise_price_2
WHERE year = 2018
;
