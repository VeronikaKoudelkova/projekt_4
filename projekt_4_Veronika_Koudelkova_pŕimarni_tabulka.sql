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