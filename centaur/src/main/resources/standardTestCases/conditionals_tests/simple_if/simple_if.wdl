task runMe {
  command {
    echo "done"
  }
  output {
    String s = read_string(stdout())
  }
  runtime {
    docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
  }
}

workflow simple_if {
  if (true) {
    call runMe as runMeTrue
  }

  if (false) {
    call runMe as runMeFalse
  }

  output {
    runMeTrue.s
    runMeFalse.s
  }
}
