/*
Covid 19 Data Exploration
Skills demonstrated: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


Select *
From PortfolioProject1..CovidDeaths
Where continent is not null
order by 3,4

-- Select Starting Data

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject1..CovidDeaths
Where continent is not null
Order by 1,2


-- Looking at Total Cases vs Total Deaths in South Africa (Death Rate %)
-- Likelihood of death resulting from infection

Select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathRate
from PortfolioProject1..CovidDeaths
Where location like 's%africa%'
and continent is not null
Order by 1,2

-- Looking at Total Cases vs Population In South Africa (Population Infection Rate %)
-- Percentage of population infected

Select location, date, total_cases, population, (total_cases / population)*100 as PopulationInfectionRate
from PortfolioProject1..CovidDeaths
Where location like 's%africa%'
Order by 1,2


-- Looking at Countries with Highest Infection Rate vs Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases / population))*100 as PopulationInfectionRate
from PortfolioProject1..CovidDeaths
Where continent is not null
Group By location, population
Order by PopulationInfectionRate desc

-- Looking at Countries with Highest Death Count for respective Population

Select location, Max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
Where continent is not null
Group By location
Order by TotalDeathCount desc

-- Countries with Highest Death Count for respective Population, represented by respective Continents

Select continent, Max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
Where continent is not null
Group By continent
Order by TotalDeathCount desc

-- Ranking Continents' Total Death Counts

Select location, Max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
Where continent is null
Group By location
Order by TotalDeathCount desc

-- Global Death Rate Percentage

Select Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathRate
from PortfolioProject1..CovidDeaths
Where continent is not null 
Order by 1,2


-- Looking at Total Population vs Vaccinations (Vaccination Rate %)
-- Percentage of population that received at least one Covid vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition By dea.location Order By dea.location, dea.date) as CountingTotalVaccines
--, (RollingPeopleVaccinated/population)*100
-- The line above produces an error. Two solutions are given in the queries below below.
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--Using CTE

With PopvsVac (continent, location, date, population, new_vaccinations, CountingTotalVaccines)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition By dea.location Order By dea.location, dea.date) 
as CountingTotalVaccines
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (CountingTotalVaccines/population)*100 as VaccinationRate
From PopvsVac


-- Using a Temp Table

Drop table if exists #Vacc_rates
Create table #Vacc_rates
(
continent nvarchar(255),
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
CountingTotalVaccines numeric
)

Insert into #Vacc_rates
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition By dea.location Order By dea.location, dea.date) 
as CountingTotalVaccines
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select *, (CountingTotalVaccines/population)*100 as VaccinationRate
From #Vacc_rates



-- Creating View to Store Data for Later Visualisations

Create View VaccinationRates as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition By dea.location Order By dea.location, dea.date) 
as CountingTotalVaccines
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From VaccinationRates