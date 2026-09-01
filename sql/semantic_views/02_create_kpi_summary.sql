CREATE OR REPLACE VIEW
`datapulse-v0.datapulse_semantic.kpi_summary` AS

WITH base AS (

    SELECT
        COUNT(*) AS total_events,

        COUNT(DISTINCT customer_key) AS unique_users,

        COUNT(DISTINCT CASE
            WHEN event_name = 'view_item'
            THEN customer_key
        END) AS product_viewers,

        COUNT(DISTINCT CASE
            WHEN event_name = 'add_to_cart'
            THEN customer_key
        END) AS add_to_cart_users,

        COUNT(DISTINCT CASE
            WHEN event_name = 'begin_checkout'
            THEN customer_key
        END) AS checkout_users,

        COUNT(DISTINCT CASE
            WHEN event_name = 'purchase'
             AND purchase_quality_status = 'valid'
            THEN customer_key
        END) AS unique_purchasers,

        COUNTIF(event_name = 'purchase')
            AS purchase_events,

        COUNTIF(
            event_name = 'purchase'
            AND purchase_quality_status = 'valid'
        ) AS valid_purchases,

        COUNTIF(
            event_name = 'purchase'
            AND purchase_quality_status != 'valid'
        ) AS invalid_purchases,

        SUM(
            CASE
                WHEN event_name = 'purchase'
                 AND purchase_quality_status = 'valid'
                THEN purchase_revenue
                ELSE 0
            END
        ) AS revenue,

        SUM(
            CASE
                WHEN event_name = 'purchase'
                 AND purchase_quality_status = 'valid'
                THEN total_item_quantity
                ELSE 0
            END
        ) AS items_purchased,

        COUNT(DISTINCT CASE
            WHEN identity_status != 'anonymous'
            THEN customer_key
        END) AS identified_users,

        COUNT(DISTINCT CASE
            WHEN identity_status = 'anonymous'
            THEN customer_key
        END) AS anonymous_users

    FROM `datapulse-v0.datapulse_semantic.events_semantic`
)

SELECT
    *,

    SAFE_DIVIDE(
        unique_purchasers,
        product_viewers
    ) AS view_to_purchase_rate,

    SAFE_DIVIDE(
        checkout_users,
        add_to_cart_users
    ) AS cart_to_checkout_rate,

    SAFE_DIVIDE(
        unique_purchasers,
        checkout_users
    ) AS checkout_to_purchase_rate,

    SAFE_DIVIDE(
        revenue,
        valid_purchases
    ) AS average_order_value,

    SAFE_DIVIDE(
        identified_users,
        unique_users
    ) AS identity_stitch_rate,

    SAFE_DIVIDE(
        valid_purchases,
        purchase_events
    ) AS purchase_quality_rate

FROM base;
