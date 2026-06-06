-- Query 1 — Monthly Revenue Trend
SELECT DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
       ROUND(SUM(oi.price)::numeric, 2)                AS gross_revenue,
       ROUND(SUM(oi.freight_value)::numeric, 2)        AS total_freight,
       ROUND(SUM(oi.price - oi.freight_value)::numeric, 2) AS net_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1 ORDER BY 1
LIMIT 10;

-- Query 2 — Category Net Revenue Analysis
SELECT ct.product_category_name_english AS category,
       COUNT(DISTINCT oi.order_id)              AS total_orders,
       ROUND(SUM(oi.price)::numeric, 2)         AS gross_revenue,
       ROUND(SUM(oi.freight_value)::numeric, 2) AS total_freight,
       ROUND(SUM(oi.price - oi.freight_value)::numeric, 2) AS net_revenue,
       ROUND(AVG(oi.freight_value / NULLIF(oi.price,0)*100)
             ::numeric, 2) AS freight_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN category_translation ct
  ON p.product_category_name = ct.product_category_name
GROUP BY 1 ORDER BY net_revenue DESC LIMIT 10;

-- Query 3 — Repeat Purchase Rate
WITH order_counts AS (
    SELECT c.customer_unique_id,
           COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT COUNT(*) AS total_customers,
       SUM(CASE WHEN total_orders >= 2 THEN 1 ELSE 0 END)
           AS repeat_customers,
       ROUND(100.0 * SUM(CASE WHEN total_orders >= 2
             THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_rate_pct
FROM order_counts;

-- Query 4 — Top Sellers by Revenue
SELECT oi.seller_id,
       COUNT(DISTINCT oi.order_id)              AS total_orders,
       ROUND(SUM(oi.price)::numeric, 2)         AS total_revenue,
       ROUND(AVG(r.review_score)::numeric, 2)   AS avg_rating,
       ROUND(AVG(oi.freight_value)::numeric, 2) AS avg_freight
FROM order_items oi
JOIN orders o  ON oi.order_id = o.order_id
JOIN reviews r ON oi.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id
ORDER BY total_revenue DESC LIMIT 10;

-- Query 5 — Delivery SLA Performance
SELECT
    COUNT(*) AS total_delivered,
    SUM(CASE WHEN order_delivered_customer_date
             <= order_estimated_delivery_date THEN 1 ELSE 0 END) AS on_time,
    SUM(CASE WHEN order_delivered_customer_date
             >  order_estimated_delivery_date THEN 1 ELSE 0 END) AS late,
    ROUND(100.0 * SUM(CASE WHEN order_delivered_customer_date
                      <= order_estimated_delivery_date
                      THEN 1 ELSE 0 END) / COUNT(*), 2) AS sla_pct,
    ROUND(AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date -
               order_estimated_delivery_date))/86400)
              ::numeric, 2) AS avg_delay_days
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;

-- Query 6 — Delivery Delay vs Review Score
SELECT
    CASE
        WHEN delay <= 0            THEN 'On Time or Early'
        WHEN delay BETWEEN 1 AND 3 THEN '1-3 Days Late'
        WHEN delay BETWEEN 4 AND 7 THEN '4-7 Days Late'
        WHEN delay BETWEEN 8 AND 14 THEN '8-14 Days Late'
        ELSE                            '15+ Days Late'
    END AS delay_bucket,
    COUNT(*) AS order_count,
    ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score
FROM (
    SELECT o.order_id,
           EXTRACT(EPOCH FROM (order_delivered_customer_date -
                   order_estimated_delivery_date))/86400 AS delay
    FROM orders o WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
) d
JOIN reviews r ON d.order_id = r.order_id
GROUP BY 1 ORDER BY 1;

-- Query 7 — High-LTV One-Time Buyers
WITH customer_metrics AS (
    SELECT c.customer_unique_id,
           COUNT(DISTINCT o.order_id) AS total_orders,
           ROUND(SUM(p.payment_value)::numeric, 2) AS total_spent,
           MAX(o.order_purchase_timestamp) AS last_order_date
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN payments  p ON o.order_id    = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT customer_unique_id, total_spent, last_order_date
FROM customer_metrics
WHERE total_orders = 1
  AND total_spent > (
        SELECT PERCENTILE_CONT(0.75) WITHIN GROUP
               (ORDER BY total_spent) FROM customer_metrics)
ORDER BY total_spent DESC LIMIT 10;

-- Query 8 — Seller Risk Identification
WITH seller_stats AS (
    SELECT oi.seller_id,
           ROUND(AVG(r.review_score)::numeric, 2) AS avg_rating,
           COUNT(DISTINCT oi.order_id) AS total_orders,
           ROUND(
               100.0 * SUM(
                   CASE
                       WHEN o.order_delivered_carrier_date > oi.shipping_limit_date
                       THEN 1 ELSE 0
                   END
               ) / COUNT(DISTINCT oi.order_id),
               2
           ) AS late_ship_pct
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN reviews r ON oi.order_id = r.order_id
    GROUP BY oi.seller_id
)
SELECT *
FROM seller_stats
WHERE avg_rating < 3.0
  AND late_ship_pct > 20
ORDER BY avg_rating ASC
LIMIT 10;

-- Query 9 — Payment Method Analysis
SELECT p.payment_type,
       COUNT(DISTINCT p.order_id)                     AS total_orders,
       ROUND(SUM(p.payment_value)::numeric, 2)        AS total_revenue,
       ROUND(AVG(p.payment_value)::numeric, 2)        AS avg_order_value,
       ROUND(AVG(p.payment_installments)::numeric, 2) AS avg_installments
FROM payments p
GROUP BY p.payment_type
ORDER BY total_revenue DESC;

-- Query 10 — Top Sellers Within Each Category
SELECT ct.product_category_name_english AS category,
       oi.seller_id,
       COUNT(DISTINCT oi.order_id)      AS total_orders,
       ROUND(SUM(oi.price)::numeric, 2) AS total_revenue,
       DENSE_RANK() OVER (
           PARTITION BY ct.product_category_name_english
           ORDER BY SUM(oi.price) DESC) AS rank_in_category
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN category_translation ct
  ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english, oi.seller_id
ORDER BY category, rank_in_category
LIMIT 10;

-- Query 11 — Cohort Retention Analysis
WITH first_purchase AS (
    SELECT c.customer_unique_id,
           DATE_TRUNC('month', MIN(o.order_purchase_timestamp))
               AS cohort_month
    FROM orders o JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
customer_orders AS (
    SELECT c.customer_unique_id,
           COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders o JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT f.cohort_month,
       COUNT(DISTINCT f.customer_unique_id) AS cohort_size,
       COUNT(DISTINCT CASE WHEN co.total_orders >= 2
                      THEN f.customer_unique_id END) AS repeat_customers,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN co.total_orders >= 2
                           THEN f.customer_unique_id END)
             / COUNT(DISTINCT f.customer_unique_id), 2) AS retention_rate_pct
FROM first_purchase f
JOIN customer_orders co ON f.customer_unique_id = co.customer_unique_id
GROUP BY f.cohort_month ORDER BY f.cohort_month
LIMIT 10;