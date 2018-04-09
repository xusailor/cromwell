task hello {
  File iFile
  String addressee = read_string(iFile)
  command {
    echo "Hello ${addressee}!"
  }
  output {
    String salutation = read_string(stdout())
  }
  runtime {
    docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
  }
}

workflow refresh_token {
  call hello
  output {
     hello.salutation
  }
}
