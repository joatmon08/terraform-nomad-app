locals {
  nomad_vars = var.environment_variables

  environment_variables = contains(keys(var.applications), var.waypoint_application) ? merge({
    NAME    = var.waypoint_application
    MESSAGE = var.applications[var.waypoint_application].nomad_clues
  }, local.nomad_vars) : local.nomad_vars

  metadata = var.waypoint_additional_details != null ? merge({
    "waypoint.provisioned"        = "true"
    "waypoint.additional_details" = "${var.waypoint_additional_details}"
  }, var.metadata) : var.metadata
}

data "nomad_job_parser" "application" {
  hcl = templatefile("${path.module}/templates/jobspec.hcl", {
    application_name  = var.waypoint_application
    application_port  = var.application_port
    application_count = var.application_count
    node_pool         = var.node_pool
    driver            = var.driver
    command           = var.command
    args              = var.args
    cpu               = var.cpu
    memory            = var.memory
    image             = var.image
    service_provider  = var.service_provider
    metadata          = local.metadata
  })
  canonicalize = false
}
resource "nomad_variable" "application" {
  count = length(local.environment_variables) > 0
  path  = "nomad/jobs/${nomad_job.application.id}"
  items = local.environment_variables
}

resource "nomad_job" "application" {
  jobspec = data.nomad_job_parser.application.json
  json    = true
}