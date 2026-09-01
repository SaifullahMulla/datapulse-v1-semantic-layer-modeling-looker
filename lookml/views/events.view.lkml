view: events {

  sql_table_name: `datapulse-v0.datapulse_mart.events` ;;

  # -------------------------
  # Identifiers
  # -------------------------

  dimension: anonymous_id {
    type: string
    sql: ${TABLE}.anonymous_id ;;
  }

  dimension: user_id_at_event {
    type: string
    sql: ${TABLE}.user_id_at_event ;;
  }

  dimension: stitched_user_id {
    type: string
    sql: ${TABLE}.stitched_user_id ;;
  }

  dimension: customer_key {
    type: string
    sql: ${TABLE}.customer_key ;;
  }

  dimension: transaction_id {
    type: string
    sql: ${TABLE}.transaction_id ;;
  }


  # -------------------------
  # Event / Identity Dimensions
  # -------------------------

  dimension: event_name {
    type: string
    sql: ${TABLE}.event_name ;;
  }

  dimension: identity_status {
    type: string
    sql: ${TABLE}.identity_status ;;
  }


  # -------------------------
  # Descriptive Dimensions
  # -------------------------

  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: device_category {
    type: string
    sql: ${TABLE}.device_category ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
  }


  # -------------------------
  # Data Quality
  # -------------------------

  dimension: purchase_quality_status {
    type: string
    sql: ${TABLE}.purchase_quality_status ;;
  }


  # -------------------------
  # Numeric Dimensions
  # -------------------------

  dimension: purchase_revenue {
    type: number
    sql: ${TABLE}.purchase_revenue ;;
  }

  dimension: total_item_quantity {
    type: number
    sql: ${TABLE}.total_item_quantity ;;
  }


  # -------------------------
  # Time Dimensions
  # -------------------------

  dimension_group: event_time {
    type: time
    timeframes: [raw, date, week, month]
    sql: ${TABLE}.event_timestamp ;;
  }

  # -------------------------
  # Core Measures
  # -------------------------

  measure: total_events {
    type: count
  }

  measure: unique_users {
    type: count_distinct
    sql: ${customer_key} ;;
  }


  # -------------------------
  # Funnel Measures
  # -------------------------

  measure: product_viewers {
    type: count_distinct
    sql: ${customer_key} ;;
    filters: [event_name: "view_item"]
  }

  measure: add_to_cart_users {
    type: count_distinct
    sql: ${customer_key} ;;
    filters: [event_name: "add_to_cart"]
  }

  measure: checkout_users {
    type: count_distinct
    sql: ${customer_key} ;;
    filters: [event_name: "begin_checkout"]
  }

  measure: unique_purchasers {
    type: count_distinct
    sql: ${customer_key} ;;
    filters: [
      event_name: "purchase",
      purchase_quality_status: "valid"
    ]
  }


  # -------------------------
  # Commerce / Quality Measures
  # -------------------------

  measure: purchase_events {
    type: count
    filters: [event_name: "purchase"]
  }

  measure: valid_purchases {
    type: count
    filters: [
      event_name: "purchase",
      purchase_quality_status: "valid"
    ]
  }

  measure: invalid_purchases {
    type: count
    filters: [
      event_name: "purchase",
      purchase_quality_status: "-valid"
    ]
  }

  measure: revenue {
    type: sum
    sql: ${purchase_revenue} ;;
    filters: [
      event_name: "purchase",
      purchase_quality_status: "valid"
    ]
    value_format: "#,##0.00"
  }

  measure: items_purchased {
    type: sum
    sql: ${total_item_quantity} ;;
    filters: [
      event_name: "purchase",
      purchase_quality_status: "valid"
    ]
  }


  # -------------------------
  # Identity Measures
  # -------------------------

  measure: identified_users {
    type: count_distinct
    sql: ${customer_key} ;;
    filters: [identity_status: "-anonymous"]
  }

  measure: anonymous_users {
    type: count_distinct
    sql: ${customer_key} ;;
    filters: [identity_status: "anonymous"]
  }


  # -------------------------
  # Derived / Calculated Measures
  # -------------------------

  measure: view_to_purchase_rate {
    type: number
    sql: ${unique_purchasers} / NULLIF(${product_viewers}, 0) ;;
    value_format: "0.00%"
  }

  measure: cart_to_checkout_rate {
    type: number
    sql: ${checkout_users} / NULLIF(${add_to_cart_users}, 0) ;;
    value_format: "0.00%"
  }

  measure: checkout_to_purchase_rate {
    type: number
    sql: ${unique_purchasers} / NULLIF(${checkout_users}, 0) ;;
    value_format: "0.00%"
  }

  measure: average_order_value {
    type: number
    sql: ${revenue} / NULLIF(${valid_purchases}, 0) ;;
    value_format: "#,##0.00"
  }

  measure: identity_stitch_rate {
    type: number
    sql: ${identified_users} / NULLIF(${unique_users}, 0) ;;
    value_format: "0.00%"
  }

  measure: purchase_quality_rate {
    type: number
    sql: ${valid_purchases} / NULLIF(${purchase_events}, 0) ;;
    value_format: "0.00%"
  }

}
