set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# List available commands
list: 
  just --list --unsorted

[private]
default: list
