-- DEATH STATISTICS
select * from CovidDeaths
order by 3,4

-- select the data to use
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

-- looking at total cases vs total deaths
-- shows likelihood of dying from covid-19 in australia up to 30 April 2021
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
from CovidDeaths
where location = 'Australia' and continent is not null
order by 1,2

-- looking at total cases vs population
-- total percentage of the population contracting covid-19
select location, date, population, total_cases, (total_cases/population)*100 as infected_population_percentage
from CovidDeaths
where location = 'Australia' and continent is not null
order by 1,2

-- countries with highest infection rate compared to population
select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as infected_population_percentage
from CovidDeaths
where continent is not null
group by location, population
order by infected_population_percentage desc

-- showing countries wiht highest death count per population
select location, max(cast(total_deaths as int)) as total_death_count
from CovidDeaths
where continent is not null
group by location
order by total_death_count desc


-- break down by continent
select location, max(cast(total_deaths as int)) as total_death_count
from CovidDeaths
where continent is null
group by location
order by total_death_count desc

-- break down by continent - max death count per continent
select continent, max(cast(total_deaths as int)) as total_death_count
from CovidDeaths
where continent is not null
group by continent
order by continent desc

-- daily global numbers
select date,sum(new_cases) as global_total_cases, sum(cast(new_deaths as int)) as global_total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage -- total_cases, total_deaths, (total_deaths/total_cases)*200 as death_percentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

-- total cases and deaths
select sum(new_cases) as global_total_cases, sum(cast(new_deaths as int)) as global_total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage -- total_cases, total_deaths, (total_deaths/total_cases)*200 as death_percentage
from CovidDeaths
where continent is not null
order by 1,2

-- VACCINATION STATISTICS
select * from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

-- total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccination_number
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- total population vaccinated - using CTE
with popvsvac (continent, location, date, population, new_vaccinations, rolling_vaccination_number)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccination_number
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
---order by 2,3
)
select *, (rolling_vaccination_number/population)*100
from popvsvac

-- creating views for visualisation
create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as rolling_vaccination_number
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 