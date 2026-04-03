output "node_pool_names" {
  value = { for k, v in google_container_node_pool.pools : k => v.name }
}

output "node_pool_ids" {
  value = { for k, v in google_container_node_pool.pools : k => v.id }
}