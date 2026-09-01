connection: "YOUR_BIGQUERY_CONNECTION"

include: "/views/*.view.lkml"

explore: events {
  label: "DataPulse Ecommerce Events"
}
