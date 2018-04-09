task a {
  command {
    echo "12"
    >&2 echo "200"
  }
  output {
    File out = stdout()
    File err = stderr()
  }
  runtime {docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"}
}

task b {
  File in_file
  command {
    cat ${in_file}
  }
  output {
    Int out = read_int(stdout())
  }
  runtime {docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"}
}

workflow stdout_stderr_passing {
  call a
  call b {input: in_file=a.out}
  call b as b_prime {input: in_file=a.err}
  output {
    b_prime.out
  }
}
