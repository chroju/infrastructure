resource "aws_cloudwatch_log_group" "prometheus" {
  name = "/k3s/prometheus"
}

resource "aws_prometheus_workspace" "k3s" {
  alias = "k3s"
  logging_configuration {
    log_group_arn = "${aws_cloudwatch_log_group.prometheus.arn}:*"
  }
}

