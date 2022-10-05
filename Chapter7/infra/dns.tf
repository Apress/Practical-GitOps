// Pseudo Code
// if(environment==staging){
//     url = staging.gitops.rohitsalecha.com
// }elseif(environment==prod){
//     url = gitops.rohitsalecha.com
// }elseif(environment==dev){
//     url = dev.gitops.rohitsalecha.com
// }

locals {

  staging_url = var.environment == "staging" ? "staging.${var.domain}" : ""
  prod_url    = var.environment == "prod" ? "${var.domain}" : ""
  dev_url     = var.environment == "dev" ? "dev.${var.domain}" : ""

  url = coalesce(local.staging_url, local.prod_url, local.dev_url)

}

# Fetch the Zone ID of the hosted domains
data "aws_route53_zone" "domain" {
  name = "${var.domain}."

}

# Generate Certificate for the particular domain
module "acm" {
  source = "./modules/acm"

  zone_id     = data.aws_route53_zone.domain.zone_id
  domain      = local.url
  environment = var.environment

  depends_on = [module.alb_ingress]

}

# Fetching the ZoneID for ELB
data "aws_elb_hosted_zone_id" "main" {}

# Mapping The Ingress controller hostname with DNS Record
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = local.url
  type    = "A"

  alias {
    name                   = kubernetes_ingress_v1.app.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }

  depends_on = [module.alb_ingress, kubernetes_ingress_v1.app]

}