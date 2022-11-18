-- avg monthly active user by year
WITH mau as (
	SELECT order_yr,
  round(
    sum(avg_usr_actv_day) / count(DISTINCT order_mth),
    0
  ) AS avg_actv_usr_mth
FROM
  (
    SELECT
      count(DISTINCT y.customer_unique_id) / count(
        DISTINCT extract(
          day
          FROM
            x.order_purchase_timestamp
        )
      ) AS avg_usr_actv_day,
      extract(
        month
        FROM
          x.order_purchase_timestamp
      ) AS order_mth,
      extract(
        year
        FROM
          x.order_purchase_timestamp
      ) AS order_yr
    FROM
      orders AS x
      JOIN customers AS y ON x.customer_id = y.customer_id
    GROUP BY
      3,
      2
    ORDER BY
      3,
      2
  ) AS temp1
GROUP BY
  1
			 ),
  
-- New Customer by year
new_cust as (
SELECT
  count(customer_unique_id) AS new_cust_cnt,
  extract(
    year
    FROM
      temp3.new_order_at
  ) AS new_order_yr
FROM
  (
    SELECT
      y.customer_unique_id,
      min(x.order_purchase_timestamp) AS new_order_at
    FROM
      orders AS x
      JOIN customers AS y ON x.customer_id = y.customer_id
    GROUP BY
      1
  ) AS temp3
GROUP BY
  2
ORDER BY
  2

			),
  
-- Customer with repeat order by year
cust_rept as (
	SELECT
  count(y.customer_unique_id) AS cust_rept_cnt,
  extract(
    year
    FROM
      x.order_purchase_timestamp
  ) AS order_yr
FROM
  orders AS x
  JOIN customers AS y ON y.customer_id = x.customer_id
GROUP BY
  2
HAVING
  count(y.customer_unique_id) > 1
		   
		  ),
  
-- AVG. frequency order by year
freq_order as (
	SELECT
  count(x.order_id) / COUNT(y.customer_unique_id) AS avg_freq_order,
  extract(
    year
    FROM
      x.order_purchase_timestamp
  ) AS order_yr
FROM
  orders AS x
  JOIN customers AS y ON x.customer_id = y.customer_id
GROUP BY
  2
	)

-- Master Table
SELECT m.order_yr, m.avg_actv_usr_mth, n.new_cust_cnt, c.cust_rept_cnt, f.avg_freq_order
FROM
  mau AS m
  JOIN new_cust AS n ON m.order_yr = n.new_order_yr
  JOIN cust_rept AS c ON m.order_yr = c.order_yr
  JOIN freq_order AS f ON m.order_yr = f.order_yr
