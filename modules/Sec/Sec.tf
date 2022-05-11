
# Start by giving myself permissions to use S3 bucket for CloudTrail

data "aws_caller_identity" "current" {}


#Creating bucket for us to use

resource "aws_s3_bucket" "digitaldimensionstrail" {
  bucket        = "tf-test-trail"
  force_destroy = true
}


#Allowing Cloudtrail to access bucket, it is private by default
resource "aws_s3_bucket_policy" "digitaldimensionstrailpolicy" {
  bucket = aws_s3_bucket.digitaldimensionstrail.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.digitaldimensionstrail.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.digitaldimensionstrail.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}


# Append Policy for bucket with explicit deny to public access

resource "aws_s3_bucket_public_access_block" "denypublic" {
  bucket = aws_s3_bucket.digitaldimensionstrail.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true

  depends_on = [
    aws_s3_bucket_policy.digitaldimensionstrailpolicy
  ]
}

#Create CloudTrail and give it the bucket we just made to use
resource "aws_cloudtrail" "digitaldimensionstrailsource" {
  is_multi_region_trail         = true #enables mutliregion cloudtrail
  name                          = "tf-trail-digitaldimensionstrail"
  s3_bucket_name                = aws_s3_bucket.digitaldimensionstrail.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = true # allows for IAM events and management events
  enable_log_file_validation    = true # allows us to validate files

  #Send logs to cloudwatch
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.digitaldimensionstraillogs.arn}:*" # CloudTrail requires the Log Stream wildcard
  cloud_watch_logs_role_arn  = aws_iam_role.assume_cloudtrail.arn

  # Logging S3 events ideally it would be a specific bucket

  event_selector {
    read_write_type           = "All"
    include_management_events = true #management events are included as requested

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3"]
    }
  }


}
#creating a cloudwatch log group to intercept information
resource "aws_cloudwatch_log_group" "digitaldimensionstraillogs" {
  name = "digitaldimensionstraillogs"
}
#Giving permissions to CloudWatch to access CloudTrail Logs
resource "aws_iam_role" "assume_cloudtrail" {
  name = "role-access-for-Cloudwatch"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

#Creating KMS Key for bucket, this would be essentially placeholder variable in here with the client key

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

#CloudTrail Logs encrypted at rest

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.digitaldimensionstrail.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

#ye old bucket of logs about logs, ideally it should be another bucket in a main account away from the user
resource "aws_s3_bucket" "haveyoubeenplayingwithmylogs" {
  bucket        = "haveyoubeenplayingwithmylogs"
  force_destroy = true
}

#Enabling bucket logs
resource "aws_s3_bucket_logging" "example" {
  bucket = aws_s3_bucket.digitaldimensionstrail.id

  target_bucket = aws_s3_bucket.haveyoubeenplayingwithmylogs.id
  target_prefix = "log/"
}


#Creating SNS Topic for alerting suspicious behaviour
resource "aws_sns_topic" "sus_behaviour" {
  name = "sus_behaviour"
}
#Creating an email subscription for alerts
resource "aws_sns_topic_subscription" "email_sec" {
  topic_arn = aws_sns_topic.sus_behaviour.arn
  protocol  = "email"
  endpoint  = "emailmebro@exampleemail.com"
}
#Detecting Suspicious API Calls
resource "aws_cloudwatch_log_metric_filter" "badAPI" {

  log_group_name = aws_cloudwatch_log_group.digitaldimensionstraillogs.name
  name           = "badAPICall"
  pattern        = "{ ($.errorCode = *UnauthorizedOperation) || ($.errorCode = AccessDenied*) }"

  metric_transformation {
    name      = "numberofBadAPICalls"
    namespace = "BadAPICalls"
    value     = "1"
  }
}


resource "aws_cloudwatch_metric_alarm" "badAPIalarm" {

  alarm_name          = "badAPIcall_alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  namespace           = "BadAPICalls"

  period        = "60"
  statistic     = "Sum"
  metric_name   = "Suspicious_Behaviour_Metrics"
  threshold     = "0"
  alarm_actions = ["${aws_sns_topic.sus_behaviour.arn}"]
}

#Detecting Login with no MFA
resource "aws_cloudwatch_log_metric_filter" "noMFA" {

  log_group_name = aws_cloudwatch_log_group.digitaldimensionstraillogs.name
  name           = "noMFALogin"
  pattern        = "{ ($.eventName = ConsoleLogin) && ($.additionalEventData.MFAUsed = No) }"

  metric_transformation {
    name      = "noMFANumber"
    namespace = "noMFALogins"
    value     = "1"
  }
}


resource "aws_cloudwatch_metric_alarm" "noMFAalarm" {

  alarm_name          = "NoMFALogin_alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  namespace           = "NoMFALogins"

  period        = "60"
  statistic     = "Sum"
  metric_name   = "Suspicious_Behaviour_Metrics"
  threshold     = "0"
  alarm_actions = ["${aws_sns_topic.sus_behaviour.arn}"]
}

#Detecting root user usage
resource "aws_cloudwatch_log_metric_filter" "rootLogin" {

  log_group_name = aws_cloudwatch_log_group.digitaldimensionstraillogs.name
  name           = "rootLogin"
  pattern        = "{$.userIdentity.type = Root}"

  metric_transformation {
    name      = "numberofrootLogins"
    namespace = "RootLogins"
    value     = "1"
  }
}


resource "aws_cloudwatch_metric_alarm" "rootLoginalarm" {

  alarm_name          = "rootLogin_alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  namespace           = "RootLogins"

  period        = "60"
  statistic     = "Sum"
  metric_name   = "Suspicious_Behaviour_Metrics"
  threshold     = "0"
  alarm_actions = ["${aws_sns_topic.sus_behaviour.arn}"]
}

#VPC Deletion

#We started here, later created two new modules to work on destruction of VPC to ensure it works in every region.

# resource "aws_default_vpc" "default" {
#   tags = {
#     Name = "Default VPC"
#   }
#   force_destroy = true
#   # Trying to itterate over list of regions
#   # count  = length(var.regions)
#   # provider = var.regions[count.index]
# }
module "vpcdestroyer" {
  source = "../vpcdestroyer"
}

