Select *
From PortfolioProject.dbo.CovidDeaths
order by 3,4
--Death rate from infected cases
Select location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeatPercentage
from CovidDeaths 
Where location like'%states%'
order by 1,2

--Looking at the total cased vs population
Select location, Date, total_cases, population,(total_deaths/population)*100 as DeathPercentage
from CovidDeaths 
Where location like'%states%'
order by 1,2

Select location, population, Max(total_cases) as InfectionHigh, MAX((total_cases/population))*100
as Infectionhighpercentage from CovidDeaths 
--Where location like'%states%'
group by location, population
order by Infectionhighpercentage desc

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths 
--Where location like'%states%'
Where continent is not null
group by location
order by TotalDeathCount desc

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths 
--Where location like'%states%'
Where continent is not null
group by continent
order by TotalDeathCount desc

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths 
--Where location like'%states%'
Where continent is not null
order by 1,2

--Use CTE
 With DeaVac (continent, location, date, population, new_vaccinations, cummvac)
 as (Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as cummvac
From CovidDeaths dea
join CovidVaccinations vac 
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null)
--Order by 2,3
Select *, (cummvac/population)*100 from DeaVac


--Create Table
Drop Table if exists PercentVaccinatedPeople
Create Table PercentVaccinatedPeople
(Continent nvarchar (255),
Location nvarchar (255),
date date,
Population numeric,
New_Vaccinations numeric,
cummvac numeric)

Insert into PercentVaccinatedPeople
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as cummvac
From CovidDeaths dea
join CovidVaccinations vac 
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

Select *, (cummvac/population)*100 as cummvacpercentage
From PercentVaccinatedPeople

--Create view to store data for visualizations

Create View RollingVacc as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as cummvac
From CovidDeaths dea
join CovidVaccinations vac 
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

