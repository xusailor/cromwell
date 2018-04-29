task getAverage {
  Int base1 = 9
  Int base2 = 13
    command {
        echo ${(base1*base2)/2}
    }
    output {
        Float average = read_float(stdout())
    }
    runtime {
       docker: "us.gcr.io/google-containers/ubuntu-slim@sha256:1d5c0118358fc7651388805e404fe491a80f489bf0e7c5f8ae4156250d6ec7d8"
    }
}

task heightProduct{
   Float baseAverage
   Int height = 7

   command {
   		echo ${baseAverage*height}
   }
   output {
		Float trapezoidalArea = read_float(stdout())
   }
   runtime {
      docker: "us.gcr.io/google-containers/ubuntu-slim@sha256:1d5c0118358fc7651388805e404fe491a80f489bf0e7c5f8ae4156250d6ec7d8"
   }
}

workflow cacheBetweenWF {
   call getAverage {
   }
   call heightProduct {
      input: baseAverage = getAverage.average
   }
   output {
        heightProduct.trapezoidalArea
   }
}
