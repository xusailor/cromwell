task hey {
  String what
  command {
    echo "Hey ${what}!"
  }
  output {
    String lyrics = read_string(stdout())
  }
  runtime {
    docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
  }
}

workflow refresh_token_failure {
  call hey
  output {
     hey.lyrics
  }
}
