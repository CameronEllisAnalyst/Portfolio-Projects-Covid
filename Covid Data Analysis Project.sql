SELECT *
FROM Covid_Deaths_Table
WHERE continent is not NULL
ORDER BY 3,4

-- SELECT *
-- FROM CovidVaccinationsTable
-- ORDER BY 3,4

-- Select Data that we are going to be using 

SELECT location, date_column, total_cases, new_cases, total_deaths, population
FROM Covid_Deaths_Table
order by 1,2

-- Looking at total cases vs total deaths

SELECT location, date_column, total_cases, total_deaths, (CAST(total_deaths AS REAL) /total_cases) * 100 AS DeathPercentage
FROM Covid_Deaths_Table
WHERE location LIKE '%states%' and continent is not NULL
order by 1,2

-- Looking at Total Cases Vs. Population

SELECT location, date_column, total_cases, population, (CAST(total_cases AS REAL) /population) * 100 AS percent_of_population_infected
FROM Covid_Deaths_Table
WHERE location LIKE '%states%'
order by 1,2

-- Looking at Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS Highest_Infenction_Count, MAX((CAST(total_cases AS REAL)) /population) * 100 AS percent_of_population_infected
FROM Covid_Deaths_Table
GROUP BY 1, 2
ORDER BY 4 DESC

-- Showing Countries with Highest Death Count per population

SELECT location, MAX(CAST(total_deaths as INT)) AS total_death_count
FROM Covid_Deaths_Table
WHERE continent is not NULL
GROUP BY location
ORDER BY total_death_count DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(CAST(total_deaths as INT)) AS total_death_count
FROM Covid_Deaths_Table
WHERE continent is NULL
GROUP BY location
ORDER BY total_death_count DESC

-- Showing the continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as INT)) AS total_death_count
FROM Covid_Deaths_Table
WHERE continent is not NULL
GROUP BY continent
ORDER BY total_death_count DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, sum(CAST(new_deaths AS REAL)) / sum(new_cases) * 100 AS DeathPercentage
FROM Covid_Deaths_Table
WHERE continent is not NULL
--GROUP BY date_column
order by 1,2

-- Looking at Total Population vs. Vaccinations

SELECT dea.continent, dea.location, dea.date_column, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date_column) AS rolling_people_vaccinated
, --(rolling_people_vaccinated/dea.population)*100
FROM Covid_Deaths_Table dea
JOIN CovidVaccinationsTable vac
ON dea.location = vac.location
AND dea.date_column = vac.date_column
WHERE dea.continent is not NULL
order by 2,3


-- USE CTE

WITH PopvsVac (continent, location, date_column, population, new_vaccinations, rolling_people_vaccinated)
AS (
SELECT dea.continent, dea.location, dea.date_column, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date_column) AS rolling_people_vaccinated
 --(rolling_people_vaccinated/dea.population)*100
FROM Covid_Deaths_Table dea
JOIN CovidVaccinationsTable vac
ON dea.location = vac.location
AND dea.date_column = vac.date_column
WHERE dea.continent is not NULL)
-- order by 2,3
SELECT *, (CAST(rolling_people_vaccinated AS REAL) / population)*100
FROM PopvsVac


-- TEMP TABLE

CREATE TABLE Percent_Population_Vaccinated
(
Continent TEXT, 
location TEXT, 
date_column datetime, 
Population NUMERIC,
new_vaccinations NUMERIC,
rolling_people_vaccinated NUMERIC
)

Insert INTO Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date_column, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date_column) AS rolling_people_vaccinated
 --(rolling_people_vaccinated/dea.population)*100
FROM Covid_Deaths_Table dea
JOIN CovidVaccinationsTable vac
ON dea.location = vac.location
AND dea.date_column = vac.date_column
--WHERE dea.continent is not NULL
-- order by 2,3


SELECT *, (CAST(rolling_people_vaccinated AS REAL) / population)*100
FROM Percent_Population_Vaccinated


-- Creating view to store data for later visualizations

CREATE VIEW Percent_Population_Vaccinated_View AS 
SELECT dea.continent, dea.location, dea.date_column, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date_column) AS rolling_people_vaccinated
 --(rolling_people_vaccinated/dea.population)*100
FROM Covid_Deaths_Table dea
JOIN CovidVaccinationsTable vac
ON dea.location = vac.location
AND dea.date_column = vac.date_column
WHERE dea.continent is not NULL
--order by 2,3

SELECT *
FROM Percent_Population_Vaccinated_View
