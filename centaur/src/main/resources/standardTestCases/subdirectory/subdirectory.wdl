task subdirTask {
  command {
    mkdir subdir
    cd subdir
    echo "I'm in a subdirectory !" > subFile
  }
  runtime {
    docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
  }
  output {
    File outputFile = "subdir/subFile"
  }
}

workflow subdirWorkflow {
  call subdirTask
}
