task aborted {
    command {
        echo "Instant abort"
    }
    
    runtime {
        docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
    }
}

workflow instant_abort {
    call aborted
}
