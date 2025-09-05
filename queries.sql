select COUNT(customer_id) as customers_count
from customers;
--считает количество покупателей


select
    CONCAT(employees.first_name, ' ', employees.last_name) as seller,
    COUNT(sales.sales_id) as operations,
    FLOOR(SUM(sales.quantity * products.price)) as income
from sales
left join employees on sales.sales_person_id = employees.employee_id
left join products on sales.product_id = products.product_id
group by seller
order by income desc
limit 10;
--показывает 10 продавцов с наибольшей выручкой


with sells2 as (
    select
        CONCAT(employees.first_name, ' ', employees.last_name) as seller,
        COUNT(sales.sales_id) as operations,
        FLOOR(SUM(sales.quantity * products.price)) as income,
        AVG(sales.quantity * products.price) as average_income
    from sales
    left join employees on sales.sales_person_id = employees.employee_id
    left join products on sales.product_id = products.product_id
    group by employees.first_name, employees.last_name
)

select
    s2.seller,
    FLOOR(s2.average_income) as average_income
from sells2 as s2
where
    s2.average_income < (
        select AVG(s3.average_income) from sells2 as s3
    )
order by average_income asc;
--показывает продавцов, чья выручка ниже, чем средняя по всем продавцам


select
    CONCAT(e.first_name, ' ', e.last_name) as seller,
    LOWER(TRIM(TO_CHAR(s.sale_date, 'day'))) as day_of_week,
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
left join employees as e on s.sales_person_id = e.employee_id
left join products as p on s.product_id = p.product_id
group by seller, day_of_week, EXTRACT(isodow from s.sale_date)
order by EXTRACT(isodow from s.sale_date), seller;
--показывает среднюю выручку по продавцами и дням недели


select
    case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        when age > 40 then '40+'
    end as age_category,
    COUNT(customer_id) as age_count
from customers
group by age_category
order by age_category;
--считает кол-во покупателей по возрастным категориям


select
    TO_CHAR(sales.sale_date, 'YYYY-MM') as selling_month,
    COUNT(distinct sales.customer_id) as total_customers,
    FLOOR(SUM(sales.quantity * products.price)) as income
from sales
left join products on sales.product_id = products.product_id
group by TO_CHAR(sales.sale_date, 'YYYY-MM')
order by selling_month;
--считает кол-во покупателей и выручку по месяцам


with income as (
    select
        s.customer_id as cust_id,
        CONCAT(c.first_name, ' ', c.last_name) as customer,
        TO_CHAR(s.sale_date, 'YYYY-MM-DD') as sale_date,
        CONCAT(e.first_name, ' ', e.last_name) as seller,
        SUM(s.quantity * p.price) as income
    from sales as s
    left join customers as c on s.customer_id = c.customer_id
    left join employees as e on s.sales_person_id = e.employee_id
    left join products as p on s.product_id = p.product_id
    group by
        c.first_name, c.last_name,
        s.sale_date,
        e.first_name, e.last_name,
        s.customer_id
),

sn as (
    select
        customer,
        sale_date,
        seller,
        income,
        cust_id,
        ROW_NUMBER() over (
            partition by customer
            order by sale_date
        ) as sale_number
    from income
    where income = 0
)

select
    customer,
    sale_date,
    seller
from sn
where sale_number = 1
order by cust_id;
--показывает покупателей, первая покупка которых была в ходе проведения акций
