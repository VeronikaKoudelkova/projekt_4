soubor "projekt_4_Veronika_koudelkova.sql" obsahuje sadu SQL dotazů generujících:
1. tabulku "t_Veronika_Koudelkova_project_SQL_primary_final" s daty mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky
2. tabulku "t_Veronika_Koudelkova_project_SQL_secondary_final" s daty HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR
3. sady SQL dotazů odpovídajících na celkem 5 otázek, odpovědi na ně jsou spolu s výstupním SQL dotazem uvedeny na konci každého zadání otázky

Odpovědi na jednotlivé výzkumné otázky:

Otázka č. 1: "Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?"

Odpověď: Ve všech odvětvích v letech 2001 až 2021 platy rostly, nicméně v každém odvětví, kromě C a Q, se našel alespoň jeden rok, ve kterém byla průměrná mzda nižší, než v předchozím roce.



Otázka č. 2: "Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?"

Odpověď: Množství kilogramů chleba / litrů mléka, které je možné si koupit z průměrného ročního platu každého odvětví je uvedeno ve sloupci "unit_per_payroll".
         V tabulce je uveden první rok 2006 a poslední rok 2018 srovnatelného období.

         

Otázka č. 3: "Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?"

Odpověď: Nejpomaleji zdražuje Cukr krystalový, kumulativní nárůst u něj v roce 2018 činí -23,3 %, tzn. že oproti roku 2006 cukr výrazně zlevnil.
         Pokud bych se zaměřila na potravinu, která v průběhu let zdražila nejméně, tak nejpomaleji zdražují banány, neboť jejich kumulativní nárůst ceny mezi roky 2006 a 2018 činil 9.72 %.
         Jakostní víno bíle jsem neposuzovala, neboť jsou v tabulce czechia_price uvedena pouze data pro rok 2015 az 2018.

         

Otázka č. 4: "Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?"

Odpověď: Byla porovnávána průměrná cena všch potravin dohromady a průměrný plat ze všech odvětví pro každý rok v intervalu 2007 az 2018.
         Z výsledků vyplývá, že rozdíl v žádném roce nedosáhl hodnoty 10 %.

         

Otázka č. 5: "Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?"

Odpověď: Z dat zahrnujících meziroční procentuální rozdíl cen potravin a HDP byl v excelu zkonstruován graf, který zobrazuje výraznou závislost změn ceny potravin na změnách HDP.
         K nejvýraznějšímu poklesu HDP došlo v roce 2009, z dat je viditelný pokles ceny potravin ještě v tomtéž roce a u některých potravin i v roce následujícím mezi roky 2010 a 2012 docházelo ke snižování HDP, 
         trend v cenách potravin byl však opačný, docházelo k postupnému zdražování.
         Pokud jde o průměrné mzdy v každém odvětví, rok 2009 s poklesem HDP o -4,66 % vedl u téměř všech odvětví k poklesu platu či jen k jejich velmi mírnému nárůstu oproti roku 2008.
         mezi roky 2010 a 2012 docházelo ke snižování HDP, což se v roce 2013 pravděpodobně odrazilo v platech, kdy byl pokles mezd či jen jejich nepatrný nárůst zaznamenán v každém odvětví
         od roku 2013 mzdy v každém odvětví s mírnými výkyvy rostou.
         Nicméně korelace mezi vývojem cen potravin či mezd a trendem HDP nemusí být nutně podmíněna příčinným vztahem!
