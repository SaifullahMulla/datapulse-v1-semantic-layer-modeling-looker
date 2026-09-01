CREATE OR REPLACE VIEW
  `datapulse-v0.datapulse_semantic.events_semantic` AS

SELECT
    event_date,
    event_timestamp,
    event_name,

    anonymous_id,
    user_id_at_event,
    stitched_user_id,
    customer_key,
    identity_status,

    platform,
    device_category,
    country,

    transaction_id,
    purchase_revenue,
    total_item_quantity,
    purchase_quality_status,

    -- Funnel flags
    event_name = 'view_item'
        AS is_product_view,

    event_name = 'add_to_cart'
        AS is_add_to_cart,

    event_name = 'begin_checkout'
        AS is_checkout,

    event_name = 'purchase'
        AS is_purchase,

    -- Valid purchase business rule
    event_name = 'purchase'
        AND purchase_quality_status = 'valid'
        AND transaction_id IS NOT NULL
        AS is_valid_purchase,

    -- Identity rule
    identity_status != 'anonymous'
        AS is_identified_user,

    -- Governed revenue
    CASE
        WHEN event_name = 'purchase'
         AND purchase_quality_status = 'valid'
         AND transaction_id IS NOT NULL
        THEN purchase_revenue
        ELSE 0
    END AS valid_purchase_revenue,

    -- Governed purchased quantity
    CASE
        WHEN event_name = 'purchase'
         AND purchase_quality_status = 'valid'
         AND transaction_id IS NOT NULL
        THEN total_item_quantity
        ELSE 0
    END AS valid_item_quantity

FROM `datapulse-v0.datapulse_mart.events`;
