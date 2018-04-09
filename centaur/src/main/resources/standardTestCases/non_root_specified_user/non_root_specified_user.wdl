task nobody {
  command {
    whoami
  }

  runtime {
    docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
    docker_user: "nobody"
  }

  output {
    String user = read_string(stdout())
  }
}

workflow woot {
  call nobody

  output {
    String nobodyUser = nobody.user
  }
}
