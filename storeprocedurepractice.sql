use BikeStores;
create function udf_netSales(@quantity int,@listprice decimal(10,2),@discount decimal(4,2))
returns decimal(10,2)
as
begin
return @quantity*@listprice*(1-@discount);
end;
select dbo.udf_netSales(10,100,0.1) NetSales;

select order_id,sum(dbo.udf_netSales(quantity,list_price,discount)) NetSales
from sales.Order_items
group by order_id
order by NetSales desc;

select* from sales.order_items;

/*table function*/
create function udf_pro_year(@year int)
returns table
as
return select product_name,model_year,list_price from production.products where model_year = @year;

select* from udf_pro_year(2018);
/*Class Excercise*/
/*1*/
CREATE FUNCTION CalculateDiscountedPrice
(
    @list_price DECIMAL(10, 2),
    @discount DECIMAL(4, 2)
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    RETURN @list_price * (1 - @discount);
END;
SELECT dbo.CalculateDiscountedPrice(100.00, 0.15) AS DiscountedPrice;
/*2*/

CREATE FUNCTION fn_getFullCustomerName
(
    @first_name VARCHAR(255),
    @last_name VARCHAR(255)
)
RETURNS VARCHAR(510)
AS
BEGIN
    RETURN @last_name + ', ' + @first_name;
END;

SELECT dbo.fn_getFullCustomerName(first_name, last_name) AS FullName from sales.customers;

/*3*/
CREATE FUNCTION calculateTotalOrderAmount
(
    @order_id INT
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @total_amount DECIMAL(18, 2);

    SELECT 
        @total_amount = SUM(oi.quantity * oi.list_price * (1 - oi.discount))
    FROM 
        sales.order_items AS oi
    WHERE 
        oi.order_id = @order_id;

    RETURN ISNULL(@total_amount, 0);
END;

SELECT dbo.calculateTotalOrderAmount(order_id) AS TotalOrderAmount from sales.order_items;


/*4*/
CREATE FUNCTION getProductsByBrand
(
    @brand_id INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.product_id,
        p.product_name,
        p.category_id,
        p.list_price
    FROM 
        production.products AS p
    WHERE 
        p.brand_id = @brand_id
);

SELECT * FROM dbo.getProductsByBrand(1);

/*5*/

CREATE FUNCTION fn_getOrdersByCustomer
(
    @customer_id INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        o.order_id,
        o.order_date,
        o.store_id,
        o.staff_id
    FROM 
        sales.orders AS o
    WHERE 
        o.customer_id = @customer_id
);

SELECT * FROM dbo.fn_getOrdersByCustomer(1);
/*6*/
CREATE FUNCTION fn_getStockByStore
(
    @store_id INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        s.product_id,
        p.product_name,
        s.quantity
    FROM 
        production.stocks AS s
    INNER JOIN 
        production.products AS p ON s.product_id = p.product_id
    WHERE 
        s.store_id = @store_id
);

SELECT * FROM dbo.fn_getStockByStore(1);

