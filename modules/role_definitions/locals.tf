locals {
  root_scope_resource_id = "/providers/Microsoft.Management/managementGroups/${var.root_scope_resource_id}"

  role_definitions = flatten(
    [for file in fileset("${path.root}", "archetypes/role_definitions/*.json") :
      jsondecode(replace(file("${path.root}/${file}"), "$${root_scope_resource_id}", local.root_scope_resource_id))
    ]
  )
}