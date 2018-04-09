workflow tmp_dir {
    call mkTmpFile
    call writeToTmpDir

  output {
      mkTmpFile.out
      writeToTmpDir.tmpDir
  }
}

task mkTmpFile {
    command {
        echo "tmp_dir test wdl" > tmp
    }
    runtime {
        docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
    }
    output {
        String out = read_string("tmp")
    }
}

task writeToTmpDir {
   command {
        echo "tmp_dir test wdl 2" > $TMPDIR/tmp
        cat $TMPDIR/tmp
   }
   runtime {
        docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
   }
   output {
        String tmpDir = read_string(stdout())
   }
}
