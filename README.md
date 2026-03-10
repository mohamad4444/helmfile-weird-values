# DevOps Helmfile Weird Values

This repository demonstrates a clean, intuitive pattern for handling and deep-merging values across multiple environments in `helmfile`.

## What it Solves
Helmfile normally passes environment-specific values as global variables in `.Values`. To use them inside a release block, you generally have to write cumbersome Go templates per release or hardcode the overrides. This repository eliminates that redundancy.

It solves the problem by replicating the merging behavior of umbrella Helm charts. It uses a single template (`env-magic.gotmpl`) to implement a robust 4-tier value hierarchy.

### How `env-magic.gotmpl` Logic Works
The template performs a top-down merge with the following overwrite precedence (from lowest to highest):

1. **`globalDefaults`**: Used as the base configuration for all releases.
2. **`releaseValues`**: Specific settings targeted for the current release (matches `.Release.Name`). These overwrite the `globalDefaults`.
3. **`globalOverrides`**: Strict overrides that take top priority and overwrite all the previous values.
4. **`globalConfig`**: Added cleanly under its own isolated namespace (it does not overwrite the top-level keys).

**The magic mechanism behind this:**
Helmfile merges the environment values file (e.g. `dev.yaml`) and exposes it. `env-magic.gotmpl` intercepts this map, strips out only what is relevant based on the precedence above, sets the keys into an empty dictionary `dict` via Go's `set`, and ultimately exposes the final computed tree `toYaml`. This keeps your `helmfile.yaml` incredibly DRY and clean.

### How Helm & Helmfile Read Values
When you execute Helmfile, the order of how values are processed and merged is critical to understand. The precedence flows from lowest priority to highest priority:

1. **Chart Defaults (Lowest Priority):** Helm initially loads the target chart's default `values.yaml` file.
2. **Helmfile Outputs (`env-magic.gotmpl`):** Helmfile evaluates the Go templates listed in the `releases[].values` array within your `helmfile.yaml`. It takes the output of `env-magic.gotmpl` (which already merged the 4 tiers of environment values), writes it to a temporary YAML file, and passes it to Helm using the `--values` flag.
3. **Helm Merges:** Helm takes this temporary YAML file and merges it *over* the chart's native defaults. 
4. **Command Line Flags (Highest Priority):** If you pass any inline `--set` flags to Helm, those override everything else.

In short: **Chart native `values.yaml` < Helmfile Environment Values < Command Line `--set` flags.**

## Requirements
To use and test this project, you need the following tools installed on your system:
- **[Helm](https://helm.sh/docs/intro/install/)** (v3.x or newer)
- **[Helmfile](https://github.com/helmfile/helmfile)** 
- **[helm-diff](https://github.com/databus23/helm-diff)** plugin (Recommended/Required by Helmfile for `apply` and `diff` operations)

## How to Use It (Local Testing)

If you don't have Helm and Helmfile installed, you can simply download the binaries into the project directory and test the logic yourself.

1. **Download Helm and Helmfile binaries:**
   ```bash
   cd example/environments
   # Download Helmfile
   curl -sL https://github.com/helmfile/helmfile/releases/download/v0.169.1/helmfile_0.169.1_linux_amd64.tar.gz -o helmfile.tar.gz && tar -xzf helmfile.tar.gz && chmod +x helmfile
   
   # Download Helm v3
   curl -sL https://get.helm.sh/helm-v3.16.1-linux-amd64.tar.gz -o helm.tar.gz && tar -xzf helm.tar.gz && mv linux-amd64/helm ./helm
   ```

2. **Customize Values:**
   Review and tweak the environment values in `values/env/dev.yaml` to observe the template magic.

3. **Run Helmfile Commands:**
   To make sure Helmfile uses the locally downloaded `helm` binary, prefix the execution with `PATH=$PWD:$PATH`.

   - **View the rendered YAML values deeply merged output for the dev environment:**
     ```bash
     PATH=$PWD:$PATH ./helmfile -e dev write-values
     ```
     *(This outputs the rendered files into a temporary `helmfile-XXXXX/` directory. Check the file to see the final merged YAML)*

   - **View the rendered YAML specifically for the 'test' release:**
     ```bash
     PATH=$PWD:$PATH ./helmfile -e dev -l name=test write-values
     ```

   - **Template the Kubernetes manifests to see the final overall generated output:**
     ```bash
     PATH=$PWD:$PATH ./helmfile -e dev template --args="--debug"
     ```

## Credits
Based on the pattern detailed in [derlin/helmfile-intuitive-values-handling](https://github.com/derlin/helmfile-intuitive-values-handling).