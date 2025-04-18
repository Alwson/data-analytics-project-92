select
COUNT(customer_id) as customers_count
from customers;   
#считает количество покупателей



select
  	CONCAT(employees.first_name,' ', employees.last_name) as seller,
  	COUNT(sales.sales_id) as operations,
  	FLOOR(SUM(sales.quantity*products.price)) as income
from sales
left join employees on sales.sales_person_id = employees.employee_id 
left join products on sales.product_id  = products.product_id 
group by seller
order by income desc
limit 10; 
#показывает 10 продавцов с наибольшей выручкой



with sellers as
	(
select
  CONCAT(employees.first_name, ' ', employees.last_name) as seller,
  COUNT(sales.sales_id) as operations,
  ROUND(SUM(sales.quantity*products.price), 0) as income,
  SUM(sales.quantity*products.price)/COUNT(sales.sales_id) as average_income 
from sales
left join employees on sales.sales_person_id = employees.employee_id 
left join products on sales.product_id  = products.product_id 
group by seller
order by income desc)
select
  seller,
  ROUND(average_income, 0) as average_income
from sellers
where average_income < (select sum(income)/sum(operations) from sellers)
order by average_income ASC;
#показывает продавцов, чья выручка ниже, чем средняя по всем продавцам
	
	
	
select
  	CONCAT(employees.first_name,' ', employees.last_name) as seller,
  	to_char(sales.sale_date, 'day') as day_of_month,
  	FLOOR(SUM(sales.quantity*products.price)) as income
from sales
left join employees on sales.sales_person_id = employees.employee_id 
left join products on sales.product_id  = products.product_id 
group by seller, day_of_month, sales.sale_date 
order by extract(isodow from sales.sale_date), seller ASC;
#показывает среднюю выручку по продавцами и дням недели 



select
	(case
		when age between 16 and 25 then '16-25'
		when age between 26 and 40 then '26-40'
		when age>=40 then '40+'
	end) as age_category,
	COUNT(customer_id) as age_count
from customers
group by age_category
order by age_category; 
#считает кол-во покупателей по возрастным категориям



select
	to_char(sales.sale_date, 'YYYY-MM') as selling_month,
	count(distinct sales.customer_id) as total_customers,
	FLOOR(SUM(sales.quantity*products.price)) as income
from sales
left join products on sales.product_id=products.product_id
group by selling_month, sales.sale_date
order by sales.sale_date;
#считает кол-во покупателей и выручку по месяцам


with 
income as
	(select
		CONCAT(c.first_name, ' ', c.last_name) as customer,
		to_char(s.sale_date, 'YYYY-MM-DD') as sale_date,
		CONCAT(e.first_name,' ', e.last_name) as seller,
		sum(s.quantity*p.price) as income,
		s.customer_id as cust_id
	from sales as s
	left join customers as c on s.customer_id=c.customer_id
	left join employees as e on s.sales_person_id=e.employee_id
	left join products as p on s.product_id=p.product_id
	group by customer, sale_date, seller, cust_id 
	order by customer, sale_date),
sn as
	(select
		customer,
		sale_date,
		seller,
		income,
		cust_id,
		row_number() over (partition by customer order by sale_date) as sale_number
	from income)
select
	customer,
	sale_date,
	seller
from sn
where sale_number=1 and income=0
order by cust_id;
#показывает покупателей, первая покупка которых была в ходе проведения 
акций (акционные товары отпускали со стоимостью равной 0)
