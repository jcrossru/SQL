-- use sakila database
use sakila;

-- remove safe move
SET SQL_SAFE_UPDATES = 0;

-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select CONCAT(UPPER(first_name), ' ', UPPER(last_name)) AS 'Actor Name' from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?

select actor_id, first_name, last_name from actor where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
select * from actor where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * from actor where last_name like '%LI%' order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
-- as the difference between it and VARCHAR are significant).
alter table actor add(description blob);

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
select last_name, count(*) from actor group by last_name having count(*) > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor set first_name = 'HARPO' where last_name = 'WILLIAMS' and first_name = 'GROUCHO';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor set first_name = 'GROUCHO' where first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select staff.first_name, staff.last_name, address.address  from staff, address where staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select staff.staff_id, staff.first_name, staff.last_name, sum(payment.amount) as 'Total Amount' from payment, staff where staff.staff_id = payment.staff_id group by staff.staff_id, staff.first_name, staff.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select film.film_id, film.title, count(film_actor.film_id) as 'Number of actors' from film, film_actor where film.film_id = film_actor.film_id group by film.film_id, film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(film.film_id) as 'Number of Copies' from film, inventory where film.title = 'HUNCHBACK IMPOSSIBLE' and film.film_id = inventory.film_id;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
select customer.customer_id, customer.first_name, customer.last_name, sum(payment.amount) 
from customer, payment 
where customer.customer_id = payment.customer_id 
group by customer.customer_id, customer.first_name, customer.last_name
order by customer.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of
-- movies starting with the letters K and Q whose language is English.
select * from film
where (title like 'K%'
or title like 'Q%')
and language_id in (
select language_id from language where name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select * from actor where actor_id in (
select actor_id from film_actor where film_id in (
select film_id from film where title = 'ALONE TRIP'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all
--  Canadian customers. Use joins to retrieve this information.
select a.first_name, a.last_name, a.email
from customer a
, address b
, country c
, city d
where c.country = 'Canada'
and c.country_id = d.country_id
and b.city_id = d.city_id
and a.address_id = b.address_id;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
select c.* from category a, film_category b, film c where a.name = 'Family' and a.category_id = b.category_id and b.film_id = c.film_id;

-- 7e. Display the most frequently rented movies in descending order.
select c.film_id, c.title, count(c.title) from rental a, inventory b, film c where a.inventory_id = b.inventory_id 
and b.film_id = c.film_id group by c.film_id, c.title order by 3 desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select c.store_id, sum(a.amount) as 'Amount by store' from payment a, rental b, staff c where a.rental_id = b.rental_id and a.staff_id = c.staff_id group by c.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select a.store_id, c.city, d.country from store a, address b, city c, country d where a.address_id = b.address_id and b.city_id = c.city_id and c.country_id = d.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select d.name, sum(e.amount) from rental a, inventory b, film_category c, category d, payment e
where a.inventory_id = b.inventory_id and b.film_id = c.film_id and c.category_id = d.category_id
and a.rental_id = e.rental_id
group by d.name
order by 2 desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_file_genres_by_gross_rev AS
select d.name, sum(e.amount) from rental a, inventory b, film_category c, category d, payment e
where a.inventory_id = b.inventory_id and b.film_id = c.film_id and c.category_id = d.category_id
and a.rental_id = e.rental_id
group by d.name
order by 2 desc
limit 5;


-- 8b. How would you display the view that you created in 8a?
-- below query gets the data from the view
select * from top_file_genres_by_gross_rev;
-- below query will dispay the columns on the view.  I was not sure if the question meant display view data or display view details.
describe top_file_genres_by_gross_rev;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_file_genres_by_gross_rev;