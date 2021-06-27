--SELECT *
--FROM MY_First_Project..Covid_Deaths$
--ORDER BY 3,4

--SELECT *
--FROM MY_First_Project..Covid_Vaccination$
--ORDER BY 3,4 (This is the data that we will be using in the project)

SELECT location, date, total_cases, new_cases, total_deaths, gdp_per_capita 
FROM MY_First_Project..Covid_Deaths$
ORDER BY 1,2

--Total cases v/s Total deaths 
-- Shows the probablility of dying if you contract Covid (Irrespective of person specificies)
SELECT location, date, total_cases, total_deaths, (total_deaths*100/total_cases) AS Fatality_Rate
FROM MY_First_Project..Covid_Deaths$
WHERE location like '%India%'
ORDER BY 1,2

-- Fatality rate vs GDP per capita
SELECT location, MAX(total_cases) AS Highest_cases, MAX(gdp_per_capita) AS NATIONAL_INCOME, MAX((total_cases/total_deaths)) AS Fatality_rate
FROM MY_First_Project..Covid_Deaths$
GROUP BY location
ORDER BY Highest_cases DESC

-- Showing countries with highest fatality rate (MY CODE)
SELECT location, MAX (total_deaths) AS DEATHS, MAX(total_cases) AS CASES, MAX(gdp_per_capita) AS GDP_PER_CAPITA, (MAX(total_deaths*100)/MAX(total_cases)) AS FATALITIES
FROM MY_First_Project..Covid_Deaths$
WHERE total_cases IS NOT NULL AND total_deaths IS NOT NULL AND gdp_per_capita IS NOT NULL 
GROUP BY location
ORDER BY FATALITIES DESC

--SORTED BY MAXIMUM DEATHS (VIDEO CODE)
SELECT location, MAX (CAST (total_deaths as int)) AS DEATHS, MAX(total_cases) AS CASES, MAX(gdp_per_capita) AS GDP_PER_CAPITA, (MAX(total_deaths*100)/MAX(total_cases)) AS FATALITIES
FROM MY_First_Project..Covid_Deaths$
WHERE total_cases IS NOT NULL AND  gdp_per_capita IS NOT NULL AND continent IS NOT NULL
GROUP BY location
ORDER BY DEATHS DESC

-- CONTINENTAL BREAKDOWN (VIDEO)
SELECT continent, MAX (CAST (total_deaths as int)) AS DEATHS, MAX(total_cases) AS CASES, MAX(gdp_per_capita) AS GDP_PER_CAPITA, (MAX(total_deaths*100)/MAX(total_cases)) AS FATALITIES
FROM MY_First_Project..Covid_Deaths$
WHERE total_cases IS NOT NULL AND  gdp_per_capita IS NOT NULL AND continent IS NOT NULL
GROUP BY continent
ORDER BY DEATHS DESC

-- TOTAL GLOBAL NUMBERS
SELECT SUM (CAST (new_deaths as int)) AS CU_DEATHS, SUM(new_cases) AS CU_DEATHS, (SUM (CAST (new_deaths as int))*100/SUM(new_cases)) AS FATALITY_PERCENTAGE
FROM MY_First_Project..Covid_Deaths$
WHERE new_cases IS NOT NULL AND new_deaths IS NOT NULL AND  continent IS NOT NULL

--DAILY GLOBAL NUMBERS
SELECT date, SUM(CAST (new_deaths as int)) AS DAILY_DEATHS, SUM(new_cases) AS DAILY_DEATHS, (SUM (CAST (new_deaths as int))*100/SUM(new_cases)) AS FATALITY_RATE_PER_DAY
FROM MY_First_Project..Covid_Deaths$
WHERE new_cases IS NOT NULL AND new_deaths IS NOT NULL AND  continent IS NOT NULL
GROUP BY date
ORDER BY date

--Executing simple join 
SELECT *
FROM MY_First_Project..Covid_Deaths$ dea
JOIN MY_First_Project..Covid_Vaccination$ vac 
ON dea.location = vac.location AND dea.date = vac.date

--Total population v/s number of people vaccinated 
SELECT dea.location, dea.date, vac.new_vaccinations, population,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS cu_vacc
FROM MY_First_Project..Covid_Deaths$ dea
JOIN MY_First_Project..Covid_Vaccination$ vac 
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1 

--Using WITH clause (percentage of population vaccinated)
WITH PopvsVacc (location, date, new_vaccinations, population, cu_vacc)
as
(SELECT dea.location, dea.date, vac.new_vaccinations, population,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS cu_vacc
FROM MY_First_Project..Covid_Deaths$ dea
JOIN MY_First_Project..Covid_Vaccination$ vac 
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
)
SELECT *, (cu_vacc/population)*100 AS percent_vacc
FROM PopvsVacc


--Using TEMP table (percentage of population vaccinated)

DROP TABLE IF EXISTS #PercentPopulationgiven1dose
CREATE TABLE #PercentPopulationgiven1dose
(
location nvarchar (255),
date datetime,
new_vaccinations numeric,
population numeric, 
cu_vacc numeric,
)
INSERT INTO #PercentPopulationgiven1dose
SELECT dea.location,
dea.date, 
vac.new_vaccinations, 
population,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS cu_vacc 
FROM MY_First_Project..Covid_Deaths$ dea
JOIN MY_First_Project..Covid_Vaccination$ vac 
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 

SELECT *, (cu_vacc/population)*100 AS percent_vacc
FROM #PercentPopulationgiven1dose

 

 --Creating a view for Tableau

CREATE VIEW PercentPopulationgiven1dose as
SELECT dea.location,
dea.date, 
vac.new_vaccinations, 
population,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS cu_vacc
FROM MY_First_Project..Covid_Deaths$ dea
JOIN MY_First_Project..Covid_Vaccination$ vac 
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 

SELECT *
 FROM #PercentPopulationgiven1dose

