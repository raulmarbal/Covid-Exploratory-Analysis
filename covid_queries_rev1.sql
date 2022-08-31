SELECT *
FROM covid_project..covid_deaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

---- Select data we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_project..covid_deaths$
WHERE continent IS NOT NULL
ORDER BY 1,2 

-- Total cases vs Total deaths (death percentage of covid in the United States)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid_project..covid_deaths$
WHERE location = 'United States' AND continent IS NOT NULL
ORDER BY 2

-- Total cases vs Population (percentage of population with covid in the United States)
SELECT location, date, population, total_cases, (total_cases/population)*100 AS cases_percentage
FROM covid_project..covid_deaths$
WHERE location = 'United States' AND continent IS NOT NULL
ORDER BY 2 

-- Countries with highest rate of cases compared to population
SELECT location, population, MAX(total_cases) AS max_cases, MAX((total_cases/population)*100) AS max_cases_percentage
FROM covid_project..covid_deaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_cases_percentage DESC

-- Countries with highest death count per population
SELECT location, population, MAX(CAST(total_deaths as int)) AS max_deaths -- Issue with total_deaths column, need to put cast as int
FROM covid_project..covid_deaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_deaths DESC

-- Countries with highest rate of deaths compared to population 
SELECT location, population, MAX(CAST(total_deaths as int)) AS max_deaths, MAX((total_deaths/population)*100) AS max_deaths_percentage
FROM covid_project..covid_deaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_deaths_percentage DESC

-- Continents with highest death count per population
SELECT continent, MAX(CAST(total_deaths as int)) AS max_deaths
FROM covid_project..covid_deaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY max_deaths DESC

-- Population vs vaccinations 
-- Use CTE (like a temporary table with the columns you input)
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, agg_sum_new_vacs) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
     SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS agg_sum_new_vacs 
	 -- aggregate sum of total new vaccinations partition by country and order by location and date
FROM covid_project..covid_deaths$ AS dea
JOIN covid_project..covid_vaccinations$ AS vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY dea.location, dea.date
)
SELECT *, (agg_sum_new_vacs/population)*100 AS new_vacs_percentage
FROM pop_vs_vac


-- Creating View to store data for later visualizations
CREATE VIEW percent_population_vaccinated AS
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, agg_sum_new_vacs) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
     SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS agg_sum_new_vacs 
	 -- aggregate sum of total new vaccinations partition by country and order by location and date
FROM covid_project..covid_deaths$ AS dea
JOIN covid_project..covid_vaccinations$ AS vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY dea.location, dea.date
)
SELECT *, (agg_sum_new_vacs/population)*100 AS new_vacs_percentage
FROM pop_vs_vac
