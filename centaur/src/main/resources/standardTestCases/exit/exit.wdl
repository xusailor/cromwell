task exitTask {
  command {
    exit 5
  }
  runtime {
    docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
    continueOnReturnCode: 5
  }
}

workflow exitWorkflow {
  call exitTask
}
