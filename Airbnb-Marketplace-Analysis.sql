drop table test;
create table listings(
id BIGINT,
listing_url TEXT,
name TEXT,
description TEXT,
host_id BIGINT,
host_name TEXT,
host_since TEXT,
host_location TEXT,
host_response_time TEXT,
host_response_rate TEXT,
host_acceptance_rate TEXT,
host_is_superhost TEXT,
host_listings_count INT,
host_total_listings_count INT,
host_verifications TEXT,
property_type TEXT,
room_type TEXT,
accommodates INTEGER,
bathrooms NUMERIC,
bathrooms_text TEXT,
bedrooms NUMERIC,
beds NUMERIC,
number_of_reviews INTEGER,
review_scores_rating NUMERIC
);
select * from listings 
order by id desc;
create table calendar (
    listing_id BIGINT,
    date TEXT,
    available TEXT,
    price TEXT, --
    minimum_nights INTEGER,
    maximum_nights INTEGER
);
create table reviews (
    listing_id BIGINT,
    id BIGINT,
    date TEXT,
    reviewer_id BIGINT,
    reviewer_name TEXT,
    comments TEXT
);

Alter table listings
alter column host_since type date
using TO_DATE(host_since, 'DD/MM/YY');

select * from calendar;
Alter table calendar
alter column date type date
using to_date(date,'DD/MM/YY');

select * from reviews;
alter table reviews
alter date type date 
using to_date(date,'DD/MM/YY');

select * from calendar;
update calendar
set price=replace(substr(price,2,4),',','')::numeric;

alter table calendar
alter price type numeric
using price::numeric;

-- Rank all reviews submitted between '2015-01-01' and '2015-06-30' by their submission date. 
select listing_id, date, reviewer_name, dense_rank()over(order by date) as rank from reviews 
where date between '2015-01-01' and '2015-06-30'
order by rank;
--calculate the total number of reviews received by each host across all their listings. Rank the hosts based on the total number of reviews. 
select host_id, host_name, sum(number_of_reviews), dense_rank()over(order by  sum(number_of_reviews) desc) 
from listings group by 1, 2
order by 4;
-- Calculate the total revenue for each listing by summing up the price for all available days. 
--Use a window function to rank the listings based on their total revenue in descending order.
select listing_id, "price for all available days", dense_rank()over(order by "price for all available days" desc) from
(select listing_id, sum(case when available='f' then price else 0 end) as "price for all available days"
from calendar
group by 1 order by 2 desc 
);
--Calculate the total summer revenue (June, July, and August) for each property type. Determine its percentile rank among all property types based on their revenue.
select property_type, "total summer revenue", percent_rank()over(order by "total summer revenue") from
(SELECT l.property_type, coalesce(sum(price),0) AS "total summer revenue"
FROM listings l
LEFT JOIN calendar c ON l.id = c.listing_id 
AND EXTRACT(month from c.date) in (6, 7, 8) AND c.available='f' 
GROUP BY l.property_type);
-- For each listing, calculate the total revenue per year and determine its YoY growth as a percentage. calculate the YoY growth. Finally, rank listings based on their YoY growth percentage to identify top-performing listings. 
--Display Listing ID,Year,Total Revenue,Year-over-Year Growth (%),Rank of Each Listing by YoY Growth
with yr as (select listing_id, extract(year from date) as year, sum(price) as yly_revenue from calendar
where available='f'
group by listing_id, extract(year from date)
order by listing_id, extract(year from date))
select listing_id, year, "Total Revenue", "pre_revenue", "Year-over-Year Growth %", dense_rank()over(order by "Year-over-Year Growth %" desc) as rank
from
(select listing_id, year, yly_revenue as "Total Revenue",lag(yly_revenue)over(partition by listing_id order by year) as pre_revenue,
round(((yly_revenue-lag(yly_revenue)over(partition by listing_id order by year))/lag(yly_revenue)over(partition by listing_id order by year))*100, 2) as "Year-over-Year Growth %"
from yr)
where "Year-over-Year Growth %" is NOT NULL
order by rank;

--Calculate the total number of listings and unique property types.
select * from listings 
select count(distinct(id)) as "number of listings", count(distinct property_type) as "unique property types"
from listings;
--Identify the top 5 most common property types and their respective counts
select property_type, "respective counts" from 
(select distinct property_type, count(property_type) as "respective counts",
dense_rank()over(order by count(property_type) desc) as rank from listings
group by property_type 
order by 2 desc)
where rank<=5;
--Calculate the average review score across all listings.
select round(avg(review_scores_rating),1) from listings;
--List the top 10 listings with the highest review scores.
select id, name, number_of_reviews, review_scores_rating from listings
where review_scores_rating is not null
order by review_scores_rating desc, number_of_reviews desc
limit 10;

select id, round(avg(review_scores_rating),1) as avg_review_scores_rating from listings 
where review_scores_rating is not null 
group by id order by avg_review_scores_rating desc 
limit 10;
--Count the number of listings with an average review score below 4.0.
select count(*) from (select * from listings where review_scores_rating<4.0)

select count(*) from (select id, avg(review_scores_rating) as avg_review_scores_rating from listings 
where review_scores_rating is not null 
group by id 
having avg(review_scores_rating)<4.0);
--1. Identify hosts managing more than 3 listings.
--2. Calculate the average review score for each host across their listings.
--3. List hosts with at least 2 listings and an average review score below 4.0.
select host_id, host_name, count(*) as "no of listings" from listings 
group by host_id, host_name 
having count(*)>3;
select host_id, host_name, round(avg(review_scores_rating),1) as "average review score" from listings 
group by host_id, host_name
having avg(review_scores_rating)>0;
--If a host has multiple listings without any reviews, those might yield NULL in SQL. we can wrap it in COALESCE() or ROUND() for cleaner output.
select host_id, host_name, count(*) as "no of listings", round(avg(review_scores_rating),1) as "average review score" from listings 
group by host_id, host_name
having count(*)>=2 and avg(review_scores_rating)<4;
--Calculate the occupancy rate for each listing for January 2024.
--Identify the top 5 listings with the highest occupancy rates in January 2024.
--List all listings that were not booked at all in January 2024.
select * from calendar;
with occ as (
select listing_id, count(case when available='f' then available else NULL end) as "occupancy", 
count(available) as availability from calendar 
where date between '2024-01-01' and '2024-01-31'
group by listing_id)
select listing_id, round((occupancy*1.0/availability),1) as "occupancy rate" from occ;

with occ as (
select listing_id, count(case when available='f' then available else NULL end) as "occupancy", 
count(available) as availability from calendar 
where date between '2024-01-01' and '2024-01-31'
group by listing_id)
select listing_id, round((occupancy*1.0/availability),1) as "occupancy rate" from occ
order by (occupancy*1.0/availability) desc limit 5;

select listing_id, round((occupancy*1.0/availability),1) as "occupancy rate" from occ
where occupancy=0;

--Calculate the average price per night for each property type.
--Identify the top 5 listings with the highest average price per night and their property type.
--Find property types with an average price below $150 per night.
select * from calendar;
select * from listings 
select property_type, round(avg(price),1) from listings l
left join calendar c on l.id=c.listing_id
group by property_type;
--whenever you use an aggregate function(AVG) and sort the results(ORDER BY), an INNER JOIN is usually safer to prevent NULL values from destroying your "Top X" reports. we implicitly dropping any listings that lack the very metric (price) we are trying to measure.
select l.id, property_type, round(avg(price),1) from listings l 
join calendar c on l.id=c.listing_id
group by 1, 2
order by 3 desc limit 5;

SELECT l.property_type, ROUND(AVG(price),1) AS avg_price_per_night
FROM listings l
JOIN calendar c ON l.id = c.listing_id
GROUP BY l.property_type
HAVING AVG(price)< 150;
--Identify the top 10 reviewers by the total number of reviews submitted.
--Calculate the average number of reviews per listing.
--Identify all listings with no reviews in 2023.
select * from reviews 
select reviewer_id, reviewer_name, count(*) as "number of reviews" from reviews
group by reviewer_id, reviewer_name
order by 3 desc limit 10;

select avg("number of reviews") from (select l.id, l.name, count(r.id) as "number of reviews" from listings l
left join reviews r on r.listing_id=l.id
group by 1, 2
order by 3);
select * from listings; 
select avg(number_of_reviews) from listings;

select l.id, l.name, count(r.id) as "number of reviews" from listings l
left join reviews r on r.listing_id=l.id
AND r.date::TEXT like '2023%' 
group by 1, 2
having count(r.id)=0;
select l.id, l.name from listings l
left join reviews r on r.listing_id=l.id
AND r.date::TEXT like '2023%' 
where r.id is null;
select id, name from listings
where id NOT IN (select listing_id from reviews 
             where date::TEXT like '2023%');
