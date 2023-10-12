Select * 
from CovidVaccinations
ORDER By 3,4

Select * 
from PortfolioProject..CovidDeaths
ORDER By 3,4

--Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER By 1,2

-- Looking at Total cases vs total Deaths
-- shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location Like '%Australia%'
And continent is not null
ORDER By 1,2

-- Looking at total cases Vs Population
-- Shows what percentage of population got covid

Select location, date, population , total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location Like '%Australia%'
ORDER By 1,2

-- Looking at countries with Highest Infection Rate compared to population

Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS 
	PercentPopulationInfected
from PortfolioProject..CovidDeaths
GROUP BY location, population
Order by PercentPopulationInfected Desc


-- Showing Countries with the highest death count per population

Select location, Max(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group By Location
Order by TotalDeathCount Desc

-- Breaking down By Continent
-- Showing continents with the highest continent by death count

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount Desc

--Global Numbers

Select date, SUM(new_cases) Sum_NewCases, SUM(cast(new_deaths as int)) Sum_NewDeaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 
	as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP By Date
Order by 1,2

-- Location at total population vs Caccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = vac.location
	and dea.date = dea.date
Where dea.continent is not null
Order by 2,3

-- Count of rolling new vaccination each day
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, SUM (cast(new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USE CTE

with  PopvsVac (Continent, Location, date, population, new_vaccination, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (cast(new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Temp Table


DROP TABLE if exists #PercentPopulationaVaccinated 
Create Table #PercentPopulationaVaccinated
(
continent nvarchar(255),
Location nvarchar (255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationaVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (cast(new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationaVaccinated

-- Creating View to Store data for later visulization

Create View PercentPopulationaVaccinated  As

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (cast(new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationaVaccinated