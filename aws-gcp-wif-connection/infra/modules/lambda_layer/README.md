# AWS Lambda Layer Terraform Module

Universal AWS Lambda Layer module for Python dependencies and shared modules.

## Features

- Automatic pip installation from requirements.txt
- Optional shared Python modules support
- Automatic rebuild on dependency changes
- Configurable Python runtime version
- Compatible runtimes derived from Python version
- Private layer (no external permissions)

## Usage

### With dependencies only

```hcl
module "my_layer" {
  source = "./modules/lambda-layer"

  layer_name        = "my-dependencies-layer"
  description       = "Common Python dependencies"
  python_version    = "3.11"
  requirements_file = "${path.module}/../lambda/requirements.txt"
}
```

### With dependencies and shared modules

```hcl
module "my_layer" {
  source = "./modules/lambda-layer"

  layer_name          = "my-complete-layer"
  description         = "Dependencies and shared utilities"
  python_version      = "3.11"
  requirements_file   = "${path.module}/../lambda/requirements.txt"
  shared_modules_path = "${path.module}/../lambda/shared"
  license_info        = "MIT"
}
```

## Directory Structure

The module expects the following structure:

```
lambda/
├── requirements.txt          # Python dependencies
└── shared/                   # Optional shared modules
    ├── __init__.py
    ├── utils.py
    └── helpers.py
```

The layer will be built with the proper Lambda layer structure:

```
layer.zip
└── python/
    ├── <installed dependencies>
    └── <shared modules>
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| layer_name | Name of the Lambda layer | string | - | yes |
| requirements_file | Path to requirements.txt | string | - | yes |
| python_version | Python version (e.g., 3.11) | string | 3.11 | no |
| shared_modules_path | Path to shared modules directory | string | null | no |
| description | Layer description | string | "" | no |
| license_info | License information | string | "" | no |

## Outputs

| Name | Description |
|------|-------------|
| layer_arn | ARN of the Lambda layer version |
| layer_version | Version number of the layer |
| layer_name | Name of the Lambda layer |
| compatible_runtimes | Compatible runtimes list |

## Notes

- The module automatically rebuilds the layer when requirements.txt or shared modules change
- Build artifacts are stored in `modules/lambda-layer/build/`
- Requires `pip` to be available in the environment where Terraform runs
- The layer remains private and is not shared with other AWS accounts
