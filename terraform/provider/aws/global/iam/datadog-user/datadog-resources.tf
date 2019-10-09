provider "datadog" {
  api_key = "${var.datadog_apikey}"
  app_key = "${var.datadog_appkey}"
}


resource "datadog_integration_aws" "dd-integration" {
    account_id = var.accountId
    role_name = "DatadogAWSIntegrationRole"
}
