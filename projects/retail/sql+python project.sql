SELECT * FROM DF_ORDERS
drop table df_orders
CREATE TABLE DF_ORDERS([order_id] INT PRIMARY KEY ,[order_date] DATE , [ship_mode] VARCHAR(20), [segment]VARCHAR(20), [country] VARCHAR(20), [city] VARCHAR(20),
       [state] VARCHAR(20), [postal_code] VARCHAR(20), [region] VARCHAR(20), [category] VARCHAR(20), [sub_category] VARCHAR(20),
       [product_id] VARCHAR(20) , [quantity] INT, [discount] DECIMAL (7,2), [sale_price] DECIMAL(7,2), [profit] DECIMAL (7,2) )
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'df_orders';

SELECT * FROM DF_ORDERS
--find 10 top revenue generating products

SELECT TOP 10 PRODUCT_ID,SUM(SALE_PRICE) AS SALES
FROM DF_ORDERS
GROUP BY product_id
ORDER BY sales DESC

--find top 5 sellling products in each region
WITH CTE AS(
SELECT REGION, PRODUCT_ID,SUM(SALE_PRICE) AS SALES
FROM DF_ORDERS
GROUP BY product_id,REGION)
SELECT * FROM
(
SELECT * ,ROW_NUMBER() OVER(PARTITION BY REGION ORDER BY sales DESC ) AS RNK
FROM CTE) A
WHERE RNK<=5


-- find  month over month growth comparison for 2022 and 2023 eg ., jan 2022 vs jan 2023
with cte as (select distinct year(order_date) as ord_year ,month(order_date) as ord_month,sum(sale_price) as sales 
from DF_ORDERS
group by year(order_date) ,month(order_date) )

select  ord_month 
,sum(case when ord_year=2022  then sales else 0 end) as sales_2022
,sum(case when ord_year=2023  then sales else 0 end) as  sales_2023
from cte A
group by ord_month
order by ord_month

--for each category which month had highest sales
WITH CTE AS(
select category, format(order_date, 'yyyyMM') as order_yr_mnth, sum(sale_price) as sales
from DF_ORDERS
group by category, format(order_date, 'yyyyMM')
--ORDER BY category, format(order_date, 'yyyyMM')
)

SELECT * FROM
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY CATEGORY order by SALES DESC) AS rn
FROM CTE) 
A
WHERE rn=1

-- which subcategory has the highest growth profit  in 2023 compared to 2022
select distinct sub_category, sum(sale_price) as sales , year(order_date) as YR
FROM DF_ORDERS
GROUP BY sub_category, order_date 
order by YR desc,sales desc

with cte as (select  sub_category , year(order_date) as ord_year ,sum(sale_price) as sales 
from DF_ORDERS
group by sub_category,year(order_date) ),

cte2 as(
select  sub_category
,sum(case when ord_year=2022  then sales else 0 end) as sales_2022
,sum(case when ord_year=2023  then sales else 0 end) as  sales_2023
from cte A
group by sub_category)

select top 1*,
(sales_2023-sales_2022)*100/sales_2023 as growth_percent
from cte2
order by growth_percent desc


