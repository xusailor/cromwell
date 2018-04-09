task A {
  command {
    python -c "print(321);exit(123)"
  }
  output {
    Int A_out = read_int(stdout())
  }
  runtime {
    continueOnReturnCode: false
    docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
  }
}

task B {
  Int B_in
  command {
    echo ${B_in}
  }
  runtime {
    docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
  }
}


workflow w {
  call A
  call B {input: B_in = A.A_out}
}
