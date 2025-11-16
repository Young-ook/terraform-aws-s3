### security
variable "bucket_policy" {
  description = "Bucket-side access control setting"
  type        = map(any)
  default     = {}
}

variable "server_side_encryption" {
  description = "A configuration of server side encryption"
  type        = map(string)
  default     = { sse_algorithm = "AES256" }
}

### features
variable "intelligent_tiering_archive_rules" {
  description = "A configuration of intelligent tiering archive management"
  type        = any
  default     = null
  validation {
    condition     = var.intelligent_tiering_archive_rules == null ? true : length(var.intelligent_tiering_archive_rules) > 0
    error_message = "The intelligent_tiering_archive_rules must not be empty. Required at least one archive tier."
  }
}

variable "lifecycle_rules" {
  description = "A configuration of object lifecycle management"
  type        = any
  default     = null
  validation {
    condition     = var.lifecycle_rules == null ? true : length(var.lifecycle_rules) > 0
    error_message = "The lifecycle_rules rules must not be empty. Required at least one lifecycle rule."
  }
}

variable "logging_rules" {
  description = "A configuration of bucket logging management"
  type        = map(string)
  default     = null
  validation {
    condition     = var.logging_rules == null ? true : length(var.logging_rules) > 0
    error_message = "Logging rules must not be empty."
  }
}

variable "versioning" {
  description = "A configuration to enable object version control"
  type        = string
  default     = null
  validation {
    condition     = var.versioning == null ? true : contains(["Enabled", "Suspended"], var.versioning)
    error_message = "Allowed values: `Enabled`, `Suspended`."
  }
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error"
  type        = bool
  default     = false
}

variable "zone_id" {
  description = "Zone ID for S3 express one zone"
  type        = string
  default     = null
  validation {
    condition     = var.zone_id == null ? true : length(var.zone_id) > 0
    error_message = "The zone-id must not be empty. Required at least one character."
  }
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
  default     = null
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
