
Select * from CovidDataAnalysis..CovidDeaths
order by 3,4; 

Select * from CovidVaccines order by 3,4;



--SELECT DATA THAT WE ARE GOING TO USE 

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
where continent is not null 
order by location,date 



--TOTAL CASES VS TOTAL DEATHS
--SHOWS LIKELIHOOD OF DYING IF ONE CONTRACTS COVID IN YOUR COUNTRY

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percent
from CovidDeaths
where location like '%states%' and continent is not null 
order by location,date



--TOTAL CASES VS POPULATION
--SHOWS WHAT PERCENTAGE OF PEOPLE GOT INFECTED WITH COVID

select location,date,total_cases,population,(total_cases/population)*100 as percentage_population_infected
from CovidDeaths
where location like 'india' and continent is not null 
order by date desc



--FIND COUNTRIES WITH HIGHEST INFECTION RATE

select location,population,max(total_cases) as highest_infection_count ,MAX((total_cases/population)*100) as percentage_population_infected
from CovidDeaths
where continent is not null 
group by location,population
order by percentage_population_infected desc



--FIND COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

select location,MAX(cast (total_deaths as int)) as highest_total_deaths
from CovidDeaths
where continent is not null 
group by location
order by highest_total_deaths desc


--LET'S BREAK THINGS DOWN BY CONTINENT

--SHOWING CONTINENTS WITH HIGHEST DEATH RATE COUNT PER POPULATION
select continent,MAX(cast (total_deaths as int)) as highest_total_deaths
from CovidDeaths
where continent is not null 
group by continent
order by highest_total_deaths desc


--GLOBAL NUMBERS

select SUM(new_cases) as total_cases_worldwide,SUM(cast (new_deaths as int)) as total_deaths_worldwide,(SUM (cast (new_deaths as int))/SUM(new_cases))*100 as total_death_percent_worldwide
from CovidDeaths
where continent is not null



--LOOKING AT TOTAL POPULATION VS VACCINATION

select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, 
SUM(convert (int,new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as rolling_people_vaccinated
from CovidDeaths cd join CovidVaccines cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null and cv.new_vaccinations is not null
order by cd.location,cd.date desc



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)  
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccines cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by location,date
)
select *,(RollingPeopleVaccinated/population)*100 from PopvsVac


--ALTERNATIVE TO CTE IS TEMP TABLE
--TEMP TABLE 

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccines cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null

select *,(RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated



--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

create view PercentPopulationVaccinated1 as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccines cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null

select * from PercentPopulationVaccinated1

