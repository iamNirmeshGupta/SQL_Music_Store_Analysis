'''Q1: Who is the senior most employee based on job title?'''

select * from employee
'''SOlution'''
select * from employee where reports_to is null;

'''Q2: Which countries have the most invoices?'''

select * from invoice
'''Solution'''
select billing_country, count(*) as counts from invoice
group by billing_country
order by counts desc

'''Q3: What are top 3 values of total invoice?'''

Select total from invoice
order by total desc 
limit 3

'''Q4: Which city has the best customers? We would like to throw a promotional music 
festival in the city we made the most money. Write a query that returns one city that
highest sum of invoice totals. Return both the city name and total.'''

select * from invoice

select billing_city, sum(total) as total from invoice
group by billing_city
order by total desc
limit 1

'''Which customer has spent the most money?'''

select * from customer

select c.customer_id, c.first_name, c.last_name, sum(i.total) from customer c
inner join invoice i on c.customer_id=i.customer_id
group by c.customer_id
order by sum(total) desc
limit 1

'''Q6: Write a query to return the email, first_name, last_name, Genre of all rock 
music listeners. Return your list ordered by email from Ato Z'''

select * from genre

select distinct email, first_name, last_name, g.name from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line l on i.invoice_id=l.invoice_id
join track t on l.track_id=t.track_id
join genre g on t.genre_id=g.genre_id
where g.name = 'Rock'
order by email

'''Q7: Let"s invite the artists who have written the most rock music in our dataset.
Write a query to return the artist name and total track count of the top 10 rock
bands'''

select a.name, count(distinct t.track_id) as track_count from artist a
join album b on a.artist_id=b.artist_id
join track t on b.album_id=t.album_id
join genre g on t.genre_id=g.genre_id
where g.name='Rock'
group by a.name
order by track_count desc
limit 10;

'''Q8: Return all the track names that have a song length more than the average song
length. Return the name and milliseconds for each track. order by song length from
highest to lowest'''

select * from track

select name, milliseconds from track
where milliseconds>(select avg(milliseconds) from track)
order by milliseconds desc;

'''Q9: Find how much amount spent by each customer on artists. Write a
query to return customer name, artist name and total spent '''

with best_selling_artist as (
 	select ar.artist_id as artist_id, ar.name as artist_name,
	sum(il.unit_price*il.quantity) as total_sales
	from invoice_line il
	join track t on t.track_id=il.track_id
	join album a on a.album_id = t.album_id
	join artist ar on ar.artist_id = a.artist_id
	group by 1
	order by 3 desc
	limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i 
join customer c on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=il.track_id
join album al on al.album_id=t.album_id
join best_selling_artist bsa on bsa.artist_id=al.artist_id
group by 1,2,3,4
order by 5 desc;

'''Q10: We want to find out most popular music genre for each country. Most popular
genre is the genre with the highest amount of purchases. Write a query that returns 
each country along with the top Genre. For countries where maximum number of genre
is shared, return all genres.'''

with cte as (
select count(il.quantity) as purchases, c.country, g.name, g.genre_id,
row_number() over(partition by c.country order by count(il.quantity) desc) as rowno
from invoice_line il
join invoice i on il.invoice_id=i.invoice_id
join customer c on c.customer_id=i.customer_id
join track t on t.track_id = il.track_id
join genre g on g.genre_id=t.genre_id
group by 2,3,4
order by 2, 1 desc
)
select * from cte where rowno<=1;

'''Q11: Write a query that determines the customer that has spent the most on music
for each country. Return country, top customer, and the amount spent.'''

with cte as (
	select i.billing_country, c.first_name, c.last_name, sum(i.total), 
	dense_rank() over (partition by i.billing_country order by sum(i.total) desc) as
	rank_ from customer c
	join invoice i on c.customer_id=i.customer_id
	group by 1,2,3
	order by 3, 4 desc
)
select * from cte where rank_=1
order by billing_country;

