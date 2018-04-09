import "refresh_token_sub_workflow_import.wdl" as sub

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

workflow refresh_token_sub_workflow {

  File wfIFile
  call hello
  call sub.wf_hello { input: wfIFile = wfIFile }
  output {
     hello.salutation
     wf_hello.salutation
  }
}
