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
