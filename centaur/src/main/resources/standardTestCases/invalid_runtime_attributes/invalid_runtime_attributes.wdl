task invalid_runtime_attributes {
    command { # NOOP }
    runtime {
        docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
        continueOnReturnCode: "oops"
    }
}

workflow invalid_runtime_attributes_wf {
    call invalid_runtime_attributes
}
