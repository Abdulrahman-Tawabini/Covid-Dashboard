select *
from PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

select *
from PortfolioProject..Covidvaccinations
Order by 3,4

-- Select Data that we are going to be using
select location, date, total_cases, New_cases, total_deaths, population
from PortfolioProject..Coviddeaths
Where continent is not null
Order By 1,2


-- Looking Total Cases vs Total Deaths
-- Shows the likelyhood of death if one got infected
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..Coviddeaths
Where location like '%bahrain%'
and continent is not null
Order By 1,2


-- looking at the total cases vs the population
-- shows what percentage of population got covid 
select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..Coviddeaths
Where location like '%bahrain%'
and continent is not null
Order By 1,2

-- looking at contries with highest infection rate compared to population
select location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 as InfectedPercentage
from PortfolioProject..Coviddeaths
Where continent is not null
Group by location,population
Order By InfectedPercentage desc

-- showing the contries with the highest deathcount per population
select location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order By TotalDeathCount desc


--showing the continents with the highest death count per population
select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order By TotalDeathCount desc


--global numbers
select SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..Coviddeaths
where continent is not null
--Group by date
Order By 1,2


--Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent is not null
  Order by 2,3


  --USE CTE
  with PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
  as
  (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent is not null
 -- Order by 2,3
 )
 select *, (RollingPeopleVaccinated/population)*100
 from PopvsVac



 --Tempt table
 Drop Table if exists #PercentPopulationVaccinated
 create table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccination numeric,
 RollingPeopleVaccinated numeric,
 )
 insert into #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
 -- WHERE dea.continent is not null
 -- Order by 2,3
select *, (RollingPeopleVaccinated/population)*100
 from #PercentPopulationVaccinated


 --creating view to store data for later visualizations
 create view PercentPopulationVaccinated as  
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
 WHERE dea.continent is not null
 --Order by 2,3

 SELECT *
 FROM PercentPopulationVaccinated