# Copyright 2015 Mirantis, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

notice('fuel-plugin-kafka: hiera_override.pp')

# Initialize network-related variables
$network_scheme   = hiera_hash('network_scheme')
$network_metadata = hiera_hash('network_metadata')
prepare_network_config($network_scheme)

$kafka = hiera_hash('kafka')
$hiera_file           = '/etc/hiera/plugins/kafka.yaml'
$kafka_nodes             = get_nodes_hash_by_roles($network_metadata, ['kafka', 'primary-kafka'])
$kafka_nodes_count       = count($kafka_nodes)

#$listen_address       = get_network_role_property('kafka', 'ipaddr')
#$kafka_addresses_map     = get_node_to_ipaddr_map_by_network_role($kafka_nodes, 'kafka')
#$kafka_ip_addresses      = sort(values($kafka_addresses_map))







#if ! $network_metadata['vips']['es_vip_mgmt'] {
#   fail('Elasticsearch VIP is not defined')
#}
#$vip = $network_metadata['vips']['es_vip_mgmt']['ipaddr']

# if is_integer($elasticsearch_kibana['number_of_replicas']) and $elasticsearch_kibana['number_of_replicas'] < $es_nodes_count {
#   $number_of_replicas = 0 + $elasticsearch_kibana['number_of_replicas']
# }else{
#   # Override the replication number otherwise this will lead to a stale cluster health
#   $number_of_replicas = $es_nodes_count - 1
#   notice("Set number_of_replicas to ${number_of_replicas}")
# }

# $retention_period = $elasticsearch_kibana['retention_period']

# if is_integer($elasticsearch_kibana['minimum_master_nodes']) and $elasticsearch_kibana['minimum_master_nodes'] <= $es_nodes_count {
#   $minimum_master_nodes = 0 + $elasticsearch_kibana['minimum_master_nodes']
# } elsif $es_nodes_count > 2 {
#   $minimum_master_nodes = floor($es_nodes_count / 2 + 1)
# }else{
#   $minimum_master_nodes = 1
# }
# notice("Set minimum_master_nodes to ${minimum_master_nodes}")

# if is_integer($elasticsearch_kibana['recover_after_time']) {
#   $recover_after_time = 0 + $elasticsearch_kibana['recover_after_time']
# } else {
#   # Use the same default value as environment_config.yaml
#   # see #1593135
#   $recover_after_time = 5
#   notice("Set recover_after_time to ${recover_after_time}")
# }

# if is_integer($elasticsearch_kibana['recover_after_nodes']) and $elasticsearch_kibana['recover_after_nodes'] <= $es_nodes_count {
#   $recover_after_nodes = $elasticsearch_kibana['recover_after_nodes']
# } else {
#   if $es_nodes_count <= 1 {
#     $recover_after_nodes = 1
#   } else {
#     $recover_after_nodes = floor($es_nodes_count * 2 / 3)
#   }
#   notice("Set recover_after_nodes to ${recover_after_nodes}")
# }

# $instance_name = 'es-01'
# $logs_dir = "/var/log/elasticsearch/${instance_name}"

# $tls_enabled = $elasticsearch_kibana['tls_enabled'] or false
# if $tls_enabled {
#   $kibana_hostname = $elasticsearch_kibana['kibana_hostname']
#   $cert_base_dir = '/etc/haproxy'
#   $cert_dir = "${cert_base_dir}/certs"
#   $cert_file_path = "${cert_dir}/${elasticsearch_kibana['kibana_ssl_cert']['name']}"

#   file { $cert_base_dir:
#     ensure => directory,
#     mode   => '0755'
#   }

#   file { $cert_dir:
#     ensure  => directory,
#     mode    => '0700',
#     require => File[$cert_base_dir]
#   }

#   file { $cert_file_path:
#     ensure  => present,
#     mode    => '0400',
#     content => $elasticsearch_kibana['kibana_ssl_cert']['content'],
#     require => File[$cert_dir]
#   }
# }

# $ldap_enabled = $elasticsearch_kibana['ldap_enabled'] or false
# $ldap_protocol              = $elasticsearch_kibana['ldap_protocol']
# $ldap_servers               = split($elasticsearch_kibana['ldap_servers'], '\s+')
# $ldap_bind_dn               = $elasticsearch_kibana['ldap_bind_dn']
# $ldap_bind_password         = $elasticsearch_kibana['ldap_bind_password']
# $ldap_user_search_base_dns  = $elasticsearch_kibana['ldap_user_search_base_dns']
# $ldap_user_search_filter    = $elasticsearch_kibana['ldap_user_search_filter']
# $ldap_user_attribute        = $elasticsearch_kibana['ldap_user_attribute']
# $ldap_authorization_enabled = $elasticsearch_kibana['ldap_authorization_enabled'] or false
# $ldap_group_attribute       = $elasticsearch_kibana['ldap_group_attribute']
# $ldap_admin_group_dn        = $elasticsearch_kibana['ldap_admin_group_dn']
# $ldap_viewer_group_dn       = $elasticsearch_kibana['ldap_viewer_group_dn']

# if empty($elasticsearch_kibana['ldap_server_port']) {
#   if downcase($ldap_protocol) == 'ldap' {
#     $ldap_port = 389
#   } else {
#     $ldap_port = 636
#   }
# } else {
#   $ldap_port = $elasticsearch_kibana['ldap_server_port']
# }

$calculated_content = inline_template('
---
kafka::kafka_jvm_heap_size: <%= @kafka["kafka_jvm_heap_size"] %>
kafka::zookeeper_jvm_heap_size: <%= @kafka["zookeeper_jvm_heap_size"] %>
kafka::num_partitions: <%= @kafka["num_partitions"] %>
kafka::replication_factor: <%= @kafka["replication_factor"] %>
kafka::log_retention_hours: <%= @kafka["log_retention_hours"] %>
kafka::kafka_nodes_count: <%= @kafka_nodes_count %>
')

file { $hiera_file:
  ensure  => file,
  content => $calculated_content,
}
