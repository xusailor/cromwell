task noop {
  command {}
  runtime {
    docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
  }
}

workflow workflow_type_and_version_default {
  call noop
}
