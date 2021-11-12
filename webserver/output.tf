/*
output "london_ec2_connect_url" {
  value = var.region == "london" ? module.webserver-london.ec2_connect_url : "NONE"
}

output "london_web_server_url" {
  value = var.region == "london" ? module.webserver-london.web_server_url : "NONE"
}

output "ireland_ec2_connect_url" {
  value = var.region == "ireland" ? module.webserver-ireland.ec2_connect_url : "NONE"
}

output "ireland_web_server_url" {
  value = var.region == "ireland" ? module.webserver-ireland.web_server_url : "NONE"
}
*/

output "ireland_ec2_connect_url" {
  value = module.webserver-ireland.ec2_connect_url
}

output "ireland_web_server_url" {
  value = module.webserver-ireland.web_server_url
}
