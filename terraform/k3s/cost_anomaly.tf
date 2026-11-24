resource "aws_ce_anomaly_monitor" "services" {
  name              = "services"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "email" {
  name      = "email"
  frequency = "DAILY"
  # Notify when the total impact is $5 or more
  threshold = 5

  monitor_arn_list = [aws_ce_anomaly_monitor.services.arn]

  subscriber {
    type    = "EMAIL"
    address = var.cost_anomaly_email
  }
}
