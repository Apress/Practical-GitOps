# Initialising the Logging and monitoring account with required resources
module "logging" {
  source              = "./logging"
  account             = "master"
  identity_account_id = module.identity_account.id

}

# Creating a Global Trail
resource "aws_cloudtrail" "central_cloud_trail" {

  name                          = "CentralCloudTrail"
  s3_bucket_name                = module.logging.s3_bucket_id
  s3_key_prefix                 = "trails"
  enable_log_file_validation    = true
  enable_logging                = true
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = true
  cloud_watch_logs_role_arn     = module.logging.cw_logs_role_arn
  cloud_watch_logs_group_arn    = "${module.logging.cw_logs_arn}:*"
  depends_on = [module.logging,
  aws_organizations_organization.root]
  tags = {
    terraform-managed = "true"
  }
}

module "sns_alert" {
  source = "./modules/snsemail"

  name        = "EmailAlerts"
  alert_email = var.alert_email

}


# Create an Alarm whenever a Root User Logs in
module "root_user_login_alarm" {
  source                           = "./modules/cwalarm"
  name                             = "RootLogin"
  cw_group_name                    = module.logging.cw_log_group_name
  pattern                          = "{ ($.userIdentity.type = \"Root\") && ($.userIdentity.invokedBy NOT EXISTS) && ($.eventType != \"AwsServiceEvent\") }"
  metric_filter_count              = "1"
  metric_filter_namespace          = "CloudTrailMetrics"
  description                      = "A CloudWatch Alarm that triggers if a root user is logging in."
  metric_alarm_statistic           = "Sum"
  metric_alarm_period              = "60"
  metric_alarm_threshold           = "1"
  metric_alarm_evaluation_periods  = "1"
  metric_alarm_comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_alarm_treat_missing_data  = "notBreaching"
  sns_topic_arn                    = module.sns_alert.arn

  depends_on = [aws_cloudtrail.central_cloud_trail]

}
