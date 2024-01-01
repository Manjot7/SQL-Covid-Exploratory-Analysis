SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECTING DATA TO BE USED

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--TOTAL CASES VS DEATHS COMPARISON - Likelihood of Death

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--TOTAL CASES VS POPULATION COMPARISON - Percentage of Population that contracted Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS Case_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'India'
ORDER BY 1,2

--HIGHEST CONTRACTION RATE

SELECT location, MAX(total_cases) AS Max_Contraction_Count, population, (MAX(total_cases)/population)*100 AS Case_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

--HIGHEST DEATH RATE

SELECT location, MAX(cast(total_deaths as int)) AS Max_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--CONTINENT COMPARISON

SELECT continent, MAX(cast(total_deaths as int)) AS Max_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

--GLOBAL NUMBERS BREAKDOWN

--CASES AND DEATHS BY DATE

SELECT date, SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--GLOBAL DEATH PERCENTAGE

SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



--VACCINATIONS DATA

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

--JOINING TABLES

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

--POPULATION VS VACCINATIONS COMPARISON

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--VACCINATION NUMBERS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Sum_Vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--CREATING A TEMP TABLE

DROP TABLE IF EXISTS #PopulationVaccinated

CREATE TABLE #PopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
sum_vaccinations numeric
)

INSERT INTO #PopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Sum_Vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (Sum_Vaccinations/population)*100 AS Percentage_Vaccinated
FROM #PopulationVaccinated
ORDER BY 2,3


--VISUALISATION - CREATING VIEWS

CREATE VIEW PopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Sum_Vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

CREATE VIEW ContinentDeaths AS
SELECT continent, MAX(cast(total_deaths as int)) AS Max_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent

CREATE VIEW LocationDeaths AS
SELECT location, MAX(cast(total_deaths as int)) AS Max_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location