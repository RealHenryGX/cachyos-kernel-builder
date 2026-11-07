# CachyOS Kernel Builder

This repository builds the default CachyOS kernel package from the upstream packaging repository with one isolated IMA configuration patch.

- Upstream: `CachyOS/linux-cachyos`, `master`
- Builder: GitHub-hosted Actions only
- Validation: checks the upstream ref, patch applicability, and final kernel configuration
- Build: manual workflow that uploads packages, configuration, and a build manifest
- Signing: no Secure Boot keys are stored or used in Actions

The pipeline starts with validation. Run the build workflow only after validation passes.
