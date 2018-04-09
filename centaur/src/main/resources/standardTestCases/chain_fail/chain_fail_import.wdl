task hello {
  Boolean addressee
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

workflow wf_hello {
  Boolean wf_hello_input = true
  
  call hello { input: addressee = wf_hello_input }
  
  output {
    String salutation = hello.salutation
  }
}
