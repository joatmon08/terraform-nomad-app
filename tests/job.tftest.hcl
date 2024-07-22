variables {
  waypoint_application = "fake-service"
  application_port     = 9090
  application_count    = 1
  image                = "nicholasjackson/fake-service:v0.26.2"
  driver               = "docker"
  service_provider     = "nomad"
  node_pool            = "default"
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
