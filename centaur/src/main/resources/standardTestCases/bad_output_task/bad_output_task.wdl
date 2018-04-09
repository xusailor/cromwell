task bad {
  command {
    echo "hello" > a
  }

  runtime {
    docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
  }

  output {
    # Oops! we made a spelling mistake in our WDL!
    File a = "b"
  }
}

workflow badExample {
  call bad
}
