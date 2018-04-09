task prefix {
  command {
    echo hello \
    | wc -l
  }
  output {
    String out = read_string(stdout())
  }
  runtime {
    docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
  }
}

workflow wf_prefix {
  call prefix
  output {
     String prefix_out = prefix.out
  }
}
