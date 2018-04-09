class: CommandLineTool
cwlVersion: v1.0
hints:
  DockerRequirement:
    dockerPull: "us.gcr.io/google-containers/ubuntu-slim:0.14"
requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - "function foo() { return 2; }"
inputs: []
outputs:
  out: stdout
arguments: [echo, $(foo())]
stdout: whatever.txt
