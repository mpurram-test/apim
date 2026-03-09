variable "resource_group_name" { type = string }
variable "api_management_name" { type = string }
variable "product_policies" { type = map(string) } # product_id => xml path
variable "product_policy_template_vars" {
	type        = map(map(string))
	description = "Optional template variables per product policy (product_id => map(var_name => value))."
	default     = {}
}
