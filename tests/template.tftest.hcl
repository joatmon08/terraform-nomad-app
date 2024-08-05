variables {
  waypoint_application        = "test-app"
  waypoint_additional_details = "test details"
  nomad_additional_details    = "test variable details"
  application_port            = 9090
  application_count           = 1
  image = "test-image"

  metadata = {
    "test" = "123"
  }
  node_pool        = "default"
  service_provider = "nomad"
  applications     = {}
}

run "docker_job_spec" {
  variables {
    driver  = "docker"
    command = "sleep"
    args    = ["30"]
  }

  command = plan

  assert {
    condition     = length(nomad_variable.application) == 0
    error_message = "Should have no nomad variables set"
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

run "docker_job_variables_override" {
  variables {
    driver  = "docker"
    command = "sleep"
    args    = ["30"]
    applications = {
      "test-app" = {
        waypoint_clues = "TODO: waypoint clue"
        nomad_clues    = "TODO: nomad clue"
        node_pool      = "containers"
        port           = 9090
      },
    }
  }

  command = plan

  assert {
    condition     = length(nomad_variable.application.0.items) == 2
    error_message = "Should have 2 nomad variables set"
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
