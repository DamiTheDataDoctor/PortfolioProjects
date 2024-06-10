
-- Select Data 
Select Location, date, cast(total_cases as float), new_cases, cast(total_deaths as float), population
From PortfolioProject..CovidDeaths
where continent <> ''
Order by 1,2

-- Total Cases vs Total Deaths
-- Likelihood of dying if you contract covid 
Select Location, cast(date as datetime), total_cases, total_deaths, (cast(total_deaths as float)/NULLIF(cast(total_cases as float),0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%' and continent <> ''
Order by 1,2

-- Total Cases vs Population
-- Percentage of population got covid
Select Location, cast(date as datetime), population,total_cases,  (cast(total_cases as float)/NULLIF(cast(population as float),0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent <> ''
Order by 1,2


-- Countries with hghest infection rates compared to population
Select Location,  population, max(cast(total_cases as float)) as HighestInfectionCount,  max((cast(total_cases as float)/NULLIF(cast(population as float),0))*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent <> ''
group by continent, population
Order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
Select Location, max(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent <> ''
group by continent
Order by TotalDeathCount desc


-- Continent View

-- Continent with Highest death count per population
Select cast(date as datetime) as date,sum(cast(new_cases as float)) as total_cases, sum(cast(new_deaths as float)) as total_deaths, 
	(sum(cast(new_deaths as float))/nullif(sum(cast(new_cases as float)),0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent <> ''
group by date
Order by 1,2


Select sum(cast(new_cases as float)) as total_cases, sum(cast(new_deaths as float)) as total_deaths, 
	(sum(cast(new_deaths as float))/nullif(sum(cast(new_cases as float)),0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent <> ''
--group by date
Order by 1,2


-- Join CovidDeath and CovidVaccination tables
-- Total Population vs Vaccinations
select dea.continent, dea.location, cast(dea.date as datetime) as date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, cast(dea.date as datetime)) as RollingPeopleVacinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent <> ''
order by 2,3


-- Use CTE

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(
select dea.continent, dea.location, cast(dea.date as datetime) as date, cast(dea.population as float) population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, cast(dea.date as datetime)) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent <> ''
)
select *, (RollingPeopleVaccinated/nullif(population,0))*100
from PopVsVac

-- Temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations float,
RollingPeopleVaccinated float
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, cast(dea.date as datetime) as date, cast(dea.population as float) population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, cast(dea.date as datetime)) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent <> ''

select *, (RollingPeopleVaccinated/nullif(population,0))*100
from #PercentPopulationVaccinated


-- Create view for viz
create view PercentPopulationVaccinated as
select dea.continent, dea.location, cast(dea.date as datetime) as date, cast(dea.population as float) population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, cast(dea.date as datetime)) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent <> ''

select *
from PercentPopulationVaccinated