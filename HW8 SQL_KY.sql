-- HW8 SQL

use sakila;

describe actor;

-- 1a. Display the first and last names of all actors from the table `actor`.
select first_name, last_name
from actor


-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select UPPER(CONCAT(first_name," ",last_name)) AS name FROM actor;


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
select actor_id, first_name, last_name
from actor
where first_name = "Joe";


-- 2b. Find all actors whose last name contain the letters GEN:
select * from actor
where last_name LIKE '%GEN%';


-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * from actor
where last_name like '%LI%'
order by last_name, first_name;


-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

describe country;

select country_id, country
from country
where country IN ('Afghanistan', 'Bangladesh', 'China');


-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type 
-- BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

ALTER TABLE actor
ADD description BLOB;

-- check the result
describe actor;


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP description;
-- check the result
describe actor;


-- 4a. List the last names of actors, as well as how many actors have that last name.
select distinct last_name, count(last_name) as 'name_count'
from actor
group by last_name;


-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select distinct last_name, count(last_name) as 'name_count'
from actor
group by last_name
having name_count >=2;


-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor
set first_name = 'Harpo'
where first_name = 'Groucho' and last_name = 'Williams';


-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor
#set first_name = case
#where first_name = 'Harpo'
#then 'Groucho';


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;

create table if not exists address (
		address_id auto_increment not null,
        address varchar(50) not null,
        address2 varchar(50) default null,
        district varchar(50) not null,
        city_id integer(10) not null,
        postal_code varchar(10) default null,
        phone varchar(20) not null,
        location geometry not null,
        last_update timestamp not null default current_timestamp on update current_timestamp,
        primary key(address_id)
);

        
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

-- check the table: need to use 'address_id'
describe staff;
describe address;

select staff.first_name, staff.last_name, address.address        
from staff
join address on staff.address_id = address.address_id;
join city on address.city_id = city.city_id
join country on city.country_id = country.country_id;
    

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
describe payment;
-- can use staff_id

select staff.first_name, staff.last_name, sum(payment.amount) as total_payment
from staff
join payment on staff.staff_id = payment.staff_id
where payment.payment_date LIKE '2005-08%'
group by payment.staff_id;


-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
describe film_actor;
describe film;

select title, count(actor_id) as number_of_actors
from film
inner join film_actor on film.film_id = film_actor.film_id
group by title;


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
describe inventory;

select title, count(inventory_id) as number_of_copies
from film
inner join inventory on film.film_id = inventory.film_id
where title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
describe customer;
describe payment;

select first_name, last_name, sum(amount) as total_paid
from payment
inner join customer on payment.customer_id = customer.customer_id
group by payment.customer_id
order by last_name ASC;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
describe language;

select title
from film
where title LIKE 'K%' or 'Q%' 
	and language_id IN
	(
		select language_id
		from language
		where name = 'English'
	);


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name
from actor
where actor_id in 
	(
    select actor_id
    from film_actor
    where film_id In
		(
		select film_id 
        from film
        where title = 'Alone Trip'
		)
	);
    
    
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
describe customer;
describe customer_list;

select c.first_name, c.last_name, c.email
from customer c
join customer_list cl on c.customer_id = cl.id
where cl.country = 'Canada';



-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
describe film_category;
describe category;

select title
from film
where film_id in
	(
	select film_id
    from  film_category
    where category_id in
		(
		select category_id
        from category
        where name = 'Family'
        )
	);


-- 7e. Display the most frequently rented movies in descending order.
describe rental;

select film.title, count(*) as 'rent_count'
from film, inventory, rental
where film.film_id = inventory.film_id 
	AND rental.inventory_id = inventory.inventory_id
group by inventory.film_id
order by rent_count DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
describe store;
describe staff;
describe payment;

select store.store_id, SUM(amount) as revenue
from store
inner join staff on staff.store_id = store.store_id
inner join payment on payment.staff_id = staff.staff_id
group by store.store_id


-- 7g. Write a query to display for each store its store ID, city, and country.
select store.store_id, city.city, country.country
from store
inner join address on store.address_id = address.address_id
inner join city on address.city_id = city.city_id
inner join country on city.country_id = country.country_id;


-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select name, sum(p.amount) as gross_revenue
from category c
join film_category fc on fc.category_id = c.category_id
join inventory i on i.film_id = fc.film_id
join rental r on r.inventory_id = i.inventory_id
right join payment p on p.rental_id = r.rental_id
group by name
order by gross_revenue DESC
Limit 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
drop view if exists top_five_genres;

create view top_five_genres as 

select name, sum(p.amount) as gross_revenue
from category c
join film_category fc on fc.category_id = c.category_id
join inventory i on i.film_id = fc.film_id
join rental r on r.inventory_id = i.inventory_id
right join payment p on p.rental_id = r.rental_id
group by name
order by gross_revenue DESC
Limit 5;


-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;


-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;










