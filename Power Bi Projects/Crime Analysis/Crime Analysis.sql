
/*
  Cleaning Data In MySQL
*/

select * from crime_us;

-- Splitting the Date_Time column into 2 separate columns.

select substring_index(Date_Time,' ',1) as Date_Crime,
	   substring_index(Date_Time,' ',-1) as Time_Crime
       from crime_us;

alter table crime_us 
add Date_Crime text,
add Time_Crime text;

update crime_us 
set Date_Crime = substring_index(Date_Time,' ',1),
	Time_Crime = substring_index(Date_Time,' ',-1);
    
-- Standardize Date Format

select Date_Crime, str_to_date(Date_Crime,'%d/%m/%Y') as New_Date_Crime 
from crime_us;

alter table crime_us
add column New_Date_Crime Date;

Update crime_us
set New_Date_Crime = str_to_date(Date_Crime,'%d/%m/%Y');

-- Standardize Time Format

select Time_Crime, str_to_date(Concat(Time_Crime, ':00'),'%H:%i:%s') as New_Time_Crime 
from crime_us;
 
 alter table crime_us
add column New_Time_Crime Time;

update crime_us 
set New_Time_Crime = str_to_date(Concat(Time_Crime, ':00'),'%H:%i:%s');

select * from crime_us;


-- Remove Duplicates 

   select *,
   row_number() over (Partition by ID Order By ID) as row_num
   from crime_us;
   
  select ID -- Statement returns ID list of duplicate rows
  from (select ID,
   row_number() over (Partition by ID Order By ID) as row_num
   from crime_us) as Dup
   where row_num > 1; -- No duplicate rows found 
   
          select * from crime_us;
   
-- Replace Missing/Blank values with Unknown

   Update crime_us
   set Location_Description = 'Unknown'
   where Location_Description ='';

-- Change True and False to YES and NO in "Arrest"

    Select Distinct(Arrest) as arrest, Count(Arrest) as arr
    from crime_us
    group by arrest;
    
    select Arrest , 
    case when Arrest ='TRUE' then 'Yes'
         when Arrest ='FALSE' then 'No'
         else Arrest 
         end as new_arrest
         from crime_us;
         
  update crime_us
  set Arrest = case when Arrest ='TRUE' then 'YES'
               when Arrest ='FALSE' then 'NO'
               else Arrest 
			   end;
 
 select * from crime_us;

-- Change True and False to YES and NO in 'Domestic'
   
   Select Distinct(Domestic) as arrest, Count(Domestic) as dom
    from crime_us
    group by Domestic;
    
    select Domestic, 
    case when Domestic ='TRUE' then 'YES'
         when Domestic='FALSE' then 'NO'
         else Domestic
         end as new_domestic
         from crime_us;
         
    update crime_us
  set Domestic = case when Domestic ='TRUE' then 'YES'
               when Domestic ='FALSE' then 'NO'
               else Domestic 
			   end;
 
 select * from crime_us;     
   

-- Deleting unused columns 

alter table crime_us
drop column Date_Time,
drop column Beat,
drop column FBI_Code,
drop column X_Coordinate,
drop column Y_Coordinate,
drop column Date_Crime,
drop column Time_Crime;

select * from crime_us;



/* Analyzing data in MYSQL */



-- Total Number of Crimes 
   select count(Case_Number) as Total_Crime
   from crime_us;
   
-- Total Number of Arrests Made 
	select count(Arrest) as Total_Arrest
    from crime_us
    where Arrest = 'YES';

-- Top 10 Types of Crimes 
   select Primary_Type, Count(Case_Number) as Num_Crime 
   from crime_us
     group by Primary_Type
     order by Num_Crime desc
     limit 10;
     
-- Crime and Arrest by Month     
    select * from crime_us;
    
    select month(New_Date_Crime) as mon,
		   count(Case_Number) as Total_Crimes,
           sum(case when Arrest = 'YES' Then 1 else 0 end) as Total_Arrests
    from crime_us
    group by mon;
    
    
-- Crime and Arrest by Time 
   select 
	case
         when New_Time_Crime between '04:00:00' and '08:59:59' then 'Early Morning'
         when New_Time_Crime between '09:00:00' and '11:59:59' then 'Morning'
         when New_Time_Crime between '12:00:00' and '16:59:59' then 'Afternoon'
         when New_Time_Crime between '17:00:00' and '19:59:59' then 'Evening'
         else 'Night'
	end as Time_Of_Day,
	count(Case_Number) as Total_Crime,
    sum(case when Arrest = 'YES' Then 1 else 0 end) as Total_Arrests
    from crime_us
    group by Time_Of_Day
    order by 
            case Time_Of_Day
            when 'Early Morning' then 1
            when 'Morning' then 2
            when 'Afternoon' then 3
            when 'Evening' then 4
            else 5
            end ;
    
-- Crime and Arrest by top 5 Locations
   
   select distinct(Location_Description) as Location_Crime,
          count(Case_Number) as Total_Crime,
          sum(case when Arrest = 'YES' Then 1 else 0 end) as Total_Arrests
     from crime_us
     group by Location_Crime
     order by Total_Crime DESC
     Limit 5;
     
-- Crime and Arrest by top 5 Districts   
   
    select distinct(District) as District_Crime,
          count(Case_Number) as Total_Crime,
          sum(case when Arrest = 'YES' Then 1 else 0 end) as Total_Arrests
     from crime_us
     group by District
     order by Total_Crime DESC
     Limit 5;
     
     select * from crime_us;
     

