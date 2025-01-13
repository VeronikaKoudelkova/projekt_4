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