use PortfolioProject
select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
-- shows likelyhhod of dying if contact
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from PortfolioProject..CovidDeaths
where location = 'India'
order by 1,2

--Looking at total cases vs population
-- percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
where location = 'India'
order by 1,2

--Looking at countries with highest infection rate compared to population
select location, population, Max(total_cases) as highestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'India'
group by location, population
order by PercentagePopulationInfected desc

--showing countries by highest death count per population
select location, max(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'India'
where continent is not null
group by location
order by totalDeathCount desc


-- Breaking it down by continent  (this query including only few countries)
select continent, max(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'India'
where continent is not null
group by continent
order by totalDeathCount desc

-- above query is correctly written down
select location, max(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by totalDeathCount desc

--Global Numbers of deaths by date
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location = 'India'
where continent is not null
group by date
order by 1,2

--total global deaths
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location = 'India'
where continent is not null
--group by date
order by 1,2


--Looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over
(Partition by dea.location order by dea.location, dea.date) as peoplevaccinated --(peoplevaccinated/population)*100 as PeopleVaccinatedPercentage
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
with PopVsVac (continent, location, date, population, new_vaccinations, peoplevaccinated)
as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over
(Partition by dea.location order by dea.location, dea.date) as peoplevaccinated --(peoplevaccinated/population)*100 as PeopleVaccinatedPercentage
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (peoplevaccinated/population)*100 from PopVsVac


--Temp Table
Create table #percentPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
peoplevaccinated numeric
)

Insert into #percentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over
(Partition by dea.location order by dea.location, dea.date) as peoplevaccinated --(peoplevaccinated/population)*100 as PeopleVaccinatedPercentage
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (peoplevaccinated/population)*100 from #percentPeopleVaccinated

--##############using drop
drop table if exists #PercentPeopleVaccinated
Create table #PercentPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
peoplevaccinated numeric
)

Insert into #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over
(Partition by dea.location order by dea.location, dea.date) as peoplevaccinated --(peoplevaccinated/population)*100 as PeopleVaccinatedPercentage
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (peoplevaccinated/population)*100 from #PercentPeopleVaccinated


--creating view to store data for later visualizations

create view PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over
(Partition by dea.location order by dea.location, dea.date) as peoplevaccinated --(peoplevaccinated/population)*100 as PeopleVaccinatedPercentage
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPeopleVaccinated
