create database Customer;
use customer;

select * from cust_seg;

select str_to_date(order_date, '%d-%m-%y')
from cust_seg;

alter table cust_seg
modify order_date Datetime;
SET SQL_SAFE_UPDATES = 0;

update cust_seg 
set order_date = str_to_date(order_date,'%d-%m-%Y');

alter table cust_seg
modify order_date datetime;

alter table cust_seg
rename column `ï»¿order_id` to `order_id`;

-- RFM Table
SELECT
    customer_id,
    SUM(sales) AS monetary,
    COUNT(order_id) AS frequency,
    DATEDIFF(
    (SELECT MAX(order_date) FROM cust_seg) + INTERVAL 1 DAY,
    MAX(order_date)
) as recency
FROM cust_seg
GROUP BY customer_id;


-- 1 TOTAL & CUMULATIVE SALES
select order_date,sum(sales) as daily_sales ,
sum(sum(sales)) over(order by order_date) as cummulative_Sales 
from cust_seg
group by order_date
order by order_date;

-- 2 RANK CUSTOMERS BY TOTAL SPEND
select customer_id,
sum(sales) as daily_sales,
rank() over(order by sum(sales) desc) as revenue_rank
from cust_seg
group by customer_id;

-- 3 rank and dense rank
select customer_id,
rank() over(order by sum(sales) desc) as revenue_rank,
dense_rank() over(order by sum(sales) desc) as unique_rank,
row_number() over(order by sum(sales) desc) as row_num
from cust_seg
group by customer_id;

-- 4 CUSTOMER-WISE PURCHASE GAPS
select customer_id,order_date,
lag(order_date) over(partition by customer_id order by order_date) as previous_order,
datediff(order_date,lag(order_date) over(partition by customer_id order by order_date)) as day_between_order
from cust_seg;

-- 5 TOP PRODUCT PER REGION
select * from(select region,product, 
rank() over(partition by region order by sum(sales) desc) as rank_in_region
from cust_seg
group by region,product) as ranked 
where rank_in_region = 1;

-- 6 PERCENTAGE CONTRIBUTION
select customer_id,sum(sales) as contri,
round( sum(sales)*100/sum(sum(sales)) over(),2) as revenue
from cust_seg
group by customer_id;
