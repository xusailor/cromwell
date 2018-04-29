task print {
  command {
    echo "She sells sea shells by the sea shore only on $(date)"
  }
  output {
    File tongueTwister = stdout()
  }
  runtime {docker: "us.gcr.io/google-containers/ubuntu-slim@sha256:1d5c0118358fc7651388805e404fe491a80f489bf0e7c5f8ae4156250d6ec7d8"}
}

task grep {
  String match = "o"
  File input_file
  command {
    grep '${match}' ${input_file} | wc -l
  }
  output {
    Int count = read_int(stdout())
    File redirect = input_file
  }
  runtime {docker: "us.gcr.io/google-containers/ubuntu-slim@sha256:1d5c0118358fc7651388805e404fe491a80f489bf0e7c5f8ae4156250d6ec7d8"}
}

task grepAgain {
  String match = "o"
  File input_file
  command {
    grep '${match}' ${input_file} | wc -l
  }
  output {
    Int count = read_int(stdout())
    File redirect = input_file
  }
  runtime {docker: "us.gcr.io/google-containers/ubuntu-slim@sha256:1d5c0118358fc7651388805e404fe491a80f489bf0e7c5f8ae4156250d6ec7d8"}
}

workflow writeToCache {
  call print
  call grep { input: input_file = print.tongueTwister }
  call grepAgain { input: input_file = grep.redirect }
  output {
    grep.count
    grepAgain.count
  }
}
