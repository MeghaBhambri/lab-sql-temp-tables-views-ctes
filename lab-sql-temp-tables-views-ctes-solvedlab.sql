-- Creating a Customer Summary Report
-- In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, including their rental history and payment details.
--  The report will be generated using a combination of views, CTEs, and temporary tables.

-- Step 1: Create a View 
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
use sakila;
CREATE VIEW Rental_info_customers AS (
  SELECT c.customer_id, c.first_name, c.email,
  count(r.rental_id) as rental_count
  FROM customer as c
  join rental as r
  on c.customer_id = r.customer_id
 GROUP BY c.customer_id, c.first_name, c.email
);
-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.
CREATE TEMPORARY TABLE customer_payment AS (
  SELECT 
  rc.customer_id,
  rc.first_name,
  rc.email,
  sum(p.amount) as total_paid
  from Rental_info_customers as rc
  join payment as p
  on rc.customer_id = p.customer_id
 GROUP BY rc.customer_id, rc.first_name, rc.email
);

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
-- The CTE should include the customer's name, email address, rental count, and total amount paid.
with CustomerSummaryCTE as 
(
select 
rc.first_name,
rc.email,
rc.rental_count,
cp.total_paid
from Rental_info_customers as rc
join customer_payment AS cp
on rc.customer_id = cp.customer_id
)

SELECT *
FROM CustomerSummaryCTE;




-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count,
--  total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

WITH CustomerSummaryCTE AS (
  SELECT 
    rc.first_name,
    rc.email,
    rc.rental_count,
    cp.total_paid,
    cp.total_paid / rc.rental_count AS average_payment_per_rental
  FROM Rental_info_customers AS rc
  JOIN customer_payment AS cp ON rc.customer_id = cp.customer_id
)

SELECT
  first_name AS "Customer Name",
  email AS "Email",
  rental_count AS "Rental Count",
  total_paid AS "Total Paid",
  average_payment_per_rental AS "Average Payment per Rental"
FROM CustomerSummaryCTE;