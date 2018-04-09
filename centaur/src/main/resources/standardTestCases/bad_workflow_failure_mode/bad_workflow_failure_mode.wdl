task hello {
  String addressee
  command {
    echo "Hello ${addressee}!"
  }
  output {
    String salutation = read_string(stdout())
  }
  runtime {
    docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
    cpu: 1
  }
}

workflow wf_hello {
  call hello
}
