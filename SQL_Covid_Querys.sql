SELECT *
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 3,4

-- Select the data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 1,2 -- Order by location and date


-- Looking at the Total Cases Vs total Deaths
-- Shows the likelihood of dying if you contract covid in the United Kingdom
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where location = 'United Kingdom'
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population has gotten covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS CovidCasePercentage
FROM PortfolioProject.dbo.CovidDeaths
Where location = 'United Kingdom'
order by 1,2


-- Exploring countries which have highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PopulationInfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by Location, population
order by PopulationInfectedPercentage DESC


-- Shows countries with the highest death count per population
SELECT Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount DESC

-- Breaking data down by continent
-- Showing the continents with the highest death count

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount DESC


-- GLOBAL NUMBERS

-- Per day

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as int)) AS Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage  
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
Group by date
order by 1,2

-- Total cases and deaths worldwide

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as int)) AS Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
order by 1,2


-- Joining Covid Deaths & Vaccinations tables

SELECT *
FROM PortfolioProject.dbo.CovidDeaths AS D
JOIN PortfolioProject.dbo.CovidVaccinations AS V
ON D.location = V.location
and D.date = V.date

-- Looking at Total Population vs Vacinations
-- Starting query to get rolling count of vaccinations partitioned by location and date

SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CAST(V.new_vaccinations as bigint)) OVER (Partition by D.location Order by D.Location, D.Date ROWS UNBOUNDED PRECEDING) AS Rolling_Count_of_Vaccinations
FROM PortfolioProject.dbo.CovidDeaths AS D
JOIN PortfolioProject.dbo.CovidVaccinations AS V
	ON D.location = V.location
	and D.date = V.date
WHERE D.continent is not null
order by 2,3

-- USE CTE or 'Common Table Expression'
-- Note, Vaccination percentage will go over 100% in some cases as people recieve more than one vaccine dose

WITH PopvsVac (continent, location, date, population, new_vaccinations, Rolling_Count_of_Vaccinations)
as 
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CAST(V.new_vaccinations as bigint)) OVER (Partition by D.location Order by D.Location, D.Date ROWS UNBOUNDED PRECEDING) AS Rolling_Count_of_Vaccinations
FROM PortfolioProject.dbo.CovidDeaths AS D
JOIN PortfolioProject.dbo.CovidVaccinations AS V
	ON D.location = V.location
	and D.date = V.date
WHERE D.continent is not null
)
SELECT *, (Rolling_Count_of_Vaccinations/population)*100 AS Percent_of_population_with_vaccine_dose
FROM PopvsVac


--Temp TABLE
-- Have to specify data type as well

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_Count_of_Vaccinations numeric
)


Insert into #PercentPopulationVaccinated

SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CAST(V.new_vaccinations as bigint)) OVER (Partition by D.location Order by D.Location, D.Date ROWS UNBOUNDED PRECEDING) AS Rolling_Count_of_Vaccinations
FROM PortfolioProject.dbo.CovidDeaths AS D
JOIN PortfolioProject.dbo.CovidVaccinations AS V
	ON D.location = V.location
	and D.date = V.date
WHERE D.continent is not null

SELECT *, (Rolling_Count_of_Vaccinations/population)*100 AS Percent_of_population_with_vaccine_dose
FROM #PercentPopulationVaccinated

--Dropping tables
--here we 'drop' the table before making alterations, this way you don't have to delete the tempttable every tinme

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_Count_of_Vaccinations numeric
)


Insert into #PercentPopulationVaccinated

SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CAST(V.new_vaccinations as bigint)) OVER (Partition by D.location Order by D.Location, D.Date ROWS UNBOUNDED PRECEDING) AS Rolling_Count_of_Vaccinations
FROM PortfolioProject.dbo.CovidDeaths AS D
JOIN PortfolioProject.dbo.CovidVaccinations AS V
	ON D.location = V.location
	and D.date = V.date
WHERE D.continent is not null

SELECT *, (Rolling_Count_of_Vaccinations/population)*100 AS Percent_of_population_with_vaccine_dose
FROM #PercentPopulationVaccinated

--Creating views to store data for later visualizations
--Unlike temptables views are permanent


Create View PercentPopulationVaccinated as
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CAST(V.new_vaccinations as bigint)) OVER (Partition by D.location Order by D.Location, D.Date ROWS UNBOUNDED PRECEDING) AS Rolling_Count_of_Vaccinations
FROM PortfolioProject.dbo.CovidDeaths AS D
JOIN PortfolioProject.dbo.CovidVaccinations AS V
	ON D.location = V.location
	and D.date = V.date
WHERE D.continent is not null



SELECT *
FROM PercentPopulationVaccinated



