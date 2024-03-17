--Select * from CovidDeaths order by location
--Select * from CovidVaccinations order by 3
/*SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CovidDeaths' AND COLUMN_NAME = 'total_cases';*/
--Group by location death percentage
/*Select covid.location, (Sum(cast(covid.total_deaths AS int))/Sum(covid.total_cases))*100
from CovidDeaths as covid
group by covid.location
order by covid.location*/

----------------infection rate relative to their population----------------------
/*select location,population,SUM(total_cases)
from CovidDeaths
where location = 'pakistan'
group by location, population*/
/*select co.location, co.population,max(co.total_cases) as total_cases,(max(co.total_cases)/co.population)*100 as infByPopul
from CovidDeaths co
group by co.location,co.population
order by infByPopul desc*/

-----------------Death COunt per population----------------------
--select co.location, co.population,max(cast(co.total_deaths as int)) as total_deaths,(max(cast(co.total_deaths as int))/co.population)*100 as DeathsPerPopulation
--from CovidDeaths co
--group by co.location,co.population
--order by total_deaths desc

--------------------Deaths count per continent----------------------
--select subquery.continent,Sum(population) as continentPopulation, SUM(total_deaths) as Deaths_per_continent
--from (select co.location,co.population, co.continent,max(cast(co.total_deaths as int)) as total_deaths
--	  from CovidDeaths co
--	  group by co.location,co.population,co.continent) as subquery
--where continent is not null
--group by subquery.continent

-----------------Total population and vaccinated-------------------
/*Select deth.location,max(deth.population) Total_Population,Sum(cast(vac.new_vaccinations as int))total_Vaccinations
from CovidDeaths deth
join CovidVaccinations vac
	on deth.location = vac.location and deth.date = vac.date
where deth.continent is not null
group by deth.location
order by deth.location*/

/*Select deth.location,deth.date,deth.population Total_Population,vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as int)) over (partition by deth.location order by deth.location,deth.date) total_Vaccinations
from CovidDeaths deth
join CovidVaccinations vac
	on deth.location = vac.location and deth.date = vac.date
where deth.continent is not null
order by deth.location*/

------------------------------USING CTE's--------------------------------------
---------------(vaccination/population)*100------------------------------------
/*with vacbypopPercentage(location,date,population,new_vaccinations,tota_Vaccinations)
as(
Select deth.location,deth.date,deth.population Total_Population,vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as int)) over (partition by deth.location order by deth.location,deth.date) total_Vaccinations
from CovidDeaths deth
join CovidVaccinations vac
	on deth.location = vac.location and deth.date = vac.date
where deth.continent is not null
)
select * , (tota_Vaccinations/population)*100
from vacbypopPercentage*/

-----------------------USING TEMP TABLE FOR SAME TASK--------------------------
Create Table #TotalVac
(location nvarchar(255),
date datetime,
population float,
new_vaccinations nvarchar(255),
total_vaccinations nvarchar(255)
)

insert into #TotalVac
Select deth.location,deth.date,deth.population Total_Population,vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as int)) over (partition by deth.location order by deth.location,deth.date) as total_Vaccinations
from CovidDeaths deth
join CovidVaccinations vac
	on deth.location = vac.location and deth.date = vac.date
where deth.continent is not null

select * , (Tvac.total_vaccinations/Tvac.population)*100 vacPerDayRate
from #TotalVac Tvac

-----------------Craeting views for later visualization---------------------
create view totalVac as 
Select deth.location,deth.date,deth.population Total_Population,vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as int)) over (partition by deth.location order by deth.location,deth.date) as total_Vaccinations
from CovidDeaths deth
join CovidVaccinations vac
	on deth.location = vac.location and deth.date = vac.date
where deth.continent is not null