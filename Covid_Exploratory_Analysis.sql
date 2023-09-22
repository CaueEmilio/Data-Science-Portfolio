/* Data exploration of data extracted from: https://ourworldindata.org/covid-deaths */ 
SELECT * FROM ..[owid-covid-data];

/* Death Analysis */
/*Death rate by country (per day)*/
SELECT 
	location
	,continent
	,date
	,total_cases
	,total_deaths
	,(total_deaths/total_cases*100) AS death_rate
FROM ..[owid-covid-data]
WHERE continent is not null
ORDER BY date DESC, location ASC;
/*Death rate by continent (per day)*/
SELECT 
	location
	,date
	,total_cases
	,total_deaths
	,(total_deaths/total_cases*100) AS death_rate
FROM ..[owid-covid-data]
WHERE location IN('Europe','Asia','North America','South America','Africa','Oceania')
ORDER BY date DESC, location ASC;
/*Death rate by income (per day)*/
SELECT 
	location
	,date
	,total_cases
	,total_deaths
	,(total_deaths/total_cases*100) AS death_rate
FROM ..[owid-covid-data]
WHERE location IN('Low income','Lower middle income','Upper middle income','High income')
ORDER BY date DESC, location ASC;

/*Highest death rate by country*/
SELECT 
	location
	,continent
	,MAX(total_cases) AS highest_total_cases
	,MAX(total_deaths) AS highest_total_deaths
	,MAX(total_deaths)/MAX(total_cases)*100 AS highest_death_rate
FROM ..[owid-covid-data]
WHERE continent is not null
GROUP BY location, population, continent
ORDER BY highest_death_rate DESC;
/*Highest death rate by continent*/
SELECT 
	location 
	,MAX(total_cases) AS highest_total_cases
	,MAX(total_deaths) AS highest_total_deaths
	,MAX(total_deaths)/MAX(total_cases)*100 AS highest_death_rate
FROM ..[owid-covid-data]
WHERE location IN('Europe','Asia','North America','South America','Africa','Oceania')
GROUP BY location, population
ORDER BY highest_death_rate DESC;
/*Highest death rate by income*/
SELECT 
	location
	,MAX(total_cases) AS highest_total_cases
	,MAX(total_deaths) AS highest_total_deaths
	,MAX(total_deaths)/MAX(total_cases)*100 AS highest_death_rate
FROM ..[owid-covid-data]
WHERE location IN('Low income','Lower middle income','Upper middle income','High income')
GROUP BY location, population
ORDER BY highest_death_rate DESC;

/* Countries w/ most deaths (Absolute)*/
SELECT 
	location
	,MAX(total_deaths) AS highest_total_deaths
FROM ..[owid-covid-data]
WHERE continent is not null
GROUP BY location
ORDER BY highest_total_deaths DESC;
/* Continents w/ most deaths (Absolute)*/
SELECT 
	location
	,MAX(total_deaths) AS highest_total_deaths
FROM ..[owid-covid-data]
WHERE location IN('Europe','Asia','North America','South America','Africa','Oceania')
GROUP BY location
ORDER BY highest_total_deaths DESC;
/* Most deaths by income(Absolute)*/
SELECT 
	location
	,MAX(total_deaths) AS highest_total_deaths
FROM ..[owid-covid-data]
WHERE location IN('Low income','Lower middle income','Upper middle income','High income')
GROUP BY location
ORDER BY highest_total_deaths DESC;


/*Infection Analysis*/
/*Infection rate by country (per day)*/
SELECT 
	location
	,continent
	,date
	,total_cases
	,population
	,(total_cases/population*100) AS infection_rate
FROM ..[owid-covid-data]
WHERE continent is not null
ORDER BY date DESC, location ASC;
/*Infection rate by continent (per day)*/
SELECT 
	location
	,date
	,total_cases
	,population
	,(total_cases/population*100) AS infection_rate
FROM ..[owid-covid-data]
WHERE location IN('Europe','Asia','North America','South America','Africa','Oceania')
ORDER BY date DESC, location ASC;
/*Infection rate by income (per day)*/
SELECT 
	location
	,date
	,total_cases
	,population
	,(total_cases/population*100) AS infection_rate
FROM ..[owid-covid-data]
WHERE location IN('Low income','Lower middle income','Upper middle income','High income')
ORDER BY date DESC, location ASC;


/* Countries w/ Highest infection rate */
SELECT 
	location
	,continent
	,population
	,MAX(total_cases) AS highest_total_cases
	,MAX(population) AS highest_population
	,MAX(total_cases)/MAX(population)*100 AS highest_infection_rate
FROM ..[owid-covid-data]
WHERE continent is not null
GROUP BY location, population, continent
ORDER BY highest_infection_rate DESC;
/* Continents w/ Highest infection rate */
SELECT 
	location
	,population, 
	,MAX(total_cases) AS highest_total_cases
	,MAX(population) AS highest_population
	,MAX(total_cases)/MAX(population)*100 AS highest_infection_rate
FROM ..[owid-covid-data]
WHERE location IN('Europe','Asia','North America','South America','Africa','Oceania')
GROUP BY location, population
ORDER BY highest_infection_rate DESC;
/* Highest infection rate by Income*/
SELECT 
	location
	,population
	,MAX(total_cases) AS highest_total_cases
	,MAX(population) AS highest_population
	,MAX(total_cases)/MAX(population)*100 AS highest_infection_rate
FROM ..[owid-covid-data]
WHERE location IN('Low income','Lower middle income','Upper middle income','High income')
GROUP BY location, population
ORDER BY highest_infection_rate DESC;

/* Countries w/ most infections (Absolute)*/
SELECT 
	location
	,MAX(total_cases) AS highest_total_cases
FROM ..[owid-covid-data]
WHERE continent is not null
GROUP BY location
ORDER BY highest_total_cases DESC;
/* Continents w/ most infections (Absolute)*/
SELECT 
	location
	,MAX(total_cases) AS highest_total_cases
FROM ..[owid-covid-data]
WHERE location IN('Europe','Asia','North America','South America','Africa','Oceania')
GROUP BY location
ORDER BY highest_total_cases DESC;
/* Most infections BY income (Absolute)*/
SELECT 
	location
	,MAX(total_cases) AS highest_total_cases
FROM ..[owid-covid-data]
WHERE location IN('Low income','Lower middle income','Upper middle income','High income')
GROUP BY location
ORDER BY highest_total_cases DESC;


/*Global Analysis*/
/*Infection, death and vaccination rate by day*/
WITH VacAndDeathByDay (date, world_population,total_cases,total_deaths,total_vaccinations)
AS (SELECT DISTINCT
		date
		,(SELECT MAX(population) FROM [owid-covid-data] WHERE location = 'World') AS world_population
		,ISNULL(SUM(new_cases) OVER (ORDER BY date),0) AS total_cases
		,ISNULL(SUM(new_deaths) OVER (ORDER BY date),0) AS total_deaths
		,ISNULL(SUM(new_vaccinations) OVER (ORDER BY date),0) AS total_vaccinations
	FROM ..[owid-covid-data]
	WHERE continent is not null
	)
SELECT 
	*
	,total_deaths/total_cases*100 AS death_rate
	,total_cases/world_population*100 AS infection_rate
	,total_vaccinations/world_population*100 AS vaccinations_rate
FROM VacAndDeathByDay
ORDER BY date


/* Creating Auxiliary table for the rolling totals aggregated by location and date*/ 
DROP TABLE IF EXISTS #RollingTotalsByLocation
CREATE TABLE #RollingTotalsByLocation ( 
continent nvarchar(50)
,location nvarchar(50)
,date datetime
,total_population numeric
,new_cases numeric
,new_deaths numeric
,new_vaccinations numeric
,total_cases numeric
,total_deaths numeric
,total_vaccinations numeric
)
/* Inserting Data to Auxiliary table */
INSERT INTO #RollingTotalsByLocation
SELECT
	continent
	,location
	,date
	,MAX(population) 
	,new_cases
	,new_deaths
	,new_vaccinations
	,ISNULL(SUM(new_cases) OVER (PARTITION BY location ORDER BY date),0)
	,ISNULL(SUM(new_deaths) OVER (PARTITION BY location ORDER BY date),0)
	,ISNULL(SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY date),0)
FROM ..[owid-covid-data]
WHERE continent is not null
GROUP BY date, location, continent,new_cases,new_deaths,new_vaccinations

select * from #RollingTotalsByLocation

/*Infection and death rate totals by location*/
SELECT 
	location
	,MAX(total_population) AS total_population
	,MAX(total_cases) AS total_cases
	,MAX(total_deaths) AS total_deaths
	,MAX(total_deaths)/MAX(total_cases)*100 AS death_rate
	,MAX(total_cases)/MAX(total_population)*100 AS infection_rate
FROM #RollingTotalsByLocation
GROUP BY location
ORDER BY total_cases DESC;

/*Vaccinations by country*/
SELECT 
	continent
	,location
	,date
	,total_population
	,new_vaccinations
	,total_vaccinations
FROM #RollingTotalsByLocation
ORDER BY location, date;


/* Creating Views for later visualizations */
CREATE VIEW DeathAndInfectionRatesByCountry AS
SELECT 
	location
	,date
	,total_cases
	,total_deaths
	,(total_deaths/total_cases*100) AS death_rate
FROM ..[owid-covid-data]
WHERE location IN('Low income','Lower middle income','Upper middle income','High income');


CREATE VIEW VaccDeathAndInfectionRatesByDay AS
WITH VacAndDeathByDay (date, world_population,total_cases,total_deaths,total_vaccinations)
AS (SELECT DISTINCT
		date
		,(SELECT MAX(population) FROM [owid-covid-data] WHERE location = 'World') AS world_population
		,ISNULL(SUM(new_cases) OVER (ORDER BY date),0) AS total_cases
		,ISNULL(SUM(new_deaths) OVER (ORDER BY date),0) AS total_deaths
		,ISNULL(SUM(new_vaccinations) OVER (ORDER BY date),0) AS total_vaccinations
	FROM ..[owid-covid-data]
	WHERE continent is not null
	)
SELECT 
	*
	,total_deaths/total_cases*100 AS death_rate
	,total_cases/world_population*100 AS infection_rate
	,total_vaccinations/world_population*100 AS vaccinations_rate
FROM VacAndDeathByDay;
