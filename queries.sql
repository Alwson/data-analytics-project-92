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


WITH sel2 AS (
    SELECT
        CONCAT(employees.first_name, ' ', employees.last_name) AS seller,
        COUNT(sales.sales_id) AS operations,
        FLOOR(SUM(sales.quantity * products.price)) AS income,
        AVG(sales.quantity * products.price) AS average_income
    FROM sales
    LEFT JOIN employees ON sales.sales_person_id = employees.employee_id
    LEFT JOIN products ON sales.product_id = products.product_id
    GROUP BY employees.first_name, employees.last_name
)
SELECT
    seller,
    FLOOR(average_income) AS average_income
FROM sel2
WHERE average_income < (
    SELECT AVG(average_income) FROM sel2
)
ORDER BY average_income ASC;
--показывает продавцов, чья выручка ниже, чем средняя по всем продавцам


SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    TRIM(TO_CHAR(s.sale_date, 'Day')) AS day_of_week,
    EXTRACT(ISODOW FROM s.sale_date) AS number_day_of_week,
    FLOOR(AVG(s.quantity * p.price)) AS average_income
FROM sales s
LEFT JOIN employees e ON s.sales_person_id = e.employee_id
LEFT JOIN products p ON s.product_id = p.product_id
GROUP BY seller, day_of_week, number_day_of_week
ORDER BY number_day_of_week, seller;
--показывает среднюю выручку по продавцами и дням недели


SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 39 THEN '26-39'
        WHEN age >= 40 THEN '40+'
    END AS age_category,
    COUNT(customer_id) AS age_count
FROM customers
GROUP BY age_category
ORDER BY age_category;
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


WITH income AS (
    SELECT
        s.customer_id AS cust_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer,
        TO_CHAR(s.sale_date, 'YYYY-MM-DD') AS sale_date,
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        SUM(s.quantity * p.price) AS income
    FROM sales s
    LEFT JOIN customers c ON s.customer_id = c.customer_id
    LEFT JOIN employees e ON s.sales_person_id = e.employee_id
    LEFT JOIN products p ON s.product_id = p.product_id
    GROUP BY c.first_name, c.last_name, s.sale_date, e.first_name, e.last_name, s.customer_id
),
sn AS (
    SELECT
        customer,
        sale_date,
        seller,
        income,
        cust_id,
        ROW_NUMBER() OVER (
            PARTITION BY customer
            ORDER BY sale_date
        ) AS sale_number
    FROM income
    WHERE income = 0
)
SELECT
    customer,
    sale_date,
    seller
FROM sn
WHERE sale_number = 1
ORDER BY cust_id;
--показывает покупателей, первая покупка которых была в ходе проведения акций
