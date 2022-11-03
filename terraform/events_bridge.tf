#------------------------------------------------------------------------------
# CLOUDWATCH EVENT ROLE
#------------------------------------------------------------------------------
data "aws_iam_policy_document" "scheduled_task_cw_event_role_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "scheduled_task_cw_event_role_cloudwatch_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask"]
    resources = ["*"]
  }
  statement {
    actions   = ["iam:PassRole"]
    resources = ["*"]
    #resources = var.ecs_task_role_arn == null ? [var.ecs_execution_task_role_arn] : [var.ecs_execution_task_role_arn, var.ecs_task_role_arn]
  }
}

resource "aws_iam_role" "scheduled_task_cw_event_role" {
  name               = "cargarage-st-cw-role"
  assume_role_policy = data.aws_iam_policy_document.scheduled_task_cw_event_role_assume_role_policy.json
}

resource "aws_iam_role_policy" "scheduled_task_cw_event_role_cloudwatch_policy" {
  name   = "cargarage-st-cw-policy"
  role   = aws_iam_role.scheduled_task_cw_event_role.id
  policy = data.aws_iam_policy_document.scheduled_task_cw_event_role_cloudwatch_policy.json
}

#------------------------------------------------------------------------------
# CLOUDWATCH EVENT RULE
#------------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "cargarage_cron_event_rule" {
  name                = "CargarageCronEventTest"
  description         = "Cargarage Cron Event Test"
  schedule_expression = "cron(0 10 * * 5)" #At 10:00 AM, only on Friday
}

resource "aws_cloudwatch_event_rule" "cargarage_s3_upload_event_rule" {
  name        = "CargarageS3UploadEventTest"
  description = "Capture S3 events on upload to bucket"
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

#------------------------------------------------------------------------------
# CLOUDWATCH EVENT TARGET
#------------------------------------------------------------------------------
resource "aws_cloudwatch_event_target" "cargarage_cron_event_target" {
  arn  = "${aws_api_gateway_stage.cargarageAPIGatewayStage.execution_arn}/GET"
  rule = aws_cloudwatch_event_rule.cargarage_cron_event_rule.id

  http_target {
    query_string_parameters = {
      Body = "$.detail.body"
    }
    header_parameters = {
      Env = "Dev"
    }
  }
}

resource "aws_cloudwatch_event_target" "cargarage_s3_upload_event_target" {
  arn  = "${aws_api_gateway_stage.cargarageAPIGatewayStage.execution_arn}/GET"
  rule = aws_cloudwatch_event_rule.cargarage_s3_upload_event_rule.id

  http_target {
    query_string_parameters = {
      Body = "$.detail.body"
    }
    header_parameters = {
      Env = "Dev"
    }
  }
}

/*
resource "aws_cloudwatch_event_bus" "order" {
  name = "orders"
}

resource "aws_cloudwatch_event_archive" "order" {
  name             = "order-archive"
  description      = "Archived events from order service"
  event_source_arn = aws_cloudwatch_event_bus.order.arn
  retention_days   = 7
  event_pattern    = <<PATTERN
{
  "source": ["company.team.order"]
}
PATTERN
}

resource "aws_cloudwatch_event_connection" "test" {
  name               = "ngrok-connection"
  description        = "A connection description"
  authorization_type = "OAUTH_CLIENT_CREDENTIALS"

  auth_parameters {
    oauth {
      authorization_endpoint = "https://auth.url.com/endpoint"
      http_method            = "GET"

      client_parameters {
        client_id     = "1234567890"
        client_secret = "Pass1234!"
      }

      oauth_http_parameters {
        body {
          key             = "body-parameter-key"
          value           = "body-parameter-value"
          is_value_secret = false
        }

        header {
          key             = "header-parameter-key"
          value           = "header-parameter-value"
          is_value_secret = false
        }

        query_string {
          key             = "query-string-parameter-key"
          value           = "query-string-parameter-value"
          is_value_secret = false
        }
      }
    }
  }
}


resource "aws_cloudwatch_event_api_destination" "test" {
  name                             = "api-destination"
  description                      = "An API Destination"
  invocation_endpoint              = "https://api.destination.com/endpoint"
  http_method                      = "POST"
  invocation_rate_limit_per_second = 20
  connection_arn                   = aws_cloudwatch_event_connection.test.arn
}

*/
