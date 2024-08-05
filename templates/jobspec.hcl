job "${application_name}" {
  type        = "service"
  node_pool = "${node_pool}"

  meta = {
    %{ for key in keys(metadata) ~}
    "${key}" = "${metadata[key]}"
    %{ endfor ~}
  }

  group "${application_name}" {
    count = ${application_count}

    network {
        port "http" {
            to = ${application_port}
        }
    }

    service {
        provider = "${service_provider}"
        port = "http"

        check {
            type = "http"
            path = "/health"
            interval = "10s"
            timeout = "2s"
        }
    }

    task "${application_name}" {
      driver = "${driver}"
      config {
        %{ if driver == "docker" }image = "${image}"%{ endif }

        %{ if command != null }command = "${command}"%{ endif }
        %{ if args != null }args    = ${jsonencode(args)}%{ endif }
        ports = ["http"]
      }

      resources {
        cpu    = ${cpu}
        memory = ${memory}
      }

%{ if has_nomad_vars }
      template {
        data        = <<EOF
{{- range nomadVarListSafe }}
  {{- if nomadVarExists .Path }}
    {{- with nomadVar .Path }}
      {{- range .Tuples }}
{{ .K }}={{ .V | toJSON }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
        EOF
        env         = true
        change_mode = "restart"
        destination = "local/file.env"
      }
%{ endif }
    }
  }
}