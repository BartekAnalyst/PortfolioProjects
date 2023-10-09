select* 
from PortfolioProject..CovidDeaths
order  by 3,4

select* 
from PortfolioProject..CovidVaccination
order  by 3,4

-- Select Data what we are going to be using 

select location,date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
where Location like 'Poland'
order by 1,2


-- Looking at Total Cases vs Population 
-- Shows what percentage of population got Covid 

select location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where Location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population 
select location, Population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as 
PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
Order by PercentPopulationInfected desc

 
-- Showing Countries with Highest Death Count per Population 

select location, max(total_deaths) as TotalDeathCount 
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- Showing contintents with the highers death count per population 
select continent, max(total_deaths) as TotalDeathCount 
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc 


--	GLOBAL NUMBERS 

select sum(new_cases) as Total_cases, sum(new_deaths) as Total_deaths, sum(new_deaths)/sum(new_cases)*100  as DeathPercentage 
From PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- LET'S JONI TWO TABLES TOGETER 
 
select *
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location 
   and dea.date = vac.date 


  -- Looking at Total Population vs Vaccinations 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RoolingPeopleVaccinated
--, (RoolingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location 
   and dea.date = vac.date 
where dea.continent is not null 
-- where vac.new_vaccinations is not null and dea.continent is not null 
   order by 2,3

 
-- USE CTE 
with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RoolingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RoolingPeopleVaccinated
--, (RoolingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location 
   and dea.date = vac.date 
where dea.continent is not null 
---order by 2,3
 )

select * , (RoolingPeopleVaccinated/Population)*100 
from PopvsVac


-- TEMP TABLE 
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
RoolingPeopleVaccinated numeric
) 


Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RoolingPeopleVaccinated
--, (RoolingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location 
   and dea.date = vac.date 
-- where dea.continent is not null 
-- order by 2,3

select * , (RoolingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated


-- Creating View to store data for later visalizations 

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RoolingPeopleVaccinated
--, (RoolingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location 
   and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3


Select * 
from PercentPopulationVaccinated