task one {
  Int radius
    command {
        echo ${radius*radius}
    }
    output {
        Int rSquared = read_int(stdout())
		Int rCopy = radius
    }
    runtime {
       docker: "us.gcr.io/google-containers/ubuntu-slim@sha256:1d5c0118358fc7651388805e404fe491a80f489bf0e7c5f8ae4156250d6ec7d8"
    }
}

task two{
   Int r2
   Float pi = 3.14159

   command {
   		echo ${r2*pi}
   }
   output {
		Float area = read_float(stdout())
		Float piCopy = pi
		Int rSquaredCopy = r2
   }
   runtime {
      docker: "us.gcr.io/google-containers/ubuntu-slim@sha256:1d5c0118358fc7651388805e404fe491a80f489bf0e7c5f8ae4156250d6ec7d8"
   }
}

workflow cacheWithinWF {
   call one {
    input: radius = 62
   }
   call two {
   	input: r2 = one.rSquared
   }
   call two as twoAgain {
   	input: r2 = two.rSquaredCopy
   }
   output {
      two.area
      twoAgain.area
   }
}
