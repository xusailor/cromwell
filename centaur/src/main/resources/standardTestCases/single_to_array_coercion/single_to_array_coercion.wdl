task singleFile {
  command {
    echo hello
  }
  output {
    File out = stdout()
  }
  runtime { docker: "us.gcr.io/google-containers/ubuntu-slim:0.14" }
}

task listFiles {
  Array[File] manyIn
  command {
    cat ${sep=" " manyIn}
  }
  output {
    String result = read_string(stdout())
  }
  runtime { docker: "us.gcr.io/google-containers/ubuntu-slim:0.14" }
}

workflow oneToMany {
  call singleFile
  call listFiles { input: manyIn = singleFile.out }
}
