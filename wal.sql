create database if not exists walmartsales;

create table if not exists sales (
		invoice_id varchar(30) not null,
        branch varchar(5) not null,
        city varchar(30) not null,
        customer_type varchar (30) not null,
        gender varchar(10) not null,
        product_line varchar(100) not null,
        unit_price decimal (10, 2) not null,
        quantity int not null,
        VAT float (6, 4) not null,
        total decimal(12, 4) not null,
        date datetime not null,
        time time not null,
        payment_method varchar(15) not null,
        cogs decimal (10,2) not null,
        gross_margin_percentage float (11, 9) not null,
        gross_income  decimal (12, 4) not null,
        rating float (2, 1) not null
);

-- -----------------------------------------------------------------------------------------------
-- Feature Engineering
-- time_of_day

SELECT time, CASE
        WHEN `time` BETWEEN '00:00:01' AND '12:00:00' THEN 'Morning'
        WHEN `time` BETWEEN '12:00:01' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
        END AS time_of_day
FROM sales;

alter table sales add column time_of_day varchar(20);

UPDATE sales SET time_of_day = (CASE
					WHEN `time` BETWEEN '00:00:01' AND '12:00:00' THEN 'Morning'
					WHEN `time` BETWEEN '12:00:01' AND '16:00:00' THEN 'Afternoon'
					ELSE 'Evening'
					END);
    
-- day_name

SELECT date, DAYNAME(date) FROM sales;
 
alter table sales add column day_name varchar (10);
 
UPDATE sales SET day_name = DAYNAME(date);


-- month_name

select date, monthname(date) from sales;

alter table sales add column month_name varchar(10);

update sales set month_name = monthname(date);

-- -------------------------------------------------------------------------------------------------
-- Generic

-- 1. How many unique cities does the data have?

select count(distinct(city)) from sales;

-- 2. In which city is each branch?

select distinct(branch), city from sales;


-- -------------------------------------------------------------------------------------------------
-- Product
-- 1. How many unique product lines does the data have?

select count(distinct(product_line)) from sales;


-- 2. What is the most common payment method?

select payment_method, count(payment_method) from sales
group by payment_method order by count(payment_method) desc;

-- 3. What is the most selling product line?

select product_line, count(product_line) from sales
group by product_line order by count(product_line) desc limit 1;


-- 4. What is the total revenue by month?

select month_name, sum(total) from sales
group by month_name order by sum(total) desc;

-- 5. What month had the largest COGS?

select month_name, sum(cogs) from sales
group by month_name order by sum(cogs) desc;

-- 6. What product line had the largest revenue?

select product_line, sum(total) as revenue from sales
group by product_line order by revenue desc limit 1;

-- 5. What is the city with the largest revenue?

select city, sum(total) as revenue from sales
group by city order by revenue desc limit 1;

-- 6. What product line had the largest VAT?

select product_line, avg(VAT) from sales
group by product_line order by avg(VAT) desc limit 1;

-- 7. Fetch each product line and add a column to those product line showing "Good", "Bad".
--    Good if its greater than average sales

select product_line, total, case when total < (select avg(total) from sales) then 'BAD'
								 else 'GOOD' end as Remarks
from sales;

select avg(total) from sales;

-- 8. Which branch sold more products?

select branch, sum(quantity) from sales
group by branch order by sum(quantity) desc;

-- 9. What is the most common product line by gender?

select gender, product_line, count(product_line),
		rank() over (partition by gender order by count(product_line) desc) as rn
 from sales
 group by gender, product_line;

-- 12. What is the average rating of each product line?

select product_line, round(avg(rating), 2) from sales
group by product_line order by avg(rating) desc;

-- -------------------------------------------------------------------------------------------------
-- sales

-- 1. Number of sales made in each time of the day per weekday

select day_name, time_of_day, count(time_of_day),
		rank() over(partition by day_name order by count(time_of_day) desc) as rn
 from sales
 group by day_name, time_of_day;

-- 2. Which of the customer types brings the most revenue?

select customer_type, round(sum(total), 2) from sales
group by customer_type order by sum(total) desc;

-- 3. Which city has the largest tax percent/ VAT (**Value Added Tax**)?

select city, avg(VAT) from sales
group by city order by avg(VAT) desc limit 1;


-- 4. Which customer type pays the most in VAT?

select customer_type, round(avg(VAT), 2) from sales
group by customer_type order by avg(VAT) desc;

-- -------------------------------------------------------------------------------------------------
-- Customer
-- 1. How many unique customer types does the data have?

select distinct(customer_type) from sales;

-- 2. How many unique payment methods does the data have?

select distinct(payment_method) from sales;

-- 3. What is the most common customer type?

select customer_type, count(customer_type) from sales
group by customer_type order by count(customer_type) desc;

-- 4. Which customer type buys the most?

select customer_type, count(customer_type) from sales
group by customer_type order by count(customer_type) desc;

-- 5. What is the gender of most of the customers?

select gender, count(gender) from sales
group by gender order by count(gender) desc;

-- 6. What is the gender distribution per branch?

select branch, gender, count(gender),
		rank () over (partition by branch order by count(gender) desc) as rn
from sales
group by branch, gender;

-- 7. Which time of the day do customers give most ratings?

select time_of_day, avg(rating) from sales
group by time_of_day order by avg(rating) desc;

-- 8. Which time of the day do customers give most ratings per branch?

select * from (
select  branch, time_of_day, avg(rating),
			rank () over (partition by branch order by avg(rating) desc) as rn
            from sales
group by branch, time_of_day) as a
where rn = 1;

-- 9. Which day fo the week has the best avg ratings?

select day_name, avg(rating) from sales
group by day_name order by avg(rating) desc;

-- 10. Which day of the week has the best average ratings per branch?

select * from (
select branch, day_name, avg(rating),
			rank () over (partition by branch order by avg(rating) desc) as rn
from sales
group by branch, day_name) as a
where rn = 1;










