--Get a count of unique id's for apple store table and description tables
select count(distinct id)
from apple_store

select count(distinct id)
from description
--The count is 7197 for both tables

--See if there are missing values for key fields
select count(*)
from apple_store
where track_name is null or prime_genre is null or user_rating is null

select count(*)
from description
where app_desc is null
--No missing values

--Get an understanding of the data that is in the datasets
select * 
from apple_store
limit 500

select * 
from description
limit 500


--Number of apps per genre
select prime_genre, count(*) as num_apps
from apple_store
group by prime_genre 
order by num_apps desc
-- There are 23 total genres with games having the most apps at 3862


--Overview of app ratings
select min(user_rating) as MinRating, max(user_rating) as MaxRating, avg(user_rating) as AverageRating
from apple_store
--The min is 0, max is 5, and the average is 3.53


--*Instights--
select case
			When price > 0 then 'Paid'
			Else 'Free'
	   End as Apptype,
	   avg(user_rating) as AverageRating
from apple_store
group by Apptype
--Average rating for Free is 3.38 while average rating for Paid is 3.72

--Fix the data type of lang_num to numeric since it's text
Alter table apple_store
Add column lang_num_new numeric;

Update apple_store
set lang_num_new = lang_num::Numeric;

Alter table apple_store
drop column lang_num;

Alter table apple_store
rename column lang_num_new to lang_num;


--Check if apps with more languages have higher ratings
select case
			When cast(lang_num as numeric) < 10 then '<10 Languages'
			When cast(lang_num as numeric) > 30 then '>30 languages'
			Else '10-30 Languages' 
			End as LanguageBuckets,
	   avg(user_rating) as AverageRating
from apple_store
group by LanguageBuckets
order by AverageRating desc
-- 10-30 languages has rating of 4.13, >30 has rating of 3.78, and <10 has a rating of 3.37


--Genres with low ratings
Select avg(user_rating) as AverageRating, prime_genre
from apple_store
group by prime_genre
order by AverageRating asc
--The genre with the lowest average rating is Catalogs


--Check if there is correlation between length of app description and user rating
Select case
			When length(d.app_desc) <500 then 'Short'
			When length(d.app_desc) Between 500 and 1000 then 'Medium'
			When length(d.app_desc) >1000 then 'Long'
			End As DescLength,
	   avg(ap.user_rating) as AverageRating
from apple_store ap
join description d
on ap.id = d.id
group by DescLength
order by AverageRating desc
-- The longer the description the higher the user rating on average

--Check #1 rated apps for each genre
Select prime_genre, 
	   track_name,
	   user_rating 
from  (Select 
	   prime_genre, 
	   track_name,
	   user_rating,	  
	   Rank() Over(Partition by prime_genre order by user_rating Desc, rating_count_tot desc) as rank
	   from apple_store) as a
where a.rank = 1
