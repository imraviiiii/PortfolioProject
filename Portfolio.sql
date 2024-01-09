Select *
From PortfolioProject..CovidDeaths
Where continent IS NOT NULL
Order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--Where continent IS NOT NULL
--Order by 3, 4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent IS NOT NULL
Order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (cast(total_deaths as int)/cast(total_cases as int)) as DeathPercentage
From CovidDeaths
WHERE location like '%india%' AND continent IS NOT NULL
Order by 1, 2

-- Looking at Total Cases vs Population
Select location, date, total_cases, population, (cast(total_cases as int)/population)*100 as PopulationPercentage
From CovidDeaths
WHERE location like '%india%' AND continent IS NOT NULL
Order by 1, 2

-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
From CovidDeaths
Where continent IS NOT NULL
Group by location, population
Order by PercentPopulationInfected Desc

-- Showing countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From CovidDeaths
Where continent IS NOT NULL
Group by location
Order by TotalDeathCount Desc

-- Let's break things down by continent
-- Showing continent with highest death count per population

Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..covidDeaths
Where continent IS NOT NULL
Group by location
Order by TotalDeathCount Desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
From CovidDeaths
-- WHERE location like '%india%' AND
WHERE continent IS NOT NULL
--GROUP BY date
--Order by 1, 2


---------------------------------------------
Select *
From CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date


-- Looking at Total population vs vaccinations
-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECt *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECt *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--VIEW

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECt *
From PercentPopulationVaccinated