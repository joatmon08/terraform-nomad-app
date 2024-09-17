output "job_id" {
  value = nomad_job.application.id
}

output "clue" {
  value = var.waypoint_additional_details
}