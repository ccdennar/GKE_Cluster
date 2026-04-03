output "service_account_emails" {
  value = { for k, v in google_service_account.workloads : k => v.email }
}

output "service_account_ids" {
  value = { for k, v in google_service_account.workloads : k => v.id }
}