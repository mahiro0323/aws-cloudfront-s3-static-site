variable "aws_region" {
  description = "S3バケットを作成するリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "環境ごとに変更する名前（小文字英数字とハイフン、3〜30文字）"
  type        = string
  default     = "mahiro-tf-static-site"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,28}[a-z0-9]$", var.project_name))
    error_message = "名前は3〜30文字の小文字英数字とハイフンで、先頭と末尾は英数字にしてください。"
  }
}
