
--------    Solution by Arminder
--------    Challenge 1
--------    https://8weeksqlchallenge.com/case-study-1/


-- question 1(What is the total amount each customer spent at the restaurant?)
select 
	S.customer_id,
	SUM(M.price)
	from sales S
	inner join menu M on M.product_id = S.product_id
	group by S.customer_id
	order by S.customer_id;



-- question 2(How many days has each customer visited the restaurant?)
select customer_id, Count(Customer_id) from (
	select 
		customer_id,
		DATE_PART('day',order_date),	
		count(*)
	from sales
		group by customer_id, DATE_PART('day',order_date) 
		order by customer_id, DATE_PART('day',order_date) ) uniquevisits
group by uniquevisits.customer_id
order by uniquevisits.customer_id



-- question 3(What was the first item from the menu purchased by each customer?)
select * from (
	select 
	S.customer_id, 
	S.order_date, 
	F.product_name, 
	F.price,
	ROW_NUMBER() over (partition by S.customer_id order by S.order_date) RN
	from sales S
	join members M on S.customer_id = M.customer_id 
	join menu  F on F.product_id = S.product_id	)  X
where X.RN = 1;



-- question4(What is the most purchased item on the menu and how many times was it purchased by all customers?)
select 
	F.product_name,
	count(*) as no_of_times_sold
	from sales S
	join menu  F on F.product_id = S.product_id
	join members M on S.customer_id = M.customer_id 
	group by F.product_name
	order by no_of_times_sold desc
limit 1;



-- question5(Which item was the most popular for each customer?)
select * from (
	select 
	M.customer_id,
	F.product_name,
	count(*) as orderCount,
	RANK() over (partition by M.customer_id order by count(*) desc) as FavDish
	from sales S
	join menu  F on F.product_id = S.product_id
	join members M on S.customer_id = M.customer_id 
	group by F.product_name, M.customer_id 
	order by M.customer_id ) X 
where X.FavDish = 1;



--question6 (Which item was purchased first by the customer after they became a member?)
select customer_id, product_name from (
	select 
		S.customer_id, 
		S.order_date, 
		F.product_name, 
		F.price,
		ROW_NUMBER() over (Partition by S.customer_id order by S.order_date asc) as RN
	from sales S
	join members M on S.customer_id = M.customer_id 
	join menu  F on F.product_id = S.product_id
	where S.order_date >= M.join_date
	order by S.customer_id, RN ) X
where X.RN = 1;



-- question7 (Which item was purchased just before the customer became a member?)
select customer_id, product_name, order_date from (
	select 
			S.customer_id, 
			S.order_date, 
			F.product_name, 
			F.price,
			RANK() over(partition by S.customer_id order by S.order_date desc) RN
		from sales S
		join members M on S.customer_id = M.customer_id
		join menu  F on F.product_id = S.product_id
		where S.order_date < M.join_date ) X
where X.RN=1;



-- question8 (What is the total items and amount spent for each member before they became a member?)
select customer_id, Count(product_id), SUM(price) from (
	select 	
			S.customer_id,
			S.product_id,
			F.price	
	from sales S
	left join members M on S.customer_id = M.customer_id
	join menu  F on F.product_id = S.product_id
	where S.order_date < M.join_date or M.join_date is null
	order by S.customer_id ) X
group by X.customer_id
order by X.customer_id;



-- question9 (If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?)
select customer_id, SUM(Points) as TotalPoints from (
	select 
		S.customer_id,
		S.product_id,
		S.order_date,
		F.product_name,
		F.price,	
		case when F.product_name = 'sushi' then 2*price*10
			else 1*price*10 end as Points
	from sales S
		left join members M on S.customer_id = M.customer_id
		join menu  F on F.product_id = S.product_id ) X
group by X.customer_id
order by TotalPoints desc;



--question10 (In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?)	
select customer_id, sum(Points) as TotalPoints from (
	select 
		S.customer_id,
		S.product_id,
		S.order_date,
		F.product_name,
		F.price,		
		case 
			when S.order_date >= M.join_date and S.order_date <= M.join_date + interval '7' day then 2*price*10
			when F.product_name = 'sushi' then 2*price*10
			else 1*price*10 end as Points			
	from sales S
	left join members M on S.customer_id = M.customer_id
	join menu  F on F.product_id = S.product_id
	where S.order_date >= M.join_date and S.order_date <= '2021-01-31' ) X
group by X.customer_id
order by TotalPoints desc;



--question11 (For each Member show flag Y, if order date is after joining date, else N)
select 
	S.customer_id,
	S.order_date,
	F.product_name,
	F.price,
	case
		when S.order_date >= M.join_date then 'Y'
		else 'N' end as member
from sales S
left join members M on S.customer_id = M.customer_id
join menu  F on F.product_id = S.product_id
order by S.customer_id, S.order_date asc
	
	

--question12 (based on question11, give ranking as required)
select 
	customer_id,
	order_date,
	product_name,
	price,
	member,
	case
		when member = 'N' then null
		else RANK() over (partition by customer_id,member order by order_date) end as ranking
	from (
		select 
			S.customer_id,
			S.order_date,
			F.product_name,
			F.price,
			case
				when S.order_date >= M.join_date then 'Y'
				else 'N' end as member
		from sales S
		left join members M on S.customer_id = M.customer_id
		join menu  F on F.product_id = S.product_id	) X
order by customer_id, order_date;
