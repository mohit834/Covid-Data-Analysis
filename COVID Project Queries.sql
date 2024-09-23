SELECT *
from [Portfolio project]..CovidDeaths
where continent is not null
order by 3, 4

--select * from [Portfolio project]..CovidVaccinations
--order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio project]..CovidDeaths
order by 1, 2

--Looking at the Total cases vs Total deaths
--Shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths
where location like 'India' 
order by 1, 2

--Looking at total cases vs population
--Shows the percentage affected by covid
select location, date, total_cases, population, (total_cases/population)*100 as AffectedPercentage
From [Portfolio project]..CovidDeaths
where location like 'India'
order by 1, 2


--Looking at countries with highest interest rates compared to population
select location, population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as AffectedPercentage
From [Portfolio project]..CovidDeaths
--where location like 'India'
Group by Location, population
order by AffectedPercentage desc


--LET'S BREAK THINGS DOWN BY CONTINENT



-- Showing the Continents with the highest Death Count
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio project]..CovidDeaths
--where location like 'India'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
From [Portfolio project]..CovidDeaths
--where location like 'India' 
where continent is not null
--Group by date
order by 1, 2


--Looking at total populaiton vs vaccinations completed
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths dea
JOIN [Portfolio project]..CovidVaccinations vac
	on  dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null-- and dea.location = 'canada'
order by 2, 3


--USE CTE
with popVsVac (continent, location, date, population, New_vaccinations, rollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths dea
JOIN [Portfolio project]..CovidVaccinations vac
	on  dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null-- and dea.location = 'canada'
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population) * 100 as VaccinatedPercentage
from popVsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
ROllingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths dea
JOIN [Portfolio project]..CovidVaccinations vac
	on  dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null-- and dea.location = 'canada'
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population) * 100 as VaccinatedPercentage
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths dea
JOIN [Portfolio project]..CovidVaccinations vac
	on  dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null-- and dea.location = 'canada'
--order by 2, 3

SELECT * 
From PercentPopulationVaccinated order by 2,3