USE olist_business_intelligence;

SELECT
    COUNT(*) AS total_orders,
    SUM(order_id IS NULL OR order_id = '') AS missing_order_ids,
    SUM(customer_id IS NULL OR customer_id = '') AS missing_customer_ids,
    SUM(order_status IS NULL OR order_status = '') AS missing_status,
    SUM(order_delivered_customer_date IS NULL
        OR order_delivered_customer_date = '') AS missing_delivery_dates
FROM olist_orders_dataset;

SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_orders
FROM olist_orders_dataset;

-- Analyze Order Statuses 
SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM olist_orders_dataset),
        2
    ) AS percentage
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;

-- Analyze Delivery Performance
SELECT
    COUNT(*) AS total_delivered_orders,

    SUM(
        CAST(order_delivered_customer_date AS DATETIME) <=
        CAST(order_estimated_delivery_date AS DATETIME)
    ) AS on_time_deliveries,

    SUM(
        CAST(order_delivered_customer_date AS DATETIME) >
        CAST(order_estimated_delivery_date AS DATETIME)
    ) AS late_deliveries,

    ROUND(
        100.0 * SUM(
            CAST(order_delivered_customer_date AS DATETIME) >
            CAST(order_estimated_delivery_date AS DATETIME)
        ) / COUNT(*),
        2
    ) AS late_delivery_percentage

FROM olist_orders_dataset

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date != ''
  AND order_estimated_delivery_date IS NOT NULL
  AND order_estimated_delivery_date != '';
  
-- Customer Satisfaction Analysis
USE olist_business_intelligence;

SELECT
    review_score,
    COUNT(*) AS total_reviews,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM olist_order_reviews_dataset),
        2
    ) AS percentage
FROM olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score DESC;

-- Does Late Delivery Affect Customer Satisfaction? 
USE olist_business_intelligence;

SELECT
    CASE
        WHEN CAST(o.order_delivered_customer_date AS DATETIME)
             > CAST(o.order_estimated_delivery_date AS DATETIME)
        THEN 'Late Delivery'
        ELSE 'On-Time Delivery'
    END AS delivery_status,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(AVG(r.review_score), 2) AS average_review_score

FROM olist_orders_dataset o

INNER JOIN (
    SELECT
        order_id,
        AVG(review_score) AS review_score
    FROM olist_order_reviews_dataset
    GROUP BY order_id
) r
ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
AND o.order_delivered_customer_date != ''
AND o.order_estimated_delivery_date IS NOT NULL
AND o.order_estimated_delivery_date != ''

GROUP BY delivery_status;

-- Revenue & Financial Performance Analysis
USE olist_business_intelligence;

-- Calculate total product sales for delivered orders

SELECT
    COUNT(DISTINCT oi.order_id) AS total_orders,

    ROUND(SUM(oi.price), 2) AS total_product_revenue,

    ROUND(SUM(oi.freight_value), 2) AS total_shipping_charges,

    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_order_value,

    ROUND(
        SUM(oi.price) / COUNT(DISTINCT oi.order_id),
        2
    ) AS average_order_value

FROM olist_order_items_dataset oi

INNER JOIN olist_orders_dataset o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'delivered';

-- Monthly Revenue Trends 
USE olist_business_intelligence;

-- Monthly revenue from delivered orders

SELECT
    DATE_FORMAT(
        STR_TO_DATE(o.order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'),
        '%Y-%m'
    ) AS sales_month,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(SUM(oi.price), 2) AS product_revenue,

    ROUND(SUM(oi.freight_value), 2) AS shipping_charges,

    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_order_value

FROM olist_orders_dataset o

INNER JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'delivered'

GROUP BY sales_month

ORDER BY sales_month;

-- Month-over-Month Revenue Growth 
USE olist_business_intelligence;

-- STEP 9: Monthly Revenue Growth Analysis

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(
            STR_TO_DATE(o.order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'),
            '%Y-%m'
        ) AS sales_month,

        ROUND(SUM(oi.price), 2) AS revenue

    FROM olist_orders_dataset o

    INNER JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY sales_month
),

revenue_growth AS (
    SELECT
        sales_month,
        revenue,

        LAG(revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue

    FROM monthly_revenue
)

SELECT
    sales_month,
    revenue,
    previous_month_revenue,

    ROUND(
        (revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0) * 100,
        2
    ) AS monthly_growth_percentage

FROM revenue_growth

ORDER BY sales_month;

-- Top-Performing Product Categories 
USE olist_business_intelligence;

SELECT
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    COUNT(*) AS items_sold,

    ROUND(SUM(oi.price), 2) AS total_revenue,

    ROUND(AVG(oi.price), 2) AS average_item_price

FROM olist_order_items_dataset oi

LEFT JOIN olist_products_dataset p
    ON oi.product_id = p.product_id

LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name

GROUP BY product_category
ORDER BY total_revenue DESC
LIMIT 10;

-- STEP 11: Top 10 Sellers by Revenue

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS average_item_price

FROM olist_order_items_dataset oi

JOIN olist_sellers_dataset s
    ON oi.seller_id = s.seller_id

GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state

ORDER BY total_revenue DESC

LIMIT 10;

-- STEP 12: Customer Repeat Purchase Analysis

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)

SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,

    COUNT(*) AS total_customers,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_customers

FROM customer_orders

GROUP BY customer_type

ORDER BY total_customers DESC;

-- STEP 13: Delivery Performance Analysis

SELECT
    CASE
        WHEN DATE(order_delivered_customer_date) <=
             DATE(order_estimated_delivery_date)
        THEN 'On-Time Delivery'
        ELSE 'Late Delivery'
    END AS delivery_status,

    COUNT(*) AS total_orders,

    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_orders,

    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_days

FROM olist_orders_dataset

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL

GROUP BY delivery_status

ORDER BY total_orders DESC;

-- STEP 14: Delivery Performance vs Customer Satisfaction

WITH delivery_performance AS (
    SELECT
        order_id,
        CASE
            WHEN DATE(order_delivered_customer_date)
                 <= DATE(order_estimated_delivery_date)
            THEN 'On-Time Delivery'
            ELSE 'Late Delivery'
        END AS delivery_status
    FROM olist_orders_dataset
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
),

order_reviews AS (
    SELECT
        order_id,
        AVG(review_score) AS average_review_score
    FROM olist_order_reviews_dataset
    GROUP BY order_id
)

SELECT
    d.delivery_status,

    COUNT(*) AS total_orders_with_reviews,

    ROUND(AVG(r.average_review_score), 2)
        AS average_review_score,

    ROUND(
        SUM(CASE WHEN r.average_review_score <= 2
            THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS low_rating_percentage

FROM delivery_performance d

JOIN order_reviews r
    ON d.order_id = r.order_id

GROUP BY d.delivery_status

ORDER BY average_review_score DESC;

-- STEP 15: Monthly Revenue Growth Analysis

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(SUM(oi.price), 2) AS total_revenue

    FROM olist_orders_dataset o

    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
),

revenue_growth AS (
    SELECT
        order_month,
        total_orders,
        total_revenue,

        LAG(total_revenue) OVER (
            ORDER BY order_month
        ) AS previous_month_revenue

    FROM monthly_revenue
)

SELECT
    order_month,
    total_orders,
    total_revenue,
    previous_month_revenue,

    ROUND(
        (total_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0) * 100,
        2
    ) AS monthly_growth_percentage

FROM revenue_growth

ORDER BY order_month;

-- STEP 16: Average Order Value Analysis

WITH order_totals AS (
    SELECT
        o.order_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        SUM(oi.price) AS order_revenue

    FROM olist_orders_dataset o

    INNER JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        o.order_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
)

SELECT
    order_month,

    COUNT(*) AS total_orders,

    ROUND(SUM(order_revenue), 2) AS total_revenue,

    ROUND(AVG(order_revenue), 2) AS average_order_value

FROM order_totals

GROUP BY order_month

ORDER BY order_month;

-- STEP 17: Customer Geographic Revenue Analysis

SELECT
    c.customer_state,

    COUNT(DISTINCT c.customer_unique_id) AS total_customers,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(SUM(oi.price), 2) AS total_revenue,

    ROUND(
        SUM(oi.price) / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value

FROM olist_customers_dataset c

JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id

JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'delivered'

GROUP BY c.customer_state

ORDER BY total_revenue DESC;

-- STEP 18: Payment Method Analysis

SELECT
    p.payment_type,

    COUNT(DISTINCT p.order_id) AS total_orders,

    COUNT(*) AS total_payment_records,

    ROUND(SUM(p.payment_value), 2) AS total_payment_value,

    ROUND(AVG(p.payment_value), 2) AS average_payment_value,

    ROUND(
        COUNT(DISTINCT p.order_id) * 100.0 /
        (
            SELECT COUNT(DISTINCT order_id)
            FROM olist_order_payments_dataset
        ),
        2
    ) AS percentage_of_orders

FROM olist_order_payments_dataset p

GROUP BY p.payment_type

ORDER BY total_payment_value DESC;

-- STEP 19: Customer Review Score Distribution

WITH order_reviews AS (
    SELECT
        order_id,
        ROUND(AVG(review_score), 0) AS review_score
    FROM olist_order_reviews_dataset
    WHERE review_score BETWEEN 1 AND 5
    GROUP BY order_id
)

SELECT
    review_score,

    COUNT(*) AS total_orders,

    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_reviews

FROM order_reviews

GROUP BY review_score

ORDER BY review_score DESC;

-- STEP 20: Revenue Contribution by Product Category

WITH category_revenue AS (
    SELECT
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'Unknown'
        ) AS product_category,

        ROUND(SUM(oi.price), 2) AS total_revenue

    FROM olist_order_items_dataset oi

    LEFT JOIN olist_products_dataset p
        ON oi.product_id = p.product_id

    LEFT JOIN product_category_name_translation t
        ON p.product_category_name = t.product_category_name

    JOIN olist_orders_dataset o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY product_category
)

SELECT
    product_category,

    total_revenue,

    ROUND(
        total_revenue * 100.0 /
        SUM(total_revenue) OVER (),
        2
    ) AS revenue_contribution_percentage

FROM category_revenue

ORDER BY total_revenue DESC

LIMIT 10;

-- STEP 21: Seller Performance and Customer Satisfaction

WITH seller_sales AS (
    SELECT
        oi.seller_id,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        COUNT(*) AS items_sold,
        SUM(oi.price) AS total_revenue

    FROM olist_order_items_dataset oi

    JOIN olist_orders_dataset o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY oi.seller_id
),

order_reviews AS (
    SELECT
        order_id,
        AVG(review_score) AS average_review_score

    FROM olist_order_reviews_dataset

    GROUP BY order_id
),

seller_reviews AS (
    SELECT
        seller_orders.seller_id,
        AVG(r.average_review_score) AS average_rating

    FROM (
        SELECT DISTINCT
            oi.seller_id,
            oi.order_id

        FROM olist_order_items_dataset oi

        JOIN olist_orders_dataset o
            ON oi.order_id = o.order_id

        WHERE o.order_status = 'delivered'
    ) seller_orders

    JOIN order_reviews r
        ON seller_orders.order_id = r.order_id

    GROUP BY seller_orders.seller_id
)

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,

    ss.total_orders,
    ss.items_sold,

    ROUND(ss.total_revenue, 2) AS total_revenue,

    ROUND(sr.average_rating, 2) AS average_review_score

FROM seller_sales ss

JOIN olist_sellers_dataset s
    ON ss.seller_id = s.seller_id

LEFT JOIN seller_reviews sr
    ON ss.seller_id = sr.seller_id

ORDER BY total_revenue DESC

LIMIT 10;

-- STEP 22: Data Quality Validation

SELECT
    'Customers' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_records
FROM olist_customers_dataset

UNION ALL

SELECT
    'Orders',
    COUNT(*),
    COUNT(DISTINCT order_id)
FROM olist_orders_dataset

UNION ALL

SELECT
    'Order Items',
    COUNT(*),
    COUNT(DISTINCT order_id, order_item_id)
FROM olist_order_items_dataset

UNION ALL

SELECT
    'Payments',
    COUNT(*),
    COUNT(DISTINCT order_id, payment_sequential)
FROM olist_order_payments_dataset

UNION ALL

SELECT
    'Products',
    COUNT(*),
    COUNT(DISTINCT product_id)
FROM olist_products_dataset

UNION ALL

SELECT
    'Sellers',
    COUNT(*),
    COUNT(DISTINCT seller_id)
FROM olist_sellers_dataset

UNION ALL

SELECT
    'Reviews',
    COUNT(*),
    COUNT(DISTINCT review_id)
FROM olist_order_reviews_dataset

UNION ALL

SELECT
    'Geolocation',
    COUNT(*),
    COUNT(DISTINCT
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng
    )
FROM olist_geolocation_dataset

UNION ALL

SELECT
    'Category Translation',
    COUNT(*),
    COUNT(DISTINCT product_category_name)
FROM product_category_name_translation;

-- STEP 23: Check Missing Product References

SELECT
    COUNT(*) AS total_order_items,

    SUM(
        CASE
            WHEN p.product_id IS NULL THEN 1
            ELSE 0
        END
    ) AS items_with_missing_products,

    COUNT(
        DISTINCT CASE
            WHEN p.product_id IS NULL THEN oi.product_id
        END
    ) AS unique_missing_products

FROM olist_order_items_dataset oi

LEFT JOIN olist_products_dataset p
    ON oi.product_id = p.product_id;
    
-- STEP 24: Create a temporary import table

CREATE TABLE olist_products_backup
LIKE olist_products_dataset;

-- STEP 24.3: Verify Products Import

SELECT
    COUNT(*) AS total_products,
    COUNT(DISTINCT product_id) AS unique_products
FROM olist_products_backup;

SELECT COUNT(*) AS total_products
FROM olist_products_backup;

-- STEP 24.6: Check Duplicate Products

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_id) AS unique_products,
    COUNT(*) - COUNT(DISTINCT product_id) AS duplicate_records
FROM olist_products_backup;

-- STEP 24.7: Clear the temporary import table

TRUNCATE TABLE olist_products_backup;

-- STEP 25: Investigate Duplicate Review IDs

SELECT
    review_id,
    COUNT(*) AS occurrence_count,
    COUNT(DISTINCT order_id) AS unique_orders
FROM olist_order_reviews_dataset
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC
LIMIT 20;

-- STEP 26: Check for Exact Duplicate Reviews

SELECT
    review_id,
    order_id,
    review_score,
    COUNT(*) AS duplicate_count

FROM olist_order_reviews_dataset

GROUP BY
    review_id,
    order_id,
    review_score

HAVING COUNT(*) > 1

ORDER BY duplicate_count DESC

LIMIT 20;

-- STEP 27: Check Missing Review References

SELECT
    COUNT(*) AS total_reviews,

    SUM(
        CASE
            WHEN o.order_id IS NULL THEN 1
            ELSE 0
        END
    ) AS reviews_without_orders

FROM olist_order_reviews_dataset r

LEFT JOIN olist_orders_dataset o
    ON r.order_id = o.order_id;
    
-- STEP 28: Final Product Category Revenue Analysis

SELECT
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    COUNT(*) AS items_sold,

    ROUND(SUM(oi.price), 2) AS total_revenue,

    ROUND(
        SUM(oi.price) / COUNT(DISTINCT oi.order_id),
        2
    ) AS average_revenue_per_order

FROM olist_order_items_dataset oi

JOIN olist_orders_dataset o
    ON oi.order_id = o.order_id

LEFT JOIN olist_products_dataset p
    ON oi.product_id = p.product_id

LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name

WHERE o.order_status = 'delivered'

GROUP BY product_category

ORDER BY total_revenue DESC

LIMIT 10;

-- STEP 29: Create Tableau-Ready Sales Dataset

CREATE OR REPLACE VIEW tableau_sales_data AS

SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,

    o.order_purchase_timestamp,
    DATE(o.order_purchase_timestamp) AS order_date,
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,

    c.customer_unique_id,
    c.customer_city,
    c.customer_state,

    s.seller_city,
    s.seller_state,

    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,

    oi.price AS item_revenue,
    oi.freight_value,

    o.order_status

FROM olist_order_items_dataset oi

JOIN olist_orders_dataset o
    ON oi.order_id = o.order_id

LEFT JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id

LEFT JOIN olist_products_dataset p
    ON oi.product_id = p.product_id

LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name

LEFT JOIN olist_sellers_dataset s
    ON oi.seller_id = s.seller_id

WHERE o.order_status = 'delivered';

-- STEP 30: Validate Tableau Sales Dataset

SELECT
    COUNT(*) AS total_items,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_unique_id) AS total_customers,
    ROUND(SUM(item_revenue), 2) AS total_revenue,
    ROUND(SUM(freight_value), 2) AS total_freight
FROM tableau_sales_data;

SELECT *
FROM tableau_sales_data;

-- STEP 31: Customer Retention Analysis
-- One row per customer

CREATE OR REPLACE VIEW tableau_customer_retention AS

SELECT
    customer_unique_id,
    COUNT(DISTINCT order_id) AS total_orders,

    CASE
        WHEN COUNT(DISTINCT order_id) > 1
        THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END AS customer_type

FROM (
    SELECT
        c.customer_unique_id,
        o.order_id

    FROM olist_orders_dataset o

    JOIN olist_customers_dataset c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'
) AS customer_orders

GROUP BY customer_unique_id;

-- STEP 32: Validate Customer Retention

SELECT
    customer_type,
    COUNT(*) AS total_customers,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM tableau_customer_retention),
        2
    ) AS percentage
FROM tableau_customer_retention
GROUP BY customer_type
ORDER BY total_customers DESC;

-- STEP 33: Export Customer Retention Data for Tableau

SELECT *
FROM tableau_customer_retention;