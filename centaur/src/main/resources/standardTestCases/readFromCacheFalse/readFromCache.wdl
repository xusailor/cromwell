task echo {
  command {
    echo "Peter Piper picked a peck of pickled peppers"
  }
  output {
    File out = stdout()
  }
  runtime {docker: "us.gcr.io/google-containers/ubuntu-slim:0.14@sha256:1d5c0118358fc7651388805e404fe491a80f489bf0e7c5f8ae4156250d6ec7d8"}
}

task find {
  String match = "r"
  File in_file
  command {
    grep '${match}' ${in_file} | wc -l
  }
  output {
    Int count = read_int(stdout())
  }
  runtime {docker: "us.gcr.io/google-containers/ubuntu-slim:0.14@sha256:1d5c0118358fc7651388805e404fe491a80f489bf0e7c5f8ae4156250d6ec7d8"}
}

workflow readFromCache {
  call echo
  call find { input: in_file = echo.out }
  call echo as echoAgain
  call find as findAgain { input: in_file = echo.out }
  output {
    find.count
    findAgain.count
  }
}
