task failOnStderr {
    command <<<
        echo "OH NO!" >&2
    >>>
    output {
        String ohno = read_string(stderr())
    }
    runtime {
        docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
        failOnStderr: true
    }
}

workflow runtime_failOnStderr {
    call failOnStderr
}
