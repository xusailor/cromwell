task invalid_return_code {
    command <<<
        echo successful
    >>>
    output {
        String successful = read_string(stdout())
    }
    runtime {
        docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
        continueOnReturnCode: 1
    }
}

workflow invalid_return_code_wf {
    call invalid_return_code
}
