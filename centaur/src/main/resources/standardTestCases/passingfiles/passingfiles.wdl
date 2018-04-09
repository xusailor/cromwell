##
# Check that we can:
# - Create a file from a task and feed it into subsequent commands.
# - Create a file output by interpolating a file name
# - Use engine functions on an interpolated file name
##

task mkFile {
  command { 
    echo "small file contents" > out.txt
  }
  output { File out = "out.txt" }
  runtime { docker: "us.gcr.io/google-containers/ubuntu-slim:0.14" }
}

task consumeFile {
  File in_file
  String out_name

  command {
    cat ${in_file} > ${out_name}
  }
  runtime {
    docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
  }
  output {
    File out_interpolation = "${out_name}"
    String contents = read_string("${out_name}")
    String contentsAlt = read_string(out_interpolation)
  }
}

workflow filepassing {
  call mkFile
  call consumeFile {input: in_file=mkFile.out, out_name = "myFileName.abc.txt" }
  output {
      consumeFile.contents
      consumeFile.contentsAlt
  }
}
