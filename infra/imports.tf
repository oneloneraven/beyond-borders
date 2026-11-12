# The zone's records predate OpenTofu; these adopt them without changing them.

import {
  for_each = local.github_pages_ips
  to       = cloudflare_dns_record.github_pages[each.key]
  id       = "${local.zone_id}/${each.key}"
}

import {
  to = cloudflare_dns_record.www
  id = "${local.zone_id}/afaff7057b22f406bd2e78d35814c24f"
}

import {
  for_each = local.dkim_selectors
  to       = cloudflare_dns_record.dkim[each.key]
  id       = "${local.zone_id}/${each.key}"
}

import {
  for_each = local.mail_exchangers
  to       = cloudflare_dns_record.mx[each.key]
  id       = "${local.zone_id}/${each.key}"
}

import {
  to = cloudflare_dns_record.spf
  id = "${local.zone_id}/2e21dd77fec9b52d74e576a5a134887a"
}

import {
  to = cloudflare_dns_record.dmarc
  id = "${local.zone_id}/bbd2732a9724eb8c4c7777cf84c8b86a"
}

import {
  to = cloudflare_dns_record.mail_domain_verification
  id = "${local.zone_id}/4e97e34568d1d152bd9173885232fbee"
}
