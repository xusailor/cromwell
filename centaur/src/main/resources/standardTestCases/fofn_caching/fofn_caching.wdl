task make_file {
    Int content
    command {
        echo "hello ${content}" > out
    }
    runtime {
        docker: "us.gcr.io/google-containers/ubuntu-slim@sha256:1d5c0118358fc7651388805e404fe491a80f489bf0e7c5f8ae4156250d6ec7d8"
        backend: "Papi-Caching-No-Copy"
    }
    output {
        File out = "out"
    }
}

task use_fofn {
    File fofn
    command {
        cat ${fofn}
    }
    runtime {
        docker: "us.gcr.io/google-containers/ubuntu-slim@sha256:1d5c0118358fc7651388805e404fe491a80f489bf0e7c5f8ae4156250d6ec7d8"
        backend: "Papi-Caching-No-Copy"
    }
    output {
        Array[String] out = read_lines(stdout())
    }
}


workflow fofn_caching {
    scatter(i in range(5)) {
        call make_file { input: content = i }
    }
    
    call use_fofn { input: fofn = write_lines(make_file.out) }
    
    output {
        Array[String] files = use_fofn.out
    }
}
