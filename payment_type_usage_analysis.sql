-- jumlah penggunaan masing-masing tipe pembayaran secara all time diurutkan dari yang terfavorit

SELECT

  payment_type,
  count(t1.order_id) total_transaction
FROM
  order_payments AS t1
  INNER JOIN orders AS t2 ON t1.order_id = t2.order_id
GROUP BY
  1
ORDER BY
   2 DESC;

--  Menampilkan jumlah penggunaan masing-masing tipe pembayaran secara all time diurutkan dari yang terfavorit 

SELECT
  payment_type,
  SUM(
    CASE
      WHEN extract(
        year
        from
          order_purchase_timestamp
      ) = '2016' THEN 1
    END
  ) AS "2016",
  SUM(
    CASE
      WHEN extract(
        year
        from
          order_purchase_timestamp
      ) = '2017' THEN 1
    END
  ) AS "2017",
  SUM(
    CASE
      WHEN extract(
        year
        from
          order_purchase_timestamp
      ) = '2018' THEN 1
    END
  ) AS "2018"
FROM
  order_payments tb1
  inner JOIN orders tb2 ON tb1.order_id = tb2.order_id
GROUP BY
  1
order by
  4 DESC;
