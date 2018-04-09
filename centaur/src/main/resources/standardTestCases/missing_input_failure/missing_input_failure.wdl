task hello {
  String addressee
  command {
    echo "Hello ${addressee}!"
  }
  runtime {
      docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
    }
  output {
    String salutation = read_string(stdout())
  }
}

workflow missing_input_failure {
  File wf_hello_input
  
  call hello {input: addressee = read_string(wf_hello_input) }
  
  output {
    String salutation = hello.salutation
  }
}
