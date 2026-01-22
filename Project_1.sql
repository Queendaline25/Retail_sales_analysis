SELECT * From sample_store;

    /* Data Understanding & Quality Checks
    1. How many records are in the dataset? */
    SELECT COUNT(*) From sample_store;
    /* 2. What are the distinct values for:
Region,Category,Segment?*/
--Region
SELECT DISTINCT(Region) FROM sample_store;
--Category
SELECT DISTINCT(Category) FROM sample_store;
--Segment
SELECT DISTINCT(Segment) FROM sample_store;
--Are there missing or null values in key fields such as Sales, Profit, Order Date, and Customer ID?
SELECT * FROM sample_store
WHERE `Sales` IS NULL
 OR `Profit` IS NULL
 OR `Order_Date` is NULL
 OR `Customer_ID` is NULL;
 --Are there duplicate Order IDs? If yes, explain why duplicates may exist.
 SELECT Order_ID , COUNT(*) 
 FROM sample_store
 GROUP BY `Order_ID`
 HAVING COUNT(*) > 1;
 /* The duplicates may have existed due to one of the following reasons:
 1.  lack of unique identifiers in the order ID column
 2.It could be one to many relationships like a customer purchasing multiple products
 3. Data Entry errors
 4. Data entry variations or system errors */

 -- 5. What is the date range covered by the dataset?
 SELECT MAX(Order_Date) AS latest_date,
        MIN(Order_Date) AS earliest_date
 FROM sample_store;      
 -- Finding the date range on the Ship_Date column to know the earliest transaction.
  SELECT MAX(`Ship_Date`) AS latest_date,
        MIN(`Ship_Date`) AS earliest_date
 FROM sample_store; 
 /* The earliest date for Order is 2014-01-03 while the latest date is 2017-12-30
 Meanwhile for ship_date, the earliest is 2014-01-07 and the latest being 2018-01-05 */

 -- B. Overall Business Performance
 --1. What are the total sales, total profit, and overall profit margin?
 SELECT SUM(Sales) AS Total_Sales, SUM(profit) AS 'Total profit'
 FROM sample_store;
 SELECT SUM(Sales) AS Total_Sales, SUM(profit) AS 'Total profit', Round(SUM(profit)/SUM(Sales) * 100, 2) AS 'Profit Margin'
FROM sample_store;

-- 2.What is the average order value (AOV)?
SELECT Round(AVG(Sales),2)
FROM sample_store;
-- The average order value is 229.86
--3.How many unique customers placed orders?
SELECT COUNT(DISTINCT Customer_ID)
FROM sample_store;
-- 793 unique customers placed orders

--4.What is the total number of orders?
SELECT COUNT (DISTINCT Order_ID)
FROM sample_store;
-- 5009 placed orders
--5. What percentage of orders are profitable?
SELECT DISTINCT(`Order_ID`), profit
FROM sample_store
WHERE `Profit` > 0
LIMIT 20;
SELECT 
(COUNT (DISTINCT Case WHEN Profit > 0 THEN Order_ID END) *100
/COUNT(DISTINCT `Order_ID`)) AS percentage_orders
FROM sample_store;
/* C. Time-Based Analysis
1.What are total sales and profit by year? */
SELECT SUM(Sales) AS Total_sales, SUM(profit) AS Total_profit , EXTRACT(YEAR FROM Order_Date) AS year
from sample_store
GROUP BY year
ORDER BY year DESC;
-- 2. What are total sales and profit by month (across all years)?
SELECT DATE_FORMAT(`Order_Date`, '%Y-%m') AS yearmonth,
SUM(`Sales`) AS Total_Sales, Sum(`Profit`) AS Total_profit
FROM sample_store
GROUP BY yearmonth
ORDER BY yearmonth DESC;
--3. Which month generates the highest sales
SELECT sum(sales), EXTRACT(MONTH FROM Order_Date) AS month
from sample_store
GROUP BY month
ORDER BY month DESC;
-- Month 12 (December) generated the highest sales.

--4. Are there months with negative profit despite high sales?
SELECT sum(profit) AS Total_profit,EXTRACT(MONTH FROM Order_Date) AS month
FROM sample_store
where profit < 0
GROUP BY month;
-- Yes there are months with negative profit

--5.Calculate year-over-year sales growth.
WITH year_sales AS (
    SELECT sum(sales) AS total_sales,
    EXTRACT(YEAR FROM Order_Date) AS Order_year
    FROM sample_store
    GROUP BY order_year
)
SELECT
 total_sales,
 order_year,
 LAG(total_sales) OVER (ORDER BY order_year) AS prev_year_sales,
 ROUND(((total_sales - LAG(total_sales) OVER(ORDER BY order_year))/LAG(total_sales) OVER(ORDER BY order_year)) * 100,2) AS YOY_growth_percent
 FROM year_sales
 ORDER BY order_year;
--.D. Product & Category Performance
--1.What are total sales and profit by category and sub-category?
SELECT SUM(Profit) AS total_profit, SUM(Sales) AS total_sales,
Category, Sub_Category
from sample_store
GROUP BY Category,sub_category;
--2.Which sub-categories are the most profitable?
SELECT SUM(Sales) AS total_sales, SUM(profit) AS total_profit,Sub_category
FROM sample_store
WHERE profit > 0
GROUP BY `Sub_Category`
ORDER BY `Sub_Category` DESC;
--3. Which sub-categories generate high sales but low or negative profit?
SELECT SUM(profit) AS total_profit, SUM(Sales) AS total_sales, Sub_category
FROM sample_store
GROUP BY `Sub_Category`
HAVING SUM(Sales)> 0
AND SUM(Profit)<= 0;
--4.Rank products by total sales within each category.
SELECT SUM(Sales) AS total_sales, Category, Product_Name,
RANK() OVER (PARTITION BY category ORDER BY SUM(Sales) DESC) AS sales_rank
FROM sample_store
GROUP BY `Category`, `Product_Name`
ORDER BY `Category`, sales_rank;
--5.What percentage of total sales does each category contribute?
--E. Customer & Segment Analysis
--1.What are total sales and profit by customer segment?
SELECT Sum(sales) AS total_sales, SUM(profit) AS total_profit,`Segment`
FROM sample_store
GROUP BY `Segment`;
--2.Which segment has the highest average order value?
SELECT AVG(Sales),segment
FROM sample_store
GROUP BY `Segment`
ORDER BY AVG(`Sales`) DESC;
--3.Who are the top 10 customers by total sales?
SELECT SUM(Sales),Customer_Name
FROM sample_store
GROUP BY `Customer_Name`
ORDER BY SUM(`Sales`) DESC
LIMIT 10;
--Do the top customers by sales also generate the highest profit?
SELECT SUM(sales) AS total_sales,Sum(profit) AS total_profit,Customer_Name
FROM sample_store
GROUP BY `Customer_Name`
ORDER BY total_sales DESC,total_profit DESC
LIMIT 10;
-- No, the top most customer generated negative profit
--5. What is the average profit per customer?
SELECT AVG(profit),Customer_Name
FROM sample_store
GROUP BY `Customer_Name`
ORDER BY AVG(profit);
-- Regional & Geographic Analysis
--What are total sales and profit by region?
SELECT Sum(sales) AS total_sales, SUM(profit) AS total_profit,`Region`
FROM sample_store
GROUP BY `Region`;
--Which states are the most profitable?
SELECT Sum(profit) AS profits,Country_State
FROM sample_store
GROUP BY `Country_state`
ORDER BY profits DESC;
--Are there states with high sales but consistent losses?
SELECT SUM(sales) AS total_sales,Sum(profit) AS total_profits, Country_State
FROM sample_store
GROUP BY `Country_state`
HAVING total_sales > 0 AND total_profits <= 0
ORDER BY total_sales DESC, total_profits DESC;
--4. Rank cities within each region by profit.
WITH city_profit AS(SELECT city,Region, SUM(profit) AS total_profit
FROM sample_store
GROUP BY `City`,`Region`
)
SELECT `City`,`Region`,total_profit,
RANK() OVER (PARTITION BY `Region` ORDER BY total_profit DESC) AS ranked_city
FROM city_profit
ORDER BY `Region`,ranked_city;
--5 Which region has the highest profit margin?
SELECT Region,SUM(Sales) AS Total_Sales, SUM(profit) AS 'Total profit', Round(SUM(profit)/SUM(Sales) * 100, 2) AS profit_margin
FROM sample_store
GROUP BY `Region`
ORDER BY profit_margin DESC;
--What is the average discount applied?
SELECT ROUND(AVG(Discount),2)
FROM sample_store;
--2 How does profit change as discount levels increase?
SELECT sum(profit) AS total_profit,discount,AVG(profit) AS avg_profit
from sample_store
GROUP BY `Discount`
ORDER BY `Discount`;
--from 0-20% discount , the company maximized profit but incurred losses at discount above 20%.
--3.Which products are most frequently sold with high discounts?
SELECT Product_name,discount,sum(`Quantity`) AS number_of_occurence
FROM sample_store
GROUP BY `Product_Name`,discount
ORDER BY `Discount` DESC, number_of_occurence DESC;
--Are high discounts associated with negative profit?
SELECT sum(profit) AS total_profit,discount,AVG(profit) AS avg_profit
from sample_store
GROUP BY `Discount`
ORDER BY `Discount`;
--- Yes, based on the result
--At what discount level does profitability begin to decline significantly?
--At 30%,based on outputs
--. Shipping & Operations Analysis
--1.What are total sales and profit by ship mode?
SELECT SUM(sales) AS total_sales, Sum(profit) AS total_profit,Ship_mode
FROM sample_store
GROUP BY `Ship_Mode`;
--2.What is the average shipping time (Ship Date – Order Date)?
SELECT AVG(DATEDIFF(`Ship_Date`,`Order_Date`)) AS avg_shipping_days
FROM sample_store;
--3.Does faster shipping correlate with higher profit?
SELECT SUM(profit) AS total_profit, DATEDIFF(Ship_Date,Order_Date) AS shipping_days
FROM sample_store
GROUP BY shipping_days
ORDER BY shipping_days DESC;
--Which ship mode is used most frequently?
SELECT Ship_Mode,
Count(*) AS no_of_usage
FROM sample_store
GROUP BY `Ship_Mode`
ORDER BY no_of_usage DESC;
--Are any ship modes consistently associated with losses?
Select Ship_mode, Sum(profit) AS total_profit, AVG(profit) AS AVG_profit,Count(*) AS order_count
FROM sample_store
GROUP BY `Ship_Mode`
HAVING Sum(profit) < 0
ORDER BY total_profit DESC;
---NO,they all made profit
--Advanced SQL (Stretch Tasks)
--1.Identify customers whose total profit is negative.
SELECT Customer_Name, sum(profit) AS total_profit
from sample_store
GROUP BY `Customer_Name`
HAVING total_profit < 0
ORDER BY total_profit;
--Create a running total of sales over time.
SELECT  `Order_Date`, Sales,SUM(Sales) OVER (ORDER BY Order_Date) AS running_total_sales
FROM sample_store
ORDER BY`Order_Date`;
--3.Rank sub-categories by profit within each category.
WITH Sub_Categories_profit AS (SELECT Category, Sub_Category, Sum(profit) AS total_profit
FROM sample_store
GROUP BY `Category`,Sub_Category
)
SELECT
`Category`,Sub_Category,total_profit,
Rank() OVER (PARTITION BY `Category` ORDER BY total_profit DESC) AS Ranked_Category
FROM `Sub_Categories_profit`
ORDER BY `Category`,Ranked_Category;
--4. Identify the top three products per region by sales.
SELECT Region,`Product_Name`,SUM(Sales) AS total_sales
FROM sample_store
GROUP BY `Product_Name`,`Region`
ORDER BY total_Sales DESC
LIMIT 3;
--Create a SQL view that shows monthly sales, profit, and profit margin.
CREATE VIEW MOnthly_Sales_performance AS
WITH Monthly_sales_data AS ( SELECT SUM(Sales) AS total_Sales, SUM(profit) AS total_profit, EXTRACT(MONTH FROM Order_Date) AS month
FROM sample_store
GROUP BY EXTRACT(MONTH FROM Order_Date)
)
SELECT total_sales,total_profit,month,
CASE WHEN total_sales = 0 THEN 0 
     ELSE total_profit/total_sales
END AS profit_margin
FROM Monthly_sales_data
ORDER BY month;