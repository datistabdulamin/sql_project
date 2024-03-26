-- checking all data and Both table Together:
SELECT *
FROM covidDeaths; 
SELECT *
FROM covidVaccinations

-- select the data im working on this project:
SELECT iso_code, location, date, total_cases, total_deaths, population
FROM allaboutcovid..covidDeaths
ORDER BY 1,2;

-- Looking at Total Cases and Total Deaths:
SElECT iso_code,location, date, total_cases, total_deaths
FROM covidDeaths
ORDER BY 1,2;

-- Checking % on Total Cases over Total Deaths:
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPer
FROM covidDeaths
ORDER BY 1,2;

-- Checking the % of specific country like Pakistan
SELECT location, total_cases, total_deaths, (total_deaths/total_cases)*100 as per_ofpk
FROM covidDeaths
WHERE location='Pakistan'
ORDER BY 1,2;

-- Looking for total cases and Population as Percentage:
SELECT location, population, total_cases, (total_cases/population)*100 as total_percentage
FROM covidDeaths
ORDER BY 1,2;

-- Checking the percentage of US only:
SELECT location, population, total_cases, (total_cases/population)*100 as per_us
FROM covidDeaths
WHERE location='United States'
ORDER BY per_us DESC;

-- number of people who not effected (without null values):
SELECT location, population, total_cases, (population - total_cases) AS not_affected
FROM covidDeaths
WHERE location='United States' AND population IS NOT NULL AND total_cases IS NOT NULL
ORDER BY not_affected DESC;

-- looking for the country with highest effected rate:
SELECT location, population, MAX(total_cases) AS highest_effected_country,
MAX((total_cases/population))*100 AS per_effected
FROM covidDeaths
WHERE population IS NOT NULL and total_cases IS NOT NULL
group by location, population
ORDER BY per_effected DESC;

-- Looking for the country which is highest rate Death count:
SELECT location, MAX(CAST(total_deaths AS INTEGER)) AS total_death
FROM covidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death DESC;

-- Looking for the Continent, which is highest rate Death count:
SELECT location, max(CAST(total_deaths as int)) as totalDeathcontinent
FROM covidDeaths
Where continent is null
GROUP BY location
ORDER BY totalDeathcontinent DESC;

--  global number:
SELECT SUM(CAST(new_cases as int)) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS deaths_percentage
FROM covidDeaths

-- Looking for total population vs total vaccinated People:
-- using join
SELECT dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations 
FROM covidDeaths AS dth
JOIN covidVaccinations as vcc
	ON dth.location=vcc.location
	AND dth.date=vcc.date
WHERE dth.continent IS NOT NULL
ORDER BY new_vaccinations  DESC;
 
 -- use CTE:
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations
, SUM(CONVERT(int,vcc.new_vaccinations)) OVER (Partition by dth.Location Order by dth.location, dth.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covidDeaths dth
Join covidVaccinations vcc
	On dth.location = vcc.location
	and dth.date = vcc.date
where dth.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations
, SUM(CONVERT(int,vcc.new_vaccinations)) OVER (Partition by dth.Location Order by dth.location, dth.Date) as RollingPeopleVaccinated
From covidDeaths dth
Join covidVaccinations vcc
	On dth.location = vcc.location
	and dth.date = vcc.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covidDeaths dea
Join covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

--The End