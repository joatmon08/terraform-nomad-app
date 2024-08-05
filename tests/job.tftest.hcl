variables {
  waypoint_application        = "fake-service"
  waypoint_additional_details = null
  nomad_additional_details    = null
  application_port            = 9090
  application_count           = 1
  image                       = "nicholasjackson/fake-service:v0.26.2"
  driver                      = "docker"
  service_provider            = "nomad"
  node_pool                   = "default"
  applications = {
    "fake-service" = {
      waypoint_clues = "TODO: waypoint clue"
      nomad_clues    = "TODO: nomad clue"
      node_pool      = "containers"
      port           = 9090
    },
  }
}

run "run_job" {}

run "check_job" {
  module {
    source = "./tests/setup"
  }

  assert {
    condition     = data.nomad_job.test.status == "running"
    error_message = "Nomad job should have status `running`"
  }
}
