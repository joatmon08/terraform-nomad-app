locals {
  environment_variables = {
    NAME    = var.waypoint_application
    MESSAGE = "Hello from ${var.waypoint_application}!"
  }

  metadata = merge({
    "waypoint.provisioned"        = "true"
  }, var.metadata)
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
    has_nomad_vars    = length(nomad_variable.application) > 0
  })
  canonicalize = false
}

resource "nomad_variable" "application" {
  count = length(local.environment_variables) != 0 ? 1 : 0
  path  = "nomad/jobs/${var.waypoint_application}"
  items = local.environment_variables
}

resource "nomad_job" "application" {
  jobspec = data.nomad_job_parser.application.json
  json    = true
}