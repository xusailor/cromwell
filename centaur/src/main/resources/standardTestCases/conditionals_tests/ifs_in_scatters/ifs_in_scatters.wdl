task validate_int {
  Int i
  command {
    echo $(( ${i} % 2 ))
  }
  output {
    Boolean validation = read_int(stdout()) == 1
  }
  runtime {
    docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
  }
}

task mirror {
  Int i
  command {
    echo ${i}
  }
  output {
    Int out = read_int(stdout())
  }
  runtime {
    docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
  }
}

workflow ifs_in_scatters {
  Array[Int] numbers = range(5)
  call mirror as init { input: i = 1 }
  Int mirrorPlusOne = 1 + init.out

  scatter (n in numbers) {

    call validate_int { input: i = n }
    if (validate_int.validation) {
      Int incremented = n + 1
      if (incremented != 0) {
        call mirror { input: i = incremented + init.out + mirrorPlusOne }
      }
    }
  }

  output {
    Array[Int?] mirrors = mirror.out
  }
}
