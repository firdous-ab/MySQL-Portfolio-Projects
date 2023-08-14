SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4


-- SELECT *
-- FROM PortfolioProject.dbo.CovidVaccinations
-- ORDER BY 3, 4

-- Slect the data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Total cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location like '%Nigeria%' AND continent IS NOT NULL
ORDER BY 1, 2


-- Looking at the Total cases vs Population
-- Shows what percentage of the population has gotten covid
SELECT Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE Location like '%Nigeria%'
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Looking at countries with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE Location like '%Nigeria%'
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- -- LET'S BREAK THINGS DOWN BY CONTINENT
-- -- Showing countries with highest death count per population
-- SELECT Location,  Max(total_cases) as TotalCaseCount, MAX(total_deaths) as TotalDeathCount
-- FROM PortfolioProject.dbo.CovidDeaths
-- -- WHERE Location like '%Nigeria%'
-- WHERE continent IS NOT NULL
-- GROUP BY Location
-- ORDER BY TotalCaseCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing continents with the highest death counts per population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE Location like '%Nigeria%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT
    SUM(new_cases) as total_cases,
    SUM(new_deaths) as total_deaths,
    CASE
        WHEN SUM(new_cases) > 0 THEN (SUM(new_deaths) * 100.0) / SUM(new_cases)
        ELSE 0  -- Handle the case where new_cases is zero to avoid division by zero
    END as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1, 2;


-- Looking at total population vs vaccinations

-- COVID VACCINATIONS

-- USE CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(Cast(cv.new_vaccinations as float)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
    ON cd.Location = cv.Location
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
-- ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_Vaccinations numeric,
    RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(Cast(cv.new_vaccinations as float)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
    ON cd.Location = cv.Location
    AND cd.date = cv.date
-- WHERE cd.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- CREATING VIEW TO STOR DATA FOR LATER VISUALIZATIONS
GO
CREATE VIEW PercentPopulationVaccinated 
AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(Cast(cv.new_vaccinations as float)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
    ON cd.Location = cv.Location
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
-- ORDER BY 2, 3
