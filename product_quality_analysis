-- total revenue by year
WITH rev_sum AS (
  SELECT 
    order_yr, 
    ROUND(
      SUM(revenue)
    ) AS total_revenue_yr, 
    order_status 
  FROM 
    (
      SELECT 
        extract(
          year 
          FROM 
            t2.order_purchase_timestamp
        ) AS order_yr, 
        t1.order_id, 
        SUM(t1.price + t1.freight_value) AS revenue, 
        order_status 
      FROM 
        order_items AS t1 
        JOIN orders t2 ON t1.order_id = t2.order_id 
      WHERE 
        order_status = 'delivered' 
      GROUP BY 
        1, 
        2, 
        4
    ) AS t3 
  GROUP BY 
    1, 
    3 
  ORDER BY 
    1
), 
-- total orders canceled
canceled_orders_sum AS (
  SELECT 
    extract(
      year 
      FROM 
        tb2.order_purchase_timestamp
    ) AS order_yr, 
    count(tb1.order_id) AS total_orders_canceled_yr, 
    order_status 
  FROM 
    order_items AS tb1 
    JOIN orders tb2 ON tb1.order_id = tb2.order_id 
  WHERE 
    order_status = 'canceled' 
  GROUP BY 
    1, 
    3
), 
-- number 1 product with highest total revenue by year
-- don't forget the filter for order_status = delivered
-- we only need to calculate the delivered revenue as annual revenue
top_rev_product AS (
  SELECT 
    order_yr, 
    product_category_name AS prod_top_rev, 
    sum(revenue) AS total_rev_prod, 
    order_status 
  FROM 
    (
      SELECT 
        extract(
          year 
          FROM 
            tbl2.order_purchase_timestamp
        ) AS order_yr, 
        tbl3.product_category_name, 
        SUM(tbl1.price + tbl1.freight_value) AS revenue, 
        RANK() OVER (
          PARTITION BY extract(
            year 
            FROM 
              tbl2.order_purchase_timestamp
          ) 
          ORDER BY 
            SUM(tbl1.price + tbl1.freight_value) DESC
        ) AS rank_num, 
        order_status 
      FROM 
        order_items AS tbl1 
       JOIN orders tbl2 ON tbl1.order_id = tbl2.order_id 
       JOIN product tbl3 ON tbl3.product_id = tbl1.product_id 
      WHERE 
        order_status = 'delivered' 
      GROUP BY 
        1, 
        2, 
        5
    ) AS tbl4 
  WHERE 
    rank_num = 1 
  GROUP BY 
    1, 
    2, 
    4
), 
-- number 1 product with highest number of canceled orders by year
-- don't forget the filter for order_status = canceled
-- we only need to calculate the canceled orders by year
top_canceled_product AS (
  SELECT 
    order_yr, 
    product_category_name AS top_canceled_product, 
    sum(total_orders_canceled) AS total_orders_prod_canceled, 
    order_status 
  FROM 
    (
      SELECT 
        extract(
          year 
          FROM 
            tab2.order_purchase_timestamp
        ) AS order_yr, 
        tab3.product_category_name, 
        count(tab1.order_id) AS total_orders_canceled, 
        RANK() OVER (
          PARTITION BY extract(
            year 
            FROM 
              tab2.order_purchase_timestamp
          ) 
          ORDER BY 
            count(tab1.order_id) DESC
        ) AS rank_num, 
        order_status 
      FROM 
        order_items AS tab1 
        JOIN orders tab2 ON tab1.order_id = tab2.order_id 
        JOIN product tab3 ON tab3.product_id = tab1.product_id 
      WHERE 
        order_status = 'canceled' 
      GROUP BY 
        1, 
        2, 
        5
    ) AS tab4 
  WHERE 
    rank_num = 1 
  GROUP BY 
    1, 
    2, 
    4
)
 -- master table 
SELECT 
  temp1.order_yr, 
  total_revenue_yr, 
  total_orders_canceled_yr, 
  prod_top_rev, 
  total_rev_prod, 
  top_canceled_product, 
  total_orders_prod_canceled 
FROM 
  rev_sum AS temp1 
  INNER JOIN canceled_orders_sum AS temp2 ON temp1.order_yr = temp2.order_yr 
  INNER JOIN top_rev_product AS temp3 ON temp1.order_yr = temp3.order_yr 
  INNER JOIN top_canceled_product AS temp4 ON temp1.order_yr = temp4.order_yr
