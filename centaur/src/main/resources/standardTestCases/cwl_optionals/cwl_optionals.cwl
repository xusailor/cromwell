cwlVersion: v1.0
class: CommandLineTool
hints:
  DockerRequirement:
    dockerPull: "us.gcr.io/google-containers/ubuntu-slim:0.14"
baseCommand: echo
inputs:
  message:
    type: string[]?
  unsupplied_optional:
    type: string[]?
outputs: []
