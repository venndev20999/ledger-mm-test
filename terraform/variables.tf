variable "namespace" {
  type        = string
  description = "Kubernetes namespace to deploy resources into"
  default     = "ledger-api"
}

variable "app_name" {
  type        = string
  description = "Name of the application"
  default     = "ledger-api"
}

variable "app_replicas" {
  type        = number
  description = "Number of replicas for the app deployment"
  default     = 3
}

variable "image_tag" {
  type        = string
  description = "Docker image tag for the ledger-api app"
  default     = "dev1"
}

variable "postgres_host" {
  type        = string
  description = "Host IP of external PostgreSQL database"
  default     = "192.168.122.245"
}

variable "postgres_port" {
  type        = number
  description = "Port of external PostgreSQL database"
  default     = 5432
}

variable "postgres_db" {
  type        = string
  description = "Database name of PostgreSQL"
  default     = "mamo_db"
}

variable "postgres_user" {
  type        = string
  description = "User of PostgreSQL"
  default     = "ledger_rw"
}

variable "postgres_password" {
  type = string
  # SOPS Reference: For local execution, decrypt secrets into .terraform.tfvars using SOPS.
  # Command: sops -d secrets.enc.tfvars > .terraform.tfvars
  description = "Password of PostgreSQL"
  default     = "ledger_password123"
  sensitive   = true
}

variable "redis_host" {
  type        = string
  description = "Host IP of external Redis instance"
  default     = "192.168.122.203"
}

variable "redis_port" {
  type        = number
  description = "Port of external Redis instance"
  default     = 6379
}

variable "redis_password" {
  type = string
  # SOPS Reference: For local execution, decrypt secrets into .terraform.tfvars using SOPS.
  # Command: sops -d secrets.enc.tfvars > .terraform.tfvars
  description = "Password of external Redis instance"
  default     = "redis123"
  sensitive   = true
}

variable "image_repository" {
  type        = string
  description = "Docker image repository name"
  default     = "venndev209999/ledger-api"
}
