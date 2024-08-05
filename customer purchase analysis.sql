-- creating tables for data normalisation from the original data customer_data---- 
create database customer_purchase;
use customer_purchase;
#-- After uploading data with table name "customer_data" -- 

-- 1-- Data Normalization --------------------------------------------------------------------------------

# creating customers table ----------
create table customers as 
with cte as (select distinct customername,country,purchasedate 
from customer_data)
select row_number() over(order by purchasedate)+100 as customerid,
customername,country 
from cte;
#-- creating products table ----------  
create table products 
select row_number() over(order by purchasedate)+1000 as productid,Productname,ProductCategory
from customer_data;
#-- creating purchase table ----------  
create table purchase as 
with cte as (
select row_number() over (order by purchasedate)+200 as purchaseId,TransactionID,PurchaseDate,PurchaseQuantity,PurchasePrice,
cs.customerid,p.productid 
from customer_data c 
join products p on c.productname = p.productname
join customers cs on c.customername = cs.customername  and c.country = cs.country)
select purchaseid,transactionid,purchasedate,purchasequantity,purchaseprice,customerid,productid
from cte;

-- Creating relation among the tables-------------------------------------------------------------------------------
alter table customers 
add primary key (customerid);
alter table products 
add primary key (productid);
alter table purchase 
add primary key (purchaseid);
alter table purchase
add foreign key fk_purchase_customerid
 (customerid)references customers(customerid);
 alter table purchase
add foreign key fk_purchase_productid
 (productid) references products(productid);
 
#--Some Analysis Of data---------------------------------------------------------------------------------------
-- # --total purchase per customers--------
select customerid, count(distinct purchaseid) as total_purchase
from purchase
group by 
customerid
order by 
customerid;

#-- Revenue Generated per products-- 
select p.productname,
sum(ps.purchaseprice) as total_sale
from purchase ps
join
products p
on ps.productid = p.productid
group by 
p.productname
order by 
sum(ps.purchaseprice) asc;

#-- Product Category wise Quantity and revenue Generated--  
select p.productcategory,count(ps.purchasequantity) as total_quantity_per_category,sum(ps.purchaseprice) as total_price_per_category
from purchase ps
join products p
on ps.productid = p.productid
group by 
p.productcategory
order by count(ps.purchasequantity),sum(ps.purchaseprice) asc;

#-- Pivoting Product Ctegory wise Revenue Generated in Different Countries--   
with cte as ( select c.country,p.productcategory,sum(ps.purchaseprice) as total_sale
from purchase ps
join customers c
on ps.customerid = c.customerid
join products p on 
ps.productid = p.productid
group by 
purchaseid)
select 
country,
sum(case when productcategory = 'Home Appliances'  then total_sale else 0 end) as 'Home Appliances',
 sum(case when productcategory = 'Electronics'  then total_sale else 0 end) as 'Electronics'
 from cte
 group by 
 country;
 
 #-- Total Quantity Sold per Product-- 
 select p.productname ,count(ps.purchasequantity) as mx_sale
from purchase ps 
join products p 
on ps.productid = p.productid
group by p.productname;
 