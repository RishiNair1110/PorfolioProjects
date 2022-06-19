--Likelihood of death if affected by covid-19 in the State of Qatar
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..[Covid Deaths]
Where location like '%qatar%'
order by 1,2

--Total cases v/s Population
--Shows percentage of population that were tested positive
Select location, date, population, total_cases, (total_deaths/population)*100 as AffectedPercentage
From [Portfolio Project]..[Covid Deaths]
Where location like '%qatar%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..[Covid Deaths]
Group by location,population
order by PercentPopulationInfected desc

--Looking at Countries with Highest Death Rate compared to population
Select location, population, MAX(total_deaths) as TotalDeathCount, MAX((total_deaths/population))*100 as PercentPopulationDead
From [Portfolio Project]..[Covid Deaths]
Group by location,population
order by PercentPopulationDead desc

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..[Covid Deaths]
Where continent is null
Group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..[Covid Deaths]
Where continent is not null
Group by continent
order by TotalDeathCount desc 

--Showing continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..[Covid Deaths]
Where continent is not null
Group by continent
order by TotalDeathCount desc 

--Global Numbers

Select  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..[Covid Deaths]
--Where location like '%qatar%'
where continent is not null
--Group by date
order by 1,2


--Looking at total population v/s vaccinations
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
-- , SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
--   dea.date) as Rolling_People_Vaccinated
----, (Rolling_People_Vaccinated/population)*100
-- From [Portfolio Project]..[Covid Deaths] dea
-- Join [Portfolio Project]..[Covid Vaccinations] vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3



--USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, Rolling_People_Vaccinated)
as 
(
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
   dea.date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
 From [Portfolio Project]..[Covid Deaths] dea
 Join [Portfolio Project]..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (Rolling_People_Vaccinated/Population)*100
from PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)


Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
   dea.date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
 From [Portfolio Project]..[Covid Deaths] dea
 Join [Portfolio Project]..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

Select *, (Rolling_People_Vaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating View
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
   dea.date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
 From [Portfolio Project]..[Covid Deaths] dea
 Join [Portfolio Project]..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select * 
From PercentPopulationVaccinated