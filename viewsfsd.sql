use BikeStores;
select* from production.products;
select* from production.brands;
create view pro_brand_info
as
select product_name,brand_name,list_price from production.products p join
production.brands b on p.brand_id = b.brand_id

alter view pro_brand_info
as
select product_name,brand_name,list_price,model_year from production.products p join
production.brands b on p.brand_id = b.brand_id



select * from pro_brand_info;
/*Class Excercise*/
/*1*/
CREATE VIEW vw_product_details
AS
SELECT 
   product_name,
    brand_name,
    category_name,
    list_price
FROM 
    production.products p
JOIN 
    production.brands b ON p.brand_id = b.brand_id
JOIN 
    production.categories c ON p.category_id = c.category_id;

SELECT * FROM vw_product_details;

/*2*/
CREATE VIEW vw_customerorders AS
SELECT 
    o.order_id,
    o.order_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    s.store_name,
    SUM(oi.quantity) AS total_quantity
FROM 
    sales.orders o
JOIN 
    sales.customers c ON o.customer_id = c.customer_id
JOIN 
    sales.stores s ON o.store_id = s.store_id
JOIN 
    sales.order_items oi ON o.order_id = oi.order_id
GROUP BY 
    o.order_id,
    o.order_date,
    c.first_name,
    c.last_name,
    s.store_name;

	create view vw_customerorder
	as
	select order_id,order_date,customer_name,store_name,total quantity from
	sales.customers c join sales.orders o in c.customer_id = o.customer-id
	join sales.stores s on  o.store_id = s.store_id

	/*3*/
	CREATE VIEW vw_storestockslevels AS
SELECT 
    s.store_name,
    p.product_name,
    st.quantity AS store_quantity
FROM 
    production.stocks st
JOIN 
    production.products p ON st.product_id = p.product_id
JOIN 
    sales.stores s ON st.store_id = s.store_id;

	SELECT * FROM vw_storestockslevels ;

	/*4*/
	CREATE VIEW VW_TopSellingProducts AS
SELECT 
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales_amount
FROM 
    sales.order_items oi
JOIN 
    production.products p ON oi.product_id = p.product_id
GROUP BY 
    p.product_name;


SELECT * FROM VW_TopSellingProducts
ORDER BY total_quantity_sold DESC;

/*5*/

CREATE VIEW vw_orders_summary AS
SELECT 
    o.order_date,
    COUNT(o.order_id) AS total_orders,
    SUM(oi.quantity) AS total_quantity_ordered,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales_amount
FROM 
    sales.orders o
JOIN 
    sales.order_items oi ON o.order_id = oi.order_id
GROUP BY 
    o.order_date;

	select * from vw_orders_summary

	/*class practice on indexes*/
	/*1*/
	select * from production.products;
	create table product2(product_id int not null,product_name varchar(20),brand_id int,category_id int,model_year varchar(20),list_price decimal(10,2));
	
INSERT INTO product2 (product_id, product_name, brand_id, category_id, model_year, list_price) VALUES
(1, 'Mountain Bike', 1, 1, '2023', 500.00),
(2, 'Road Bike', 2, 1, '2022', 700.00),
(3, 'Hybrid Bike', 3, 2, '2021', 450.00),
(4, 'Electric Bike', 4, 2, '2023', 1200.00),
(5, 'Kids Bike', 5, 3, '2021', 300.00),
(6, 'Folding Bike', 6, 3, '2022', 650.00),
(7, 'Gravel Bike', 2, 1, '2023', 800.00),
(8, 'Cruiser Bike', 3, 2, '2020', 400.00),
(9, 'City Bike', 1, 1, '2019', 350.00),
(10, 'Track Bike', 4, 1, '2022', 950.00);

CREATE CLUSTERED INDEX IX_ListPrice ON product2 (list_price);
	SELECT product_id, product_name, list_price
FROM product2
ORDER BY list_price;
/* non clustured indexers practice*/

select * from sales.customers;
select first_name,last_name,email ,city from sales.customers where city = 'Atwater';
create index ix_cust_city on sales.customers(city);

select first_name,last_name,email ,city from sales.customers where first_name = 'Debra';
create index ix_cust_names on sales.customers(last_name,first_name);
/* non clustured excercise*/
/*1*/
CREATE NONCLUSTERED INDEX IX_ProductID ON sales.order_items (product_id);
SELECT order_id, item_id, product_id, quantity, list_price, discount
FROM sales.order_items
WHERE product_id = 20; 
select * from sales.order_items;
/*Triggers*/

create table pro_audits (cjange_id int identity primary key,
product_id int not null,
product_name varchar(255) not null,
brand_id int not null,
category_id int not null,
model_year smallint not null,
list_price decimal(10,2) not null,
updated_at datetime not null,
operation char(3) not null,check(operation = 'INS' or operation = 'DEL'))


create trigger trg_audit
on production.products
AFTER INSERT,DELETE
as
begin
insert into pro_audits
(product_id,product_name,brand_id,category_id,model_year,list_price,updated_at,operation)
select i.product_id,product_name,brand_id,category_id,model_year,i.list_price,getdate(),'INS' from inserted i
union all
select d.product_id,product_name,brand_id,category_id,model_year,d.list_price,getdate(),'DEL' from deleted d
end

insert into production.products(product_name,brand_id,category_id,model_year,list_price)
values('Test Trigger',1,1,2018,599);
select* from production.products;
select * from pro_audits;

delete from production.products where product_id = 324;

create table brand_approval(brand_id int identity primary key,brand_name varchar(255) not null,
approval_status varchar(50) not null)


create trigger trg_brand_add
on production.brands
instead of insert
as
begin
insert into brand_approval(brand_name,approval_status)
select i.brand_name,'Pending' from inserted i
end

select * from production.brands;
select* from brand_approval
insert into production.brands(brand_name) values ('LV');

/* class practice triggers*/
/*1*/
CREATE TABLE sales.order_log (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    customer_id INT NOT NULL,
    log_timestamp DATETIME DEFAULT GETDATE()
);

CREATE TRIGGER trg_after_insert_order
ON sales.orders
AFTER INSERT
AS
BEGIN
    INSERT INTO sales.order_log (order_id, order_date, customer_id, log_timestamp)
    SELECT 
        i.order_id,
        i.order_date,
        i.customer_id,
        GETDATE()
    FROM 
        inserted i;
END;

insert into sales.orders(customer_id,order_status,order_date,required_date,shipped_date,store_id,staff_id)
values(255,4,'2020-01-02','2020-01-02','2020-01-03',1,3);
select * from sales.orders;
select * from sales.order_log;
/*2*/
CREATE TABLE production.price_change_log (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    old_price DECIMAL(10, 2) NOT NULL,
    new_price DECIMAL(10, 2) NOT NULL,
    change_date DATETIME DEFAULT GETDATE()
);

CREATE TRIGGER trg_after_update_price
ON production.products
AFTER UPDATE
AS
BEGIN
    -- Insert a log entry only if list_price was updated
    INSERT INTO production.price_change_log (product_id, old_price, new_price, change_date)
    SELECT 
        i.product_id,
        d.list_price AS old_price,
        i.list_price AS new_price,
        GETDATE()
    FROM 
        inserted i
    JOIN 
        deleted d ON i.product_id = d.product_id
    WHERE 
        i.list_price <> d.list_price; -- Only log if there is a change in list_price
END;

select * from production.products;

UPDATE production.products
SET list_price = 550.00
WHERE product_id = 1; 
select * from production.price_change_log ;

/*3*/
CREATE TRIGGER trg_instead_of_delete_customer
ON sales.customers
INSTEAD OF DELETE
AS
BEGIN
    -- Check if any of the customers being deleted have associated orders
    IF EXISTS (
        SELECT 1
        FROM deleted d
        JOIN sales.orders o ON d.customer_id = o.customer_id
    )
    BEGIN
        -- If a customer has orders, raise an error and prevent deletion
        RAISERROR ('Cannot delete customer with existing orders.', 16, 1);
    END
    ELSE
    BEGIN
        -- If no orders are found, proceed with deletion
        DELETE FROM sales.customers
        WHERE customer_id IN (SELECT customer_id FROM deleted);
    END
END;

DELETE FROM sales.customers WHERE customer_id = 1; 

DELETE FROM sales.customers WHERE customer_id = 20000; 

/*4*/
CREATE TRIGGER trg_instead_of_update_stock
ON production.stocks
INSTEAD OF UPDATE
AS
BEGIN
    -- Check if any update would set the quantity below zero
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN production.stocks s ON i.store_id = s.store_id AND i.product_id = s.product_id
        WHERE i.quantity < 0
    )
    BEGIN
        -- If any quantity update is below zero, raise an error and prevent the update
        RAISERROR ('Stock quantity cannot be reduced below zero.', 16, 1);
    END
    ELSE
    BEGIN
        -- If the new quantity is valid, proceed with the update
        UPDATE production.stocks
        SET quantity = i.quantity
        FROM production.stocks s
        JOIN inserted i ON s.store_id = i.store_id AND s.product_id = i.product_id;
    END
END;

UPDATE production.stocks
SET quantity = -5 -- or any negative value
WHERE store_id = 1 AND product_id = 1; -- Replace with actual store_id and product_id


UPDATE production.stocks
SET quantity = 10 -- or any positive value
WHERE store_id = 1 AND product_id = 1; -- Replace with actual store_id and product_id



