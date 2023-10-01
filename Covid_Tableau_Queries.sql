/* 
All Queries used for the Tableau Dashboard available here: https://public.tableau.com/views/Porfolio-CovidDashboard/Painel1?:language=en-US&:display_count=n&:origin=viz_share_link
Since Tableau public was used for this project, the queries enumerated below were made on a local SQL Database (MSSQLServer), extracted to an Excel sheet and then uploaded to Tableau 
*/

/* 1. Total Death Rate */

CREATE VIEW TotalDeathRate AS
SELECT
	SUM(new_cases) as total_cases
	, SUM(new_deaths) as total_deaths
	, SUM(new_deaths)/SUM(New_Cases)*100 as death_rate
FROM ..[owid-covid-data]
WHERE continent IS NOT NULL;

-- Next, I'll do a double check based off the world data provided
-- The following query includes International cases, but since the total is less than 0.0000001% different, I'll keep the first query, which allows for a more consistent approach when dealing with countries and continents on the following queries

/* 
SELECT 
	SUM(new_cases) as total_cases
	, SUM(new_deaths) as total_deaths
	, SUM(new_deaths)/SUM(New_Cases)*100 as death_rate
FROM ..[owid-covid-data]
WHERE location = 'World'
ORDER BY total_cases,total_deaths;
*/


/* 2. Total Death Count by Continent*/ 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

CREATE VIEW TotalDeathsByContinent AS
SELECT
	location
	, SUM(new_deaths) as total_deaths_by_continent
FROM ..[owid-covid-data]
WHERE continent IS NULL 
AND location in ('Europe', 'Asia', 'North America','South America','Oceania','Africa')
GROUP BY location;


/* 3. Infection Rate by location*/

CREATE VIEW InfectionRateByLocation AS
SELECT 
	location
	, population
	, ISNULL(MAX(total_cases),0) as highest_infection_count
	, ISNULL(MAX((total_cases/population)),0)*100 as infection_rate
FROM ..[owid-covid-data]
GROUP BY location, population;

-- ISNULL is used because Tableau can misindentify columns with NULL as nvarchar instead of numeric

/* 4. Infection Rate by location each day*/

CREATE VIEW InfectionRateByLocationPerDay AS
SELECT 
	Location
	, Population
	, date
	, ISNULL(MAX(total_cases),0) as highest_infection_count
	, ISNULL(MAX((total_cases/population)),0)*100 as infection_rate
FROM ..[owid-covid-data]
GROUP BY Location, Population, date;

-- We got to a point where the infection rate can surpass 100%, since people are getting reinfected due to new variants and an overall decrease in letallity
