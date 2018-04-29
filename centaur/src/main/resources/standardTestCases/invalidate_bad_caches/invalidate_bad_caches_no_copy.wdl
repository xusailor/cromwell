task make_file {
    Boolean ready = true
    command {
        echo woohoo > out.txt
    }
    runtime {
        docker: "us.gcr.io/google-containers/ubuntu-slim@sha256:1d5c0118358fc7651388805e404fe491a80f489bf0e7c5f8ae4156250d6ec7d8"
        backend: "Papi-Caching-No-Copy"
    }
    output {
        File out = "out.txt"
    }
}

task read_file {
    File input_file
    command {
      cat ${input_file}
    }
    runtime {
        docker: "us.gcr.io/google-containers/ubuntu-slim:0.14"
        backend: "Papi-Caching-No-Copy"
    }
    output {
        File out = stdout()
    }
}

task delete_file_in_gcs {
    String file_path
    command {
        gsutil rm ${file_path}
    }
    runtime {
        docker: "google/cloud-sdk@sha256:fb904276e8a902ccd9564989d9222bdfbe37ffcd7f9989ca7e24b4019a9b4b6b"
        backend: "Papi-Caching-No-Copy"
    }
    output {
        Boolean done = true
    }
}

workflow invalidate_bad_caches {
    call make_file

    call delete_file_in_gcs { input: file_path = make_file.out }

    call make_file as invalidate_cache_and_remake_file { input: ready = delete_file_in_gcs.done }
    call read_file { input: input_file = invalidate_cache_and_remake_file.out }
}
