create database WALMART;

#buisness problems

use walmart;

select * from table_walmart;

select count(*) from table_walmart;

select distinct payment_method from table_walmart;

select payment_method , count(*) 
from table_walmart
group by payment_method;

select count(distinct branch) from table_walmart;

select max(quantity) from table_walmart;

select min(quantity) from table_walmart;

select * from table_walmart;

## Find diff payment methods and number of transactions , number of quantity sold

select payment_method,count(*) as no_of_transactions ,sum(quantity) as no_of_qty_sold from table_walmart
group by payment_method
order by no_of_transactions desc;

## Identify the highest-rated category in each branch , displaying the branch , category , avg rating
select * from 
(
select branch , category , avg(rating) as avg_rating,
rank() over(partition by branch order by avg(rating) desc) as rank_
from table_walmart
group by 1,2
) as sub_query
where rank_ = 1;

#identifying the buisiest day for each branch 
#based on the no of transactions

select * from
(
select 
branch,dayname(date_format(date,'%d/%m/%y')) as day_name,
count(*) as no_of_transactions,
rank() over(partition by branch order by branch,count(*) desc)
as rank_
from table_walmart
group by branch,day_name
) as sub_query
where rank_ = 1
order by no_of_transactions desc;

#calculate the total quantity of items sold per payment method.
#display payment method and total quantity

select payment_method , sum(quantity) as total_quantity
from table_walmart
group by payment_method;

#Determine the average,minimum and maximum rating of category for each city
#list the city,average,minimum,maximum rating

select city,category,
min(rating) as min_rating,
max(rating) as max_rating,
avg(rating) as avg_rating
from table_walmart
group by city,category;

#Calculate the total profit dor each category by considering profit as (unit price * quantity * profit margin)
#list category and total profit , ordered from highest to lowest profit

select category,
sum(total_cost) as revenue,
sum(total_cost*profit_margin) as total_profit
from table_walmart
group by category
order by total_profit desc;

# determine the most common payment method for each branch.
# display branch and the preferred payment method

with cte
as
(
select branch,
payment_method,
count(payment_method) as total_trans,
rank() over(partition by branch order by count(payment_method) desc) as rank_
from table_walmart
group by branch,payment_method
)
select * from cte where rank_ = 1;

#Categorize sales into morning , afternoon, evening.
#find out each of the shift and number of invoices.

select branch,count(*) as no_of_invoice,
case
 when hour(time_format(time,'%T')) < 12 then 'Morning'
 when hour(time_format(time,'%T')) between 12 and 17 then 'Afternoon'
 else 'Evening'
end as shift
from table_walmart
group by branch,shift
order by branch,no_of_invoice desc;

# Identify 5 branches with highest decrease ratio in revenue copare to the last year (current year 2023 and last year 2022)

with revenue_2022_
as(select branch,sum(total_cost) as revenue from table_walmart
where year(date_format(date,'%d/%m/%y'))=2022
group by branch
order by branch asc
),revenue_2023_
as(select branch,sum(total_cost) as revenue from table_walmart
where year(date_format(date,'%d/%m/%y'))=2023
group by branch
order by branch asc
)select ls.branch,ls.revenue as last_year_revenue,cs.revenue as current_year_revenue,
round(((ls.revenue-cs.revenue )/ls.revenue )*100,2) as revenue_decrease_ratio
from revenue_2022_ as ls
join revenue_2023_ as cs
on ls.branch = cs.branch
where ls.revenue > cs.revenue
order by revenue_decrease_ratio desc
limit 5 ;
