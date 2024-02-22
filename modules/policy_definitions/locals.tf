locals {
  root_scope_resource_id = "/providers/Microsoft.Management/managementGroups/${var.root_scope_resource_id}"
  management_group_id    = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"

  policy_definitions = flatten(
    [for file in fileset("${path.root}", "archetypes/policy_definitions/*.json") :
      jsondecode(replace(file("${path.root}/${file}"), "$${root_scope_resource_id}", local.root_scope_resource_id))
    ]
  )

  policy_set_definitions = flatten(
    [for file in fileset("${path.root}", "archetypes/policy_set_definitions/*.json") :
      jsondecode(replace(file("${path.root}/${file}"), "$${root_scope_resource_id}", local.root_scope_resource_id))
    ]
  )
}