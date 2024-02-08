SELECT *
FROM PortfolioProjects..CovidDeaths
where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProjects..CovidVaccinations
--ORDER BY 3,4

SELECT location, date,total_cases,new_cases,total_deaths,population
FROM PortfolioProjects..CovidDeaths
where continent is not null
ORDER BY 1,2

--TOTAL CASES VS TOTAL DEATH
--show likelihood of dying if you contract covid in your contry
SELECT location,continent date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS deathpercentage
FROM PortfolioProjects..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--looking at total case vs population
--shows that population that got covid

SELECT location, date,total_cases,population,(total_cases/population)*100 AS percentagepopulationinfected
FROM PortfolioProjects..CovidDeaths
--WHERE location LIKE '%states%'
where continent is not null
ORDER BY 1,2

--counrty with highest infection rate compared to population

SELECT location,population, MAX(total_cases) as Highestinfectioncount, MAX(total_cases/population)*100 AS percentagepopulationinfected
FROM PortfolioProjects..CovidDeaths
--WHERE location LIKE '%states%'
where continent is not null
GROUP BY location,population
ORDER BY percentagepopulationinfected DESC

--country with the highest death count per population

SELECT location, MAX (cast(total_deaths as int)) as totaldeathcount
FROM PortfolioProjects..CovidDeaths
--WHERE location LIKE '%states%'
where continent is not null
GROUP BY location
ORDER BY totaldeathcount DESC

--LETS BRAKE THINGS BY CONTINENT

--CONTINENT WITH THE HIGHEST DEATHCOUNT PER POPULATION

SELECT continent, MAX (cast(total_deaths as int)) as totaldeathcount
FROM PortfolioProjects..CovidDeaths
--WHERE location LIKE '%states%'
where continent is not null
GROUP BY continent
ORDER BY totaldeathcount DESC


--GLOBAL NUMBERS

SELECT SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeath,SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS deathpercentage
FROM PortfolioProjects..CovidDeaths
--WHERE location LIKE '%states%'
where continent is not null
--GROUP BY date
ORDER BY 1,2

--total population vs vaccination

SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations
, SUM(CONVERT(INT,Vac.new_vaccinations)) OVER (Partition by Dea.location order by Dea.location, Dea.date) AS Rollingpeoplevaccinated
,(Rolligpeoplevaccinated/population)*100
FROM PortfolioProjects..CovidDeaths Dea
join PortfolioProjects..CovidVaccinations Vac 
ON Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
order by 2,3


--using CTE

WITH popvsvac (continent, location,Date,Population,new_vaccination, Rolligpeoplevaccinated)
as
(
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations
, SUM(CONVERT(INT,Vac.new_vaccinations)) OVER (Partition by Dea.location order by Dea.location, Dea.date) AS Rollingpeoplevaccinated
--,(Rolligpeoplevaccinated/population)*100
FROM PortfolioProjects..CovidDeaths Dea
join PortfolioProjects..CovidVaccinations Vac 
ON Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3
)
select*,(Rolligpeoplevaccinated/Population)*100
From popvsvac


--TEMP TABLE 
DROP TABLE IF EXISTS #Percentagepopulationvaccinated
CREATE TABLE #Percentagepopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolligpeoplevaccinated numeric
)

insert into #Percentagepopulationvaccinated
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations
, SUM(CONVERT(INT,Vac.new_vaccinations)) OVER (Partition by Dea.location order by Dea.location, Dea.date) AS Rollingpeoplevaccinated
--,(Rolligpeoplevaccinated/population)*100
FROM PortfolioProjects..CovidDeaths Dea
join PortfolioProjects..CovidVaccinations Vac 
ON Dea.location = Vac.location
and Dea.date = Vac.date
--where Dea.continent is not null
--order by 2,3

select*,(Rolligpeoplevaccinated/Population)*100
From #Percentagepopulationvaccinated

--creating view to store data for later visualization

create view Percentagepopulationvaccinated as
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations
, SUM(CONVERT(INT,Vac.new_vaccinations)) OVER (Partition by Dea.location order by Dea.location, Dea.date) AS Rollingpeoplevaccinated
--,(Rolligpeoplevaccinated/population)*100
FROM PortfolioProjects..CovidDeaths Dea
join PortfolioProjects..CovidVaccinations Vac 
ON Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3

SELECT*
FROM Percentagepopulationvaccinated





