task hello {
  command {
    echo "Hello!"
  }
  output {
    String empty = ""
  }
  runtime {
    docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
  }
}

task goodbye {
  String emptyInputString
  command {
    echo "${emptyInputString}"
  }
  output {
    String empty = read_string(stdout())
  }
  runtime {
   docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
  }
}

workflow wf_hello {
  call hello
  call goodbye {input: emptyInputString=hello.empty }
  output {
   hello.empty
   goodbye.empty
  }
}
