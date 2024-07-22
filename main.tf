locals {
  environment_variables = strcontains(var.image, "fake-service") ? merge({
    NAME    = var.waypoint_application
    MESSAGE = "Hello from ${var.waypoint_application}"
  }, var.environment_variables) : var.environment_variables
  metadata = var.waypoint_template != null ? merge({
    "waypoint.provisioned" = "true"
    "waypoint.template"    = var.waypoint_template
  }, var.metadata) : var.metadata
}

data "nomad_job_parser" "application" {
  hcl = templatefile("${path.module}/templates/jobspec.hcl", {
    application_name      = var.waypoint_application
    application_port      = var.application_port
    application_count     = var.application_count
    node_pool             = var.node_pool
    driver                = var.driver
    command               = var.command
    args                  = var.args
    environment_variables = local.environment_variables
    cpu                   = var.cpu
    memory                = var.memory
    image                 = var.image
    service_provider      = var.service_provider
    metadata              = local.metadata
  })
  canonicalize = false
}

resource "nomad_job" "application" {
  jobspec = data.nomad_job_parser.application.json
  json    = true
}