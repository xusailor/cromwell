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

workflow wf_hello {
  String wfIFile
  
  call hello {input: iFile = wfIFile }
  
  output {
    String salutation = hello.salutation
  }
}
