
--------    Solution by AG-14-09-2022
--------    Challenge 2
--------    https://8weeksqlchallenge.com/case-study-2/


-- A. Pizza Metrics

--question1(How many pizzas were ordered?)
select count(*) from customer_orders;

--question2 (How many unique customer orders were made?)
select count(distinct customer_id) from customer_orders;

--question3 (How many successful orders were delivered by each runner?)
select 
	runner_id, 
	count(runner_id) 
	from runner_orders 
	where order_id not in (select order_id from runner_orders where cancellation 
						   in ('Restaurant Cancellation','Customer Cancellation')
						  ) 
group by runner_id 
order by runner_id


--question4 (How many of each type of pizza was delivered?)
select A.pizza_id, C.pizza_name, count(A.pizza_id) 
	from customer_orders A 
	inner join (
					select * from runner_orders 
					where order_id not in (select order_id from runner_orders where cancellation in ('Restaurant Cancellation','Customer Cancellation')	) 
				)  B on A.order_id = B.order_id
join pizza_names C on A.pizza_id = C.pizza_id
group by A.pizza_id, C.pizza_name;

--question5 (How many Vegetarian and Meatlovers were ordered by each customer?)
select 
	A.customer_id, 
	A.pizza_id,
	B.pizza_name, 	
	SUM(A.pizza_id) 	
from customer_orders A
inner join pizza_names B on A.pizza_id = B.pizza_id
group by A.pizza_id, A.customer_id, B.pizza_name
order by A.customer_id;


--question6 (What was the maximum number of pizzas delivered in a single order?)
select order_id, customer_id, pizzacount from (
	select 
		order_id, 
		customer_id, 
		pizzacount, 
		rank() over (order by pizzacount desc) as ra
		from (
				select orders.order_id, orders.customer_id, count(orders.pizza_id) as PizzaCount from customer_orders orders 
				join pizza_names pizza on orders.pizza_id = pizza.pizza_id
				group by orders.customer_id, orders.order_id	) 	X ) Y
where Y.ra = 1;


--question8 (How many pizzas were delivered that had both exclusions and extras?)
SELECT * FROM 
	customer_orders A 
	join (
		select * 
		from runner_orders 
		where order_id not in 
			(select order_id from runner_orders where cancellation in ('Restaurant Cancellation','Customer Cancellation'))
	) B on A.order_id = B.order_id
where A.exclusions <> '' and A.exclusions <> 'null' and A.extras <> 'null' and A.extras <> ''


--question9 (What was the total volume of pizzas ordered for each hour of the day?)

SELECT X.PizzaVolume, X.OrderHour, X.OrderDate from (
	SELECT  
		Count(pizza_id) as PizzaVolume, 
		DATE_PART('hour',order_time) as OrderHour,
		DATE_PART('day',order_time) as OrderDay,
		DATE_PART('month',order_time) as OrderMonth, 
		DATE_PART('year',order_time) as Orderyear,
		concat(DATE_PART('day',order_time),'-',DATE_PART('month',order_time),'-',DATE_PART('year',order_time)) as OrderDate
		FROM 
		customer_orders group by OrderHour, OrderDay, OrderMonth, Orderyear order by OrderDay, OrderMonth, Orderyear ASC ) X


--question10 (What was the volume of orders for each day of the week?)






------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

-- B. Runner and Customer Experience


--question5 (What was the difference between the longest and shortest delivery times for all orders?)
select 	MAX(D) - MIN(D) as DifferenceInMinutes 
from (	select 	CAST(trim(substring(duration,1,2)) as int)  as D from runner_orders where order_id not in (	select order_id from runner_orders where cancellation in ('Restaurant Cancellation','Customer Cancellation') )	) as X

