variable "waypoint_application" {
  type        = string
  description = "Name of application"
}

resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"
}

data "nomad_job" "test" {
  job_id    = var.waypoint_application
  depends_on = [ time_sleep.wait_30_seconds ]
}