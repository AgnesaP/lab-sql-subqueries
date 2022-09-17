use sakila;

#1.How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT  COUNT(inventory_id) copies
FROM inventory
WHERE film_id IN (SELECT  film_id  FROM
            (SELECT  film_id
            FROM film
            WHERE title = 'Hunchback Impossible') sub1);

#2. List all films whose length is longer than the average of all the films.
SELECT title, lengtH FROM film
WHERE  length > (SELECT  AVG(length)  FROM film);

#3.Use subqueries to display all actors who appear in the film Alone Trip
SELECT  first_name, last_namE FROM actor
WHERE  actor_id IN (SELECT  actor_id FROM film_actor
                   WHERE film_id IN (SELECT  film_id FROM film
                                      WHERE title = 'Alone Trip'));
                    
                    
#4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select * from category;
select * from film;
select * from film_category;

SELECT  title, film_id, category_id FROM film
JOIN film_category USING (film_id)
WHERE category_id IN (SELECT 
            category_id  FROM
            (SELECT  category_id FROM category
            WHERE name = 'family') sub1);                   
                    

#5. Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
# that will help you get the relevant information.
select * from customer;
select * from country;
select * from address;
select * from city;


SELECT  CONCAT(first_name, ' ', last_name) AS customer_names, email, country_id FROM address
        JOIN city USING (city_id)
        JOIN customer USING (address_id)
 WHERE country_id IN 
            (SELECT  country_id FROM country
             WHERE country = 'Canada');    
                
#6.Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films.
#First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

#Step 1 
# find the most prolific actor
SELECT  actor_id,  count(*) films FROM film_actor 
GROUP BY actor_id 
ORDER BY films DESC 
limit 1;


#Step 2: start from film_actor, get film and actor information using joins, and finally filter for the most prolific actor using INNER JOIN
SELECT fa.film_id,  f.title, fa.actor_id, a.first_name, a.last_name  from film_actor fa 
LEFT JOIN film f ON f.film_id = fa.film_id 
LEFT JOIN actor a ON a.actor_id = fa.actor_id 
INNER JOIN
 (
#most prolific actor
SELECT  actor_id,  count(*) films FROM film_actor 
GROUP BY actor_id 
ORDER BY films DESC 
limit 1 
 ) pa ON pa.actor_id = fa.actor_id
 ORDER BY f.title ASC; 
 
 
 
#7.Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

#Step 1: Most profitable customer ie the customer that has made the largest sum of payments
SELECT c.customer_id, SUM(p.amount) sum_payments FROM customer c 
LEFT JOIN payment as p ON c.customer_id = p.customer_id 
GROUP BY c.customer_id
ORDER BY sum_payments DESC 
LIMIT 1;

#Step 2:Films rented by most profitable customer
SELECT p.customer_id, f.film_id, f.title  FROM rental AS r 
LEFT JOIN inventory AS i ON i.inventory_ID = r.inventory_id
LEFT JOIN film f ON i.film_id = f.film_id 
INNER JOIN (
SELECT c.customer_id, SUM(p.amount) sum_payments FROM customer c 
LEFT JOIN payment as p ON c.customer_id = p.customer_id 
GROUP BY c.customer_id
ORDER BY sum_payments DESC 
LIMIT 1) p ON r.customer_id = p.customer_id
GROUP BY p.customer_id, f.film_id, f.title 
ORDER BY f.title ASC ;
 
 
 
#8.Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.

# Step 1: find the total_amount_spent by client_id
SELECT c.customer_id, SUM(p.amount) total_amount_spent FROM customer c 
LEFT JOIN payment as p ON c.customer_id = p.customer_id 
GROUP BY c.customer_id
ORDER BY total_amount_spent DESC ;

#Step 2: find the average of the total_amount_spent per client
SELECT avg(total_amount_spent) avg_total from (
SELECT c.customer_id, SUM(p.amount) total_amount_spent FROM customer c 
LEFT JOIN payment as p ON c.customer_id = p.customer_id 
GROUP BY c.customer_id) as SUB1 ;

#Step 3: find the clients who spent more than the average of the total_amount spent by each client.
#get the same query as in step1, but add a where condition using the query from step2. 
SELECT c.customer_id, SUM(p.amount) total_amount_spent FROM customer c 
LEFT JOIN payment as p ON c.customer_id = p.customer_id 
GROUP BY c.customer_id
HAVING total_amount_spent > (SELECT avg(total_amount_spent) avg_total from (
SELECT c.customer_id, SUM(p.amount) total_amount_spent FROM customer c 
LEFT JOIN payment as p ON c.customer_id = p.customer_id 
GROUP BY c.customer_id) as SUB1 );

