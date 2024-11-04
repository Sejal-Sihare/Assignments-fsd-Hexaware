use BikeStores;
/*class excercise*/
select t2.product_id,t2.product_name,t1.quantity,t2.list_price from sales.Order_items as t1 Right join production.products as t2 on t1.product_id = t2.product_id;

select stores.store_id,stores.store_name,staffs.staff_id,staffs.first_name from sales.stores cross join sales.staffs;

SELECT order_items.order_id, order_items.product_id, products.product_name, order_items.quantity, order_items.list_price
FROM sales.order_items
INNER JOIN production.products ON order_items.product_id = products.product_id;

SELECT customers.customer_id, customers.first_name, customers.last_name, orders.order_id
FROM sales.customers
LEFT JOIN sales.orders ON customers.customer_id = orders.customer_id;

create procedure sp_list_brand
as 
begin
select * from production.products where brand_id = 8;
end;
exec sp_list_brand;
alter procedure sp_list_brand
as 
begin
select * from production.products order by list_price;
end;
exec sp_list_brand;

create procedure pwp_sp_list_brand(@brd_id as int)
as
begin
select * from production.products where brand_id = @brd_id;
end;
exec pwp_sp_list_brand 7;

create procedure pr1(@minprice as decimal,@maxprice as decimal)
as
begin
select * from production.products where list_price between @minprice and @maxprice;
end;
exec pr1 500,1000;
exec pr1 @maxprice = 2000,@minprice = 200;


create procedure pr2(@minprice as decimal= 500,@maxprice as decimal)
as
begin
select * from production.products where list_price between @minprice and @maxprice;
end;
exec pr2 @minprice = 600, @maxprice = 1000;

/*class Excercise*/
/*1*/
create procedure usp_GetProductsByCategory(@cat_id as int)
as 
begin
select* from production.products where category_id= @cat_id;
end;

exec usp_GetProductsByCategory 2;

/*2*/
create procedure usp_AddCustomer2(@first as varchar,@last as varchar,@phone as varchar,@email as varchar,@street as varchar,@city as varchar,@state as varchar,@zip as varchar)
as
begin
insert into sales.customers values(@first,@last,@phone,@email,@street,@city,@state,@zip);
end

exec usp_AddCustomer2 sejal,sihare,2267838,tr@gmailcom,rease,nagpur,maharastra,2234;
/* 3*/
CREATE PROCEDURE usp_updateProductStock
    @StoreID  as INT,
    @ProductID as INT,
    @NewStockQuantity as INT
AS
BEGIN
 
    UPDATE production.stocks
    SET quantity = @NewStockQuantity
    WHERE store_id = @StoreID
      AND product_id = @ProductID;

END;
exec usp_updateProductStock 1,1,30;
select * from production.stocks;

/*4*/

CREATE PROCEDURE usp_getOrderDetails
    @OrderID as INT
AS
BEGIN
    SELECT 
        orders.order_date,
        customers.first_name + ' ' + customers.last_name AS customer_name,
        stores.store_name,
        products.product_name,
        order_items.quantity,
        order_items.list_price
    FROM sales.orders AS orders
    INNER JOIN sales.customers AS customers ON orders.customer_id = customers.customer_id
    INNER JOIN sales.stores AS stores ON orders.store_id = stores.store_id
    INNER JOIN sales.order_items AS order_items ON orders.order_id = order_items.order_id
    INNER JOIN production.products AS products ON order_items.product_id = products.product_id
    WHERE orders.order_id = @OrderID;
END;
exec usp_getOrderDetails 2;

/*5*/
CREATE PROCEDURE usp_getTotalSalesByStore
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    SELECT 
        s.store_name,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales_amount
    FROM 
        sales.orders AS o
    INNER JOIN 
        sales.order_items AS oi ON o.order_id = oi.order_id
    INNER JOIN 
        sales.stores AS s ON o.store_id = s.store_id
    WHERE 
        o.order_date BETWEEN @start_date AND @end_date
    GROUP BY 
        s.store_name
    ORDER BY 
        total_sales_amount DESC;
END;
EXEC usp_getTotalSalesByStore '2017-01-01', '2017-12-31';

