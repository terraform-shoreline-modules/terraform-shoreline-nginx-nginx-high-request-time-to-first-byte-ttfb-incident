resource "shoreline_notebook" "high_nginx_request_time_to_first_byte_ttfb_incident" {
  name       = "high_nginx_request_time_to_first_byte_ttfb_incident"
  data       = file("${path.module}/data/high_nginx_request_time_to_first_byte_ttfb_incident.json")
  depends_on = [shoreline_action.invoke_nginx_config_tuning]
}

resource "shoreline_file" "nginx_config_tuning" {
  name             = "nginx_config_tuning"
  input_file       = "${path.module}/data/nginx_config_tuning.sh"
  md5              = filemd5("${path.module}/data/nginx_config_tuning.sh")
  description      = "Review and make changes to the Nginx configuration file to ensure it is optimized for performance."
  destination_path = "/tmp/nginx_config_tuning.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_nginx_config_tuning" {
  name        = "invoke_nginx_config_tuning"
  description = "Review and make changes to the Nginx configuration file to ensure it is optimized for performance."
  command     = "`chmod +x /tmp/nginx_config_tuning.sh && /tmp/nginx_config_tuning.sh`"
  params      = ["PATH_TO_CONFIG_FILE"]
  file_deps   = ["nginx_config_tuning"]
  enabled     = true
  depends_on  = [shoreline_file.nginx_config_tuning]
}

