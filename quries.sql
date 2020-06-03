/*
Rent count of family safe movies(Music, Animation, Children, Comedy, Classics, Family)
*/

   WITH rental_count AS (
  SELECT f.title film_title,
         c.name category_name,
         COUNT(rental_id) rental_count
    FROM film f
    JOIN film_category fc
      ON f.film_id = fc.film_id
    JOIN category c
      ON fc.category_id = c.category_id
    JOIN inventory i
      ON f.film_id = i.film_id
    JOIN rental r
      ON r.inventory_id = i.inventory_id
    GROUP BY 2, 1
    HAVING c.name IN ('Animation','Children','Classics','Comedy','Family','Music')
    ORDER BY 2, 1
)

SELECT category_name,
       SUM(rental_count) AS tot_rental_count
  FROM rental_count
GROUP BY 1
ORDER BY 2 DESC;

/*
What are the top 10 films according to the numbers of actors involved
*/

SELECT
   film_name AS film_name,
   number_of_actors AS number_of_actors 
FROM
   (
      SELECT
         f.title AS film_name,
         COUNT(a.actor_id) AS number_of_actors 
      FROM
         film_actor fa 
         JOIN
            film f 
            ON f.film_id = fa.film_id 
         JOIN
            actor a 
            ON a.actor_id = fa.actor_id 
      GROUP BY
         f.title
   )
   sub 
GROUP BY
   sub.film_name,
   sub.number_of_actors 
ORDER BY
   number_of_actors DESC LIMIT 10;
   
   

/*
What are the top 5 Geo-location from where most customer come from
*/
SELECT cou.country, COUNT(cus.customer_id)
FROM customer cus
JOIN address a
ON cus.address_id = a.address_id
JOIN city cit
ON a.city_id = cit.city_id
JOIN country cou
ON cit.country_id = cou.country_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 15;

/*
What is the average rental price of Dracula Crystal after each payment success?
*/

SELECT
   p.payment_date AS payment_date,
   CONCAT(first_name, ' ', last_name) AS customer_name,
   p.amount AS amount,
   AVG(P.amount) OVER (
ORDER BY
   p.payment_date) AS average_amount_of_payment 
FROM
   payment p 
   JOIN
      customer c 
      ON p.customer_id = c.customer_id 
   JOIN
      rental r 
      ON p.rental_id = r.rental_id 
   JOIN
      inventory i 
      ON i.inventory_id = r.inventory_id 
   JOIN
      film f 
      ON f.film_id = i.inventory_id 
WHERE
   f.title = 'Dracula Crystal' 
GROUP BY
   p.payment_date,
   c.first_name,
   c.last_name,
   p.amount 
having
   MIN(amount) > 0.00;