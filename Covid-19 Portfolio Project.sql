SELECT location, date , total_cases, new_cases, total_deaths, population 
FROM Portfolioproject1..deaths
where continent is not NULL
order by 1,2;

--To change data type

ALTER TABLE Portfolioproject1..deaths
ALTER COLUMN total_Deaths float;

-- Total cases vs total deaths
-- Likelihood of dying of Covid in your country

SELECT location, date , total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
FROM Portfolioproject1..deaths
Where location like '%pakistan%'
AND continent is not NULL
order by 1,2;

-- Total cases vs Population

SELECT location, date , population , total_cases, (total_cases/population)*100 as Percentpopulationinfected
FROM Portfolioproject1..deaths
Where location like '%states%'
and continent is not NULL
order by 1,2;

-- Countries with highest infection rate by population

SELECT location, population , MAX(total_cases) as MaximumCases, MAX((total_cases/population))*100 as Percentpopulationinfected
FROM Portfolioproject1..deaths
where continent is not NULL
group by location,population
order by Percentpopulationinfected desc;

-- Countries with highest death percentage per population

SELECT location, population , MAX((total_deaths/population))*100 as Percentpopulationdeaths
FROM Portfolioproject1..deaths
where continent is not NULL
group by location,population
order by Percentpopulationdeaths desc;

-- Highest deaths by country

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM Portfolioproject1..deaths
where continent is not NULL
group by location,population
order by TotalDeathCount desc;

-- Highest deaths by continent

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM Portfolioproject1..deaths
where continent is not NULL
group by continent
order by TotalDeathCount desc;


-- GLOBAL TOTAL DEATHS PERCENTAGE WITH ALL CASES

SELECT SUM(new_cases) as Total_Cases, SUM(new_deaths) as total_Deaths, (SUM(new_deaths))/(SUM(new_cases))*100 as DeathPercentage
FROM Portfolioproject1..deaths
where continent is not NULL
-- group by continent
order by 1,2;


-- JOINING AND ANALYZING TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent, dea.location , dea.date , dea.population , vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location 
,dea.date) as Rollingpeoplevaccinated
FROM Portfolioproject1..deaths dea
JOIN Portfolioproject1..vaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not NULL
order by 2,3;

-- Creating Temporary Table to Calculate ratio b/w population and total vaccination per day.
DROP TABLE if exists VaccinatedPopulationPercentage
CREATE Table VaccinatedPopulationPercentage
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric
)
Insert into VaccinatedPopulationPercentage
SELECT dea.continent, dea.location , dea.date , dea.population , vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location 
,dea.date) as Rollingpeoplevaccinated
FROM Portfolioproject1..deaths dea
JOIN Portfolioproject1..vaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
--where dea.continent is not NULL
--where dea.location like '%pakistan%'
--order by 2;
SELECT *,(rollingpeoplevaccinated/population)*100
from VaccinatedPopulationPercentage;

-- CREATING VIEWS for DATA Visualizations

CREATE VIEW VaccinatedPopulationPercentages AS
SELECT dea.continent, dea.location , dea.date , dea.population , vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location 
,dea.date) as Rollingpeoplevaccinated
FROM Portfolioproject1..deaths dea
JOIN Portfolioproject1..vaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not NULL
--order by 2;

SELECT *
FROM VaccinatedPopulationPercentages
