locals {
  zone_id = "2e535ba3c51ef4badc9a14b2ef41aa55"

  github_pages_ips = {
    "6b9f9d76c54febf5e243c4e2befd7da7" = "185.199.111.153"
    "08eca9515ec932725bb8712564b7e3ae" = "185.199.110.153"
    "fd4db635b277eaad486506871100c712" = "185.199.109.153"
    "61f809ae720913f3e4a055b160cbc073" = "185.199.108.153"
  }

  dkim_selectors = {
    "1ec9450531e4cec3a937563e39eb86a0" = "dkim"
    "c83811748db7f1d50b1792cfaaa2b75b" = "dkim02"
    "3e0399151d835718e5663096656b050a" = "dkim03"
  }

  mail_exchangers = {
    "ca384f5d3a3137f69f024c472d2ec4f1" = { host = "mx1.alias.proton.me", priority = 10 }
    "77daf5aeeef7a6fead4841665bc70f66" = { host = "mx2.alias.proton.me", priority = 20 }
  }
}

resource "cloudflare_dns_record" "github_pages" {
  for_each = local.github_pages_ips
  zone_id  = local.zone_id
  name     = var.app_zone_name
  type     = "A"
  content  = each.value
  ttl      = 1
  proxied  = true
}

resource "cloudflare_dns_record" "www" {
  zone_id = local.zone_id
  name    = "www.${var.app_zone_name}"
  type    = "CNAME"
  content = "ravendarque.github.io"
  ttl     = 1
  proxied = true
  settings = {
    flatten_cname = false
  }
}

resource "cloudflare_dns_record" "dkim" {
  for_each = local.dkim_selectors
  zone_id  = local.zone_id
  name     = "${each.value}._domainkey.${var.app_zone_name}"
  type     = "CNAME"
  content  = "${each.value}._domainkey.alias.proton.me"
  ttl      = 1
  proxied  = false
  settings = {
    flatten_cname = false
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_dns_record" "mx" {
  for_each = local.mail_exchangers
  zone_id  = local.zone_id
  name     = var.app_zone_name
  type     = "MX"
  content  = each.value.host
  priority = each.value.priority
  ttl      = 1
  proxied  = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_dns_record" "spf" {
  zone_id = local.zone_id
  name    = var.app_zone_name
  type    = "TXT"
  content = "\"v=spf1 include:alias.proton.me ~all\""
  ttl     = 1
  proxied = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_dns_record" "dmarc" {
  zone_id = local.zone_id
  name    = "_dmarc.${var.app_zone_name}"
  type    = "TXT"
  content = "\"v=DMARC1; p=quarantine; pct=100; adkim=s; aspf=s\""
  ttl     = 1
  proxied = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_dns_record" "mail_domain_verification" {
  zone_id = local.zone_id
  name    = var.app_zone_name
  type    = "TXT"
  content = "\"pm-verification=kbdbuncrstppcfijdptluxaitvohap\""
  ttl     = 1
  proxied = false

  lifecycle {
    prevent_destroy = true
  }
}
