output "london_ec2_connect_url" {
  value = var.region == "london" ? module.webserver-london[0].ec2_connect_url : "NONE"
}

output "london_web_server_url" {
  value = var.region == "london" ? module.webserver-london[0].web_server_url : "NONE"
}

output "ireland_ec2_connect_url" {
  value = var.region == "ireland" ? module.webserver-ireland[0].ec2_connect_url : "NONE"
}

output "ireland_web_server_url" {
  value = var.region == "ireland" ? module.webserver-ireland[0].web_server_url : "NONE"
}
