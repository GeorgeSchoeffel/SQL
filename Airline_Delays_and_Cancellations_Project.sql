#George Schoeffel

#For this project we use the public dataset, the Airline On-Time Statistics and Delay Causes data set 
#This is found at http://www.transtats.bts.gov/
#We choose to focus on the May 2018 data
#We use AWS to load the data from our local machine into our EC2 instance

#Manually create our final table

CREATE TABLE L_CANCELATION (
	Code text,
    Reason text
    );
    
INSERT INTO L_CANCELATION
VALUES ('A', 'Carrier');

INSERT INTO L_CANCELATION
VALUES ('B', 'Weather');

INSERT INTO L_CANCELATION
VALUES ('C', 'National Air System');

INSERT INTO L_CANCELATION
VALUES ('D', 'Security');

select *
from al_perf;


#1 Finding the maximum departure delay for each airline in minutes

with dep_delay(DOT_ID_Reporting_Airline, max_delay) as
    (select DOT_ID_Reporting_Airline, max(DepDelay) as max_delay
    from al_perf 
    group by DOT_ID_Reporting_Airline)
select L_AIRLINE_ID.Name as Airline_Name, max_delay
from dep_delay 
join L_AIRLINE_ID on ID=DOT_ID_Reporting_Airline
order by dep_delay.max_delay asc;

#2 Finding the maximum early departure for each airline

with dep_delay(DOT_ID_Reporting_Airline, early_departure) as
    (select DOT_ID_Reporting_Airline, min(DepDelay) as early_departure
    from al_perf 
    group by DOT_ID_Reporting_Airline)
select L_AIRLINE_ID.Name as Airline_Name, early_departure
from dep_delay 
join L_AIRLINE_ID on ID=DOT_ID_Reporting_Airline
order by dep_delay.early_departure asc;

#3 Ranking days of the week by number of flights for each airline

with flights(DayOfWeek,number_of_flights) as
	(select DayOfWeek, count(*)
	from al_perf
	group by DayofWeek)
select Day, number_of_flights, rank() over (order by number_of_flights desc) as mostflights
from flights join L_WEEKDAYS on L_WEEKDAYS.Code=flights.DayOfWeek
order by mostflights;

#4 Find the airports with the highest average delays

with avg_delay(OriginAirportID, airportdelay) as
	(select OriginAirportID, avg(DepDelayMinutes)
	from al_perf
	group by OriginAirportID)
select L_AIRPORT_ID.Name, Code, max(airportdelay) as avg_max_delay
from avg_delay join L_AIRPORT_ID on L_AIRPORT_ID.ID = avg_delay.OriginAirportID join L_AIRPORT on L_AIRPORT.Name = L_AIRPORT_ID.Name;

#5 Finding the airport for each airline with the highest delay in departure

with avg_delay(OriginAirportID, DOT_ID_Reporting_Airline, airportdelay) as
	(select OriginAirportID, DOT_ID_Reporting_Airline, avg(DepDelayMinutes)
	from al_perf
	group by OriginAirportID, DOT_ID_Reporting_Airline)
select L_AIRPORT_ID.Name as airport_name, L_AIRLINE_ID.Name as airline_name, max(airportdelay) as max_avg_airport_delay
from avg_delay join L_AIRPORT_ID on L_AIRPORT_ID.ID = avg_delay.OriginAirportID join L_AIRLINE_ID on L_AIRLINE_ID.ID = avg_delay.DOT_ID_Reporting_Airline
group by avg_delay.DOT_ID_Reporting_Airline;

#6A Checking if there were any cancelled flights in our data

select count(*) as number_of_canceled_flights
from al_perf
where Cancelled != 0;

#6B Report the most frequent reason for each departure delay

with cancel(CancelCode, CancelCount, Airport) as
	(select CancellationCode, count(CancellationCode), OriginAirportID
    from al_perf
    where Cancelled = 1
    group by CancellationCode, OriginAirportID)
select Name, Reason, max(CancelCount)
from cancel join L_CANCELATION on CancelCode=Code join L_AIRPORT_ID on Airport=ID
group by Name;

#7 Create a report that outputs the average number of flights over the preceding 3 days for each day of the month

with report(number_flights,DayOfMonth) as
	(select count(Month), DayOfMonth
	from al_perf
    where DayofMonth != 0
	group by DayOfMonth)
select DayOfMonth, avg(number_flights) over 
	(order by DayOfMonth asc rows 3 preceding) as previous_three_day_avg
from report
group by DayOfMonth;
