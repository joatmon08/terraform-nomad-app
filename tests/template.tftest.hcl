variables {
  waypoint_application        = "test-app"
  waypoint_additional_details = "test details"
  nomad_additional_details    = "test variable details"
  application_port            = 9090
  application_count           = 1
  environment_variables = {
    "LISTEN_ADDR"   = "0.0.0.0:19090"
    "UPSTREAM_URIS" = "10.0.0.2:8080"
  }
  image = "test-image"

  metadata = {
    "test" = "123"
  }
  node_pool        = "default"
  service_provider = "nomad"
}

run "docker_job_spec" {
  variables {
    driver  = "docker"
    command = "sleep"
    args    = ["30"]
  }

  command = plan

  assert {
    condition     = length(nomad_variable.application.items) == 3
    error_message = "S"
  }

  assert {
    condition     = jsondecode(nomad_job.application.jobspec).Name == "test-app"
    error_message = "Job spec name did not match `test-app`"
  }

  assert {
    condition     = length(jsondecode(nomad_job.application.jobspec).TaskGroups.0.Tasks.0.Templates) == 1
    error_message = "Task should have 1 template for environment variables"
  }

  assert {
    condition     = jsondecode(nomad_job.application.jobspec).TaskGroups.0.Tasks.0.Env == null
    error_message = "Job spec environment variables should be null"
  }

  assert {
    condition     = length(jsondecode(nomad_job.application.jobspec).Meta) == 3
    error_message = "Job spec metadata should have 3"
  }

  assert {
    condition     = jsondecode(nomad_job.application.jobspec).TaskGroups.0.Tasks.0.Config.image == "test-image"
    error_message = "Job spec image should be fake-service"
  }

  assert {
    condition     = jsondecode(nomad_job.application.jobspec).TaskGroups.0.Tasks.0.Config.command == "sleep"
    error_message = "Job spec command should be sleep"
  }

  assert {
    condition     = jsondecode(nomad_job.application.jobspec).TaskGroups.0.Tasks.0.Config.args == ["30"]
    error_message = "Job spec args should be `[\"30\"]`"
  }
}

run "exec_job_spec" {
  variables {
    driver = "exec"
  }

  command = plan

  assert {
    condition     = jsondecode(nomad_job.application.jobspec).Name == "test-app"
    error_message = "Job spec name did not match `test-app`"
  }

  assert {
    condition     = jsondecode(nomad_job.application.jobspec).TaskGroups.0.Tasks.0.Env == null
    error_message = "Job spec environment variables should be null"
  }

  assert {
    condition     = !contains(keys(jsondecode(nomad_job.application.jobspec).TaskGroups.0.Tasks.0.Config), ["image"])
    error_message = "Job spec image should be null"
  }

  assert {
    condition     = !contains(keys(jsondecode(nomad_job.application.jobspec).TaskGroups.0.Tasks.0.Config), ["command"])
    error_message = "Job spec command should be null"
  }

  assert {
    condition     = !contains(keys(jsondecode(nomad_job.application.jobspec).TaskGroups.0.Tasks.0.Config), ["args"])
    error_message = "Job spec args should be null"
  }
}
