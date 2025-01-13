## Section 1:
You can start this section following *session 1*, but you may want to wait until you feel comfortable wtih basic SQL query writing. 

Steps to complete this part of the assignment:
- Design a logical data model
- Duplicate the logical data model and add another table to it following the instructions
- Write, within this markdown file, an answer to Prompt 3


###  Design a Logical Model

#### Prompt 1
Design a logical model for a small bookstore. 📚

At the minimum it should have employee, order, sales, customer, and book entities (tables). Determine sensible column and table design based on what you know about these concepts. Keep it simple, but work out sensible relationships to keep tables reasonably sized. 

Additionally, include a date table. 

There are several tools online you can use, I'd recommend [Draw.io](https://www.drawio.com/) or [LucidChart](https://www.lucidchart.com/pages/).




**HINT:** You do not need to create any data for this prompt. This is a conceptual model only. 

#### Prompt 2
We want to create employee shifts, splitting up the day into morning and evening. Add this to the ERD.

![ERD2](https://github.com/user-attachments/assets/5f365895-86c3-47a2-a8c1-09ec49bcbf6d)


#### Prompt 3
The store wants to keep customer addresses. Propose two architectures for the CUSTOMER_ADDRESS table, one that will retain changes, and another that will overwrite. Which is type 1, which is type 2? 

**HINT:** search type 1 vs type 2 slowly changing dimensions. 

```
<u>Type 1 SCDs - Overwriting</u>

In a Type 1 SCD the new data overwrites the existing data. Thus the existing data is lost as it is not stored anywhere else. This is the default type of dimension you create. You do not need to specify any additional information to create a Type 1 SCD.

<u>Type 2 SCDs - Creating another dimension record</u>

A Type 2 SCD retains the full history of values. When the value of a chosen attribute changes, the current record is closed. A new record is created with the changed data values and this new record becomes the current record. Each record contains the effective time and expiration time to identify the time period between which the record was active.

Store is intending to implement Type 2 approach. There are ofcourse various privacy implications to this for example -

1) Addresses are considered PII and Bookstore team should consider the prominent data protection and privacy laws and regulations based on the country/region they are going to store the customer information of.
2) Storing addresses in a database also involves implementing appropriate security measures to protect address data against unauthorized access and breaches. Data breaches can result in significant financial, reputational, and legal damages for the organization and the data subjects. They can also expose the organization to regulatory fines, penalties, civil lawsuits, and claims. They need to consider the security measures that can help prevent and mitigate data breaches for example - data encryption , data backups, data access controls, data rentention policies etc.
```


/* ASSIGNMENT 2 */
/* 1. Our favourite manager wants a detailed long list of products, but is afraid of tables! 
We tell them, no problem! We can produce a list with all of the appropriate details. 

Using the following syntax you create our super cool and not at all needy manager a list:

SELECT 
product_name || ', ' || product_size|| ' (' || product_qty_type || ')'
FROM product

But wait! The product table has some bad data (a few NULL values). 
Find the NULLs and then using COALESCE, replace the NULL with a 
blank for the first problem, and 'unit' for the second problem. 

HINT: keep the syntax the same, but edited the correct components with the string. 
The `||` values concatenate the columns into strings. 
Edit the appropriate columns -- you're making two edits -- and the NULL rows will be fixed. 
All the other rows will remain the same.) */

SELECT 
product_name || ', ' || coalesce(product_size,"")|| ' (' || coalesce(product_qty_type, 'unit') || ')'
FROM product;


--Windowed Functions
/* 1. Write a query that selects from the customer_purchases table and numbers each customer’s  
visits to the farmer’s market (labeling each market date with a different number). 
Each customer’s first visit is labeled 1, second visit is labeled 2, etc. 

You can either display all rows in the customer_purchases table, with the counter changing on
each new market date for each customer, or select only the unique market dates per customer 
(without purchase details) and number those visits. 
HINT: One of these approaches uses ROW_NUMBER() and one uses DENSE_RANK(). */
-- using DENSE_RANK()
SELECT market_date, customer_id, DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY market_date ASC) customer_visit_number
FROM customer_purchases;

--using ROW_NUMBER()
SELECT market_date, customer_id , ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY market_date) AS customer_visit_number
FROM customer_purchases;

--using ROW_NUMBER() to display unique market dates visit per customer
SELECT market_date, customer_id , ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY market_date) AS customer_visit_number
FROM (SELECT DISTINCT customer_id, market_date  FROM customer_purchases) AS unique_visits;


/* 2. Reverse the numbering of the query from a part so each customer’s most recent visit is labeled 1, 
then write another query that uses this one as a subquery (or temp table) and filters the results to 
only the customer’s most recent visit. */

SELECT * FROM
    (
        SELECT  DISTINCT customer_id, market_date, DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY market_date DESC) customer_visit_number FROM customer_purchases
    ) AS  unique_visits WHERE unique_visits.customer_visit_number = 1;
    
/* 3. Using a COUNT() window function, include a value along with each row of the 
customer_purchases table that indicates how many different times that customer has purchased that product_id. */

SELECT customer_id,product_id,market_date, COUNT(product_id) OVER(PARTITION BY customer_id, product_id)  purchase_product_count
FROM customer_purchases;


-- String manipulations
/* 1. Some product names in the product table have descriptions like "Jar" or "Organic". 
These are separated from the product name with a hyphen. 
Create a column using SUBSTR (and a couple of other commands) that captures these, but is otherwise NULL. 
Remove any trailing or leading whitespaces. Don't just use a case statement for each product! 

| product_name               | description |
|----------------------------|-------------|
| Habanero Peppers - Organic | Organic     |

Hint: you might need to use INSTR(product_name,'-') to find the hyphens. INSTR will help split the column. */

SELECT *,
CASE
			WHEN INSTR(product_name,'-') > 0 THEN TRIM(SUBSTR(product_name, INSTR(product_name,'-')+1))
            ELSE NULL
			END AS description
FROM product;


/* 2. Filter the query to show any product_size value that contain a number with REGEXP. */
SELECT *,
CASE
			WHEN INSTR(product_name,'-') > 0 THEN TRIM(SUBSTR(product_name, INSTR(product_name,'-')+1))
            ELSE NULL
			END AS description
FROM product 
WHERE product_size REGEXP '[0-9]';


-- UNION
/* 1. Using a UNION, write a query that displays the market dates with the highest and lowest total sales.

HINT: There are a possibly a few ways to do this query, but if you're struggling, try the following: 
1) Create a CTE/Temp Table to find sales values grouped dates; 
2) Create another CTE/Temp table with a rank windowed function on the previous query to create 
"best day" and "worst day"; 
3) Query the second temp table twice, once for the best day, once for the worst day, 
with a UNION binding them. */
-- 1
DROP TABLE IF EXISTS temp_sales;

CREATE TEMP TABLE temp_sales AS
    SELECT market_date, quantity, cost_to_customer_per_qty, quantity * cost_to_customer_per_qty as sales
    FROM customer_purchases;
--2
DROP TABLE IF EXISTS temp_sum_sales;
CREATE TEMP TABLE temp_sum_sales AS
    SELECT market_date, SUM(sales) AS sales
    FROM temp_sales
    GROUP BY market_date;
--3
SELECT market_date, MAX(sales) AS sales, "best_day" AS status
FROM temp_sum_sales
UNION
SELECT market_date, MIN(sales) AS sales, "worst_day" AS status
FROM temp_sum_sales;



/* SECTION 3 */

/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */

SELECT
    v.vendor_name,
    p.product_name,
    SUM(5 * vi.original_price * c.customer_count) AS total_per_product
FROM
    vendor v
JOIN
    vendor_inventory vi ON v.vendor_id = vi.vendor_id
JOIN
    product p ON vi.product_id = p.product_id
CROSS JOIN
    (SELECT COUNT(DISTINCT customer_id) AS customer_count FROM customer) c
GROUP BY
    v.vendor_name,
    p.product_name;


-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */

-- Creating new table
CREATE TABLE product_units AS
SELECT 
    product_id,
    product_name,
    product_size,
    product_qty_type,
    product_category_id
FROM 
    product
WHERE 
    product_qty_type = 'unit';

-- Adding new column Current_timestamp in new table
ALTER TABLE product_units
ADD COLUMN snapshot_timestamp TIMESTAMP;

-- Rename timestamp col to snapshot_timestamp
UPDATE product_units
SET snapshot_timestamp = CURRENT_TIMESTAMP;

/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */

INSERT INTO product_units (product_id, product_name, product_size, product_qty_type, product_category_id, snapshot_timestamp)
VALUES (1007, 'Ice cream cake', 'Large', 'unit', '98', CURRENT_TIMESTAMP);

-- DELETE
/* 1. Delete the older record for the whatever product you added. 

HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/

DELETE FROM product_units WHERE product_name = 'Ice cream cake' AND product_category_id='98';

-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;

Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 
Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
When you have all of these components, you can run the update statement. */


ALTER TABLE product_units ADD current_quantity INT;

-- Update the current_quantity in product_units with the latest quantity from vendor_inventory

UPDATE product_units SET current_quantity = (
    SELECT COALESCE(vi.quantity, 0)
    FROM vendor_inventory vi
    WHERE vi.product_id = product_units.product_id
    ORDER BY vi.market_date DESC
    LIMIT 1
);


