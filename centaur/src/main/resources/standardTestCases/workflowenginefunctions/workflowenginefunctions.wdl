task printArray {
  Array[Int] array

  command {
    echo "${sep='"; echo "' array}"
  }
  output {
    String o = read_string(stdout())
  }
  runtime {
    docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
  }
}

workflow workflowEngineFunctions {
  Array[Int] some_ints = range(10)
  call printArray {input: array=some_ints}
}
