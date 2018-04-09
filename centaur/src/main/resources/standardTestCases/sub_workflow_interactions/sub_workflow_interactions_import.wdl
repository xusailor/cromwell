task countTo {
    Int value
    command {
        seq 0 1 ${value}
    }
    runtime {
          docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
      }
    output {
        File range = stdout()
    }
}

task filterEvens {
    File numbers
    command {
        grep '[02468]$' ${numbers} > evens
    }
    runtime {
          docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
      }
    output {
        File evens = "evens"
    }
}

workflow countEvens {
    Int max = 10
    
    call countTo { input: value = max }
    call filterEvens { input: numbers = countTo.range }
    output {
        String someStringOutput = "I'm an output"
        File evenFile = filterEvens.evens
    }
}
