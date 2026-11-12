resource "cloudflare_ruleset" "redirects" {
  zone_id     = local.zone_id
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"
  name        = "Redirects"
  description = "www to the apex"

  rules = [
    {
      description = "Redirect www to the apex, keeping the path and query"
      expression  = "http.host eq \"www.${var.app_zone_name}\""
      action      = "redirect"
      action_parameters = {
        from_value = {
          status_code = 301
          target_url = {
            expression = "concat(\"https://${var.app_zone_name}\", http.request.uri.path)"
          }
          preserve_query_string = true
        }
      }
    }
  ]
}
