module "blog" {
  source                         = "../../../../blog/infrastructure"
  domain_name                    = var.domain_name
  aws_account_id                 = var.aws_account_id
  cloudflare_zone_id             = var.cloudflare_zone_id
  cloudflare_domain_cname_name   = var.cloudflare_domain_cname_name
  cloudflare_ipv4_address_ranges = compact(split("\n", file("${path.module}/files/cloudflare-ipv4-ranges.txt")))
}

