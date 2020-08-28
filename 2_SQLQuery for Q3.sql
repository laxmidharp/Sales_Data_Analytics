-- Q 3. Using your db, create a customers table from the customers file, 
--      and create a transactions table from the transactions file. For 
--      the following questions, we are looking for both 
--      (1) the answer to the question and 
--      (2) the SQL query used to obtain the answer.

-- CREATION OF Customer and transactionTbl Tables
 
CREATE TABLE Customer (
    id int NOT NULL PRIMARY KEY,
    first_name varchar(255) NOT NULL,
    last_name varchar(255),
	age int,
    gender varchar(255)
);

CREATE TABLE transactionTbl (
    transaction_id int NOT NULL PRIMARY KEY ,
    customer_id int,
    transaction_amount varchar(255) ,
    transaction_location varchar(255)
);

-- Validate Tables

select * from Customer;
select * from transactionTbl;

select COUNT(*) TotalRecords from Customer;
-- OUTPUT : 100
select COUNT(*) TotalRecords from transactionTbl;
-- OUTPUT : 1000

SELECT count(*) TotalColumns FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customer'
-- OUTPUT : 5
SELECT count(*) TotalColumns FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'transactionTbl'
-- OUTPUT : 4

--  ANALYSIS : 

-- Q 3a. How many transactions have a transaction amount > $200 ?
-- Ans : 788

select COUNT(*) TOTAL from transactionTbl where transaction_amount > $200;

-- Q 3b If we join the two tables then sum all transactions, grouping by 
--      customer gender, who has the highest total transaction amount ? 
--      Males or Females?
-- Ans : Male has the hightest total transaction amt 
--       gender     TotalAmt
--        Male      263878.62
--        Female    226519.55

select E1.gender, sum(CONVERT(FLOAT, SUBSTRING(E2.transaction_amount, 2, LEN(E2.transaction_amount)))) TotalAmt
from Customer E1
join transactionTbl E2 ON E1.id = E2.customer_id 
group by E1.gender
ORDER BY TotalAmt desc;

-- Q 3c. List the top 3 customers with the most transactions (highest number).
-- Ans :
--  customer_id   first_name  TransactionsCount
--      46          Adam          32
--      52          Bobby         27
--      60          Michelle      27

SELECT TOP 3 T2.customer_id,T1.first_name, count(*) as TransactionsCount 
FROM Customer T1
INNER JOIN transactionTbl T2
ON T1.id = T2.customer_id
GROUP BY  T2.customer_id,T1.first_name
ORDER BY TransactionsCount desc

-- Q 3d. List the top 3 customers who have the highest total transaction amount.
-- Ans :
-- id   first_name   TotalAmt
-- 46      Adam      16203.51
-- 60     Michelle   13687.29
-- 49      carol     13480.58

select DISTINCT TOP 3 E1.id,E1.first_name, sum(CONVERT(FLOAT, SUBSTRING(E2.transaction_amount, 2, LEN(E2.transaction_amount)))) TotalAmt
from Customer E1
join transactionTbl E2 ON E1.id = E2.customer_id
group by E1.id,E1.first_name
ORDER BY TotalAmt desc;

-- Q 3e List the top 3 customers who have the highest average transaction amount.?
-- Ans :
--  id  first_name  avgValue
--  86    scott       856.69
--   8    Nancy       845.76
--   7   Theresa      828.79

select DISTINCT TOP 3 E1.id,E1.first_name, AVG(CONVERT(FLOAT, SUBSTRING(E2.transaction_amount, 2, LEN(E2.transaction_amount)))) avgValue
from Customer E1
join transactionTbl E2 ON E1.id = E2.customer_id
group by E1.id,E1.first_name
ORDER BY avgValue desc;

-- Q 3f. List the top 3 transaction locations where there is lowest average transaction amount.
-- Ans :
--  transaction_location      avgTransactions
--     Wyoming                    237.23
--     Oklahoma                   288.05
--     Nebraska                   308.09

select DISTINCT TOP 3 E2.transaction_location, AVG(CONVERT(FLOAT, SUBSTRING(E2.transaction_amount, 2, LEN(E2.transaction_amount)))) avgTransactions
from Customer E1
join transactionTbl E2 ON E1.id = E2.customer_id
group by E2.transaction_location
ORDER BY avgTransactions ASC;

-- 3g. How can we get the count of the occurence of same first name and 
--     same last name with all the records from the customer table?
-- Ans :
--  id  first_name  last_name  age  gender  first_name_occurence   last_name_occurence
--  46   Adam        Gibson    31    Male      2                     2
--  19   Adam        Greene    32    Male      2                     4
--  58   Albert      MCCOY     29    Male      1                     1
--  71   Alice       FOWler    28    Female    1                     2
--  35   Anna        Elliot    26    Female    1                     1

select
  m1.id,
  m1.first_name,
  m1.last_name,
  m1.age,
  m1.gender,
  count(*) over (partition by m1.first_name) first_name_occurence ,
  count(*) over (partition by m1.last_name) last_name_occurence
from
  Customer m1
  order by first_name, last_name

-- Q 3h. List the top 1 customer's transactions who have the highest total 
--       transaction amount in such a way that the result shows all the 
--       transaction done by the customer and the last row shows the total 
--       amount of all the transaction done by the customer.
-- Ans : 
--  id     transaction_id      transaction_amount
--  46         20                    $63.32
--  46         96                    $624.45
--  46         193                   $363.73
--  46         223                   $226.06
--  46         227                   $296.15

-- Messages
--  Total_Transactions_Amount
--         16203.5

CREATE PROCEDURE spGettotalTransaction
@ID int,
@totalSum float
AS
BEGIN
select
  m1.id,
  m2.transaction_id,
  m2.transaction_amount
from
  Customer m1
  JOIN transactionTbl m2 ON m1.id = m2.customer_id
  WHERE m1.id = @ID
  order by m2.transaction_id

PRINT 'Total_Transactions_Amount'
PRINT @totalSum
END 

Declare @ID int
Declare @totalSum float
SELECT @ID=T.id, @totalSum=T.totalAmt FROM (select TOP 1 E1.id, sum(CONVERT(FLOAT, SUBSTRING(E2.transaction_amount, 2, LEN(E2.transaction_amount)))) totalAmt
from Customer E1
join transactionTbl E2 ON E1.id = E2.customer_id
group by E1.id,E1.first_name
order by totalAmt desc) T

Execute spGettotalTransaction @ID, @totalSum

  
 -- END --

