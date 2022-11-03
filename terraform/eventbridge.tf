module "eventbridge" {
  source = "/"

  # Schedules can only be created on default bus
  create_bus = false
  # bus_name = "cargarage-event-bus"
  create_connections = true
  create_api_destinations = true
  attach_api_destination_policy = true

  rules = {
    cargarage_cron = {
      description = "Cron trigger for cargarage api"
      schedule_expression = "cron(0 10 * * 5)"
      #At 10:00 AM, only on Friday
    }
    cargarage_s3 = {
      description = "s3 trigger for cargarage api"
      event_pattern = <<PATTERN
                  {
                    "source": ["aws.s3"],
                    "detail-type": ["S3 upload API Call"],
                    "detail": {
                      "eventSource": ["s3.amazonaws.com"],
                      "eventName": ["PutObject","CompleteMultipartUpload"],
                      "requestParameters": {
                        "bucketName": ["aws-terraform-java-springboot-eventbridge-bucket"]
                      }
                    }
                  }
                  PATTERN
    }
  }

  targets = {
    cargarage_cron = [
      {
        name = "cargarage-cron-target"
        destination = "cargarage_api"
        attach_role_arn = aws_iam_role.cargarage_eventbridge.arn
        input = jsonencode({
          "job" : "cron-by-rate"
        })
      }
    ]
  }

  /*connections = {
    cargarage_api = {
      authorization_type = "OAUTH_CLIENT_CREDENTIALS"
      auth_parameters = {
        oauth = {
          authorization_endpoint = "https://smee.io/hgoubgoibwekt331"
          http_method            = "GET"

          client_parameters = {
            client_id     = "1234567890"
            client_secret = "Pass1234!"
          }

          oauth_http_parameters = {
            body = [{
              key             = "body-parameter-key"
              value           = "body-parameter-value"
              is_value_secret = false
            }]

            header = [{
              key   = "header-parameter-key1"
              value = "header-parameter-value1"
            }, {
              key             = "header-parameter-key2"
              value           = "header-parameter-value2"
              is_value_secret = true
            }]

            query_string = [{
              key             = "query-string-parameter-key"
              value           = "query-string-parameter-value"
              is_value_secret = false
            }]
          }
        }
      }
    }
  }*/

  api_destinations = {
    cargarage_api = {
      description = "cargarage api endpoint"
      invocation_endpoint = "http://${aws_alb.default.dns_name}/api/cars/"
      http_method = "GET"
      invocation_rate_limit_per_second = 200
    }
  }
}

##################
# Extra resources
##################

resource "aws_iam_role" "cargarage_eventbridge" {
  name               = "cargarage_eventbridge"
  assume_role_policy = data.aws_iam_policy_document.cargarage_assume_role.json
}

data "aws_iam_policy_document" "cargarage_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}
