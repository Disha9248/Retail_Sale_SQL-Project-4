
-- RETAIL SALES ANALYSIS PROJECT


-- Create table 

DROP TABLE IF EXIST retail_data;

CREATE TABLE retail_data (

transaction_id INT PRIMARY KEY, 
sale_date DATE,
sale_time TIME,
customer_id INT,
gender VARCHAR(10),
age INT,
category VARCHAR(20),
quantity INT,
price_per_unit FLOAT,
cogs FLOAT,
total_sale FLOAT

);


------ DATA CLEANING --------

SELECT * FROM retail_data
LIMIT 10;

SELECT COUNT(*) FROM retail_data;

-- Checking Null Values

SELECT * 
FROM retail_data
WHERE transaction_id IS NULL
      OR
      sale_date IS NULL
      OR
      sale_time IS NULL
      OR
      customer_id IS NULL
      OR
      gender IS NULL
      OR
      age IS NULL
	  OR
	  category IS NULL
	  OR
	  quantity IS NULL
	  OR
	  price_per_unit IS NULL
      OR
	  cogs IS NULL
	  OR
	  total_sale IS NULL;

-- age: 10 missing values.
-- quantity, price_per_unit, cogs, total_sale: Each has 3 missing value

-- Filling missing values in age with the mean:

UPDATE retail_data
SET age = (SELECT ROUND(AVG(age)) FROM retail_data)
WHERE age IS NULL;

-- Deleting 3 rows as values of all quantity, price_per_unit, cogs, total_sale are missing

DELETE FROM retail_data
WHERE total_sale IS NULL;



------- Data Exploration -----

-- How many sales we have?

SELECT COUNT(*) 
FROM retail_data;

-- How many uniuque customers we have ?

SELECT COUNT(DISTINCT customer_id) 
FROM retail_data;

-- How many uniuque categories we have ?

SELECT DISTINCT category 
FROM retail_data;


--------- BUSINESS KEY PROBLEMS ---------


-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'?
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' 
--     and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)


--------- SOLUTION ---------

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'?

SELECT *
FROM retail_data
WHERE sale_date = '2022-11-05';


-- Q.2 Write a SQL query to retrieve all transactions 
-- where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022 ?

WITH transactions_retrieve AS (
	SELECT EXTRACT(YEAR FROM sale_date) AS year,
	       TO_CHAR( sale_date, 'Month') AS month,
		   transaction_id AS transactions,
		   category,
		   quantity
	FROM retail_data
) 

SELECT *
FROM transactions_retrieve
WHERE year = 2022 
      AND 
      TRIM(month) = 'November'
	  AND 
      category = 'Clothing' 
	  AND
	  quantity > 3;


-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT category,
       SUM(total_sale) AS total_sales
FROM retail_data
GROUP BY category;


-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT category,
       ROUND(AVG(age)) AS average_age
FROM retail_data
GROUP BY category
HAVING category = 'Beauty';



-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT *,
       total_sale
FROM retail_data
WHERE total_sale > 1000;



-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT gender,
       category,
	   COUNT(transaction_id) AS number_of_transactions
FROM retail_data
GROUP BY gender,category
ORDER BY category;



-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

WITH best_selling_month AS (
	
	SELECT TO_CHAR(sale_date, 'Month') AS month,
	       EXTRACT(YEAR FROM sale_date) AS year,		  
		   ROUND(AVG(total_sale)::NUMERIC,2) AS average_sale,
		   RANK()OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY ROUND(AVG(total_sale)::NUMERIC,2) desc) AS rank
	FROM retail_data
	GROUP BY month,year
	ORDER BY year,average_sale DESC	  
)

SELECT year,
       month,
	   average_sale
FROM best_selling_month
WHERE rank = 1;



-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

SELECT customer_id,
       SUM(total_sale) AS total_sale
FROM retail_data
GROUP BY customer_id
ORDER BY total_sale DESC
LIMIT 5;


-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT category,
       COUNT(DISTINCT(customer_id)) AS unique_customer
FROM retail_data
GROUP BY category;


-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning < 12, Afternoon Between 12 & 17, Evening >17)

SELECT  CASE 
             WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning' 
	         WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			 ELSE 'Evening'
		END AS shifts,
		COUNT(CUSTOMER_id) AS number_of_orders
FROM retail_data
GROUP BY shifts
ORDER BY number_of_orders DESC;
