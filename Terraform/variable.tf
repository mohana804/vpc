
## VPC CIDR Block ##

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "VPC_cidr block"
  type        = string
}

## Web Tier CIDR Block 1 ##

variable "public-webtier-subnet-1-cidr" {
  default     = "10.0.1.0/24"
  description = "public_web_subnet1"
  type        = string
}

## Web Tier CIDR Block 2##

variable "public-webtier-subnet-2-cidr" {
  default     = "10.0.2.0/24"
  description = "public_web_subnet2"
  type        = string
}

## App tier CIDR Block 1##

variable "private-apptier-subnet-1-cidr" {
  default     = "10.0.3.0/24"
  description = "private_app_subnet1"
  type        = string
}

## App tier CIDR Block 2 ##

variable "private-apptier-subnet-2-cidr" {
  default     = "10.0.4.0/24"
  description = "private_app_subnet2"
  type        = string
}

## DB CIDR Block 1 ##

variable "private-database-subnet-1-cidr" {
  default     = "10.0.5.0/24"
  description = "private_db_subnet1"
  type        = string
}

## DB CIDR Block 2 ##

variable "private-database-subnet-2-cidr" {
  default     = "10.0.6.0/24"
  description = "private_db_subnet2"
  type        = string
}


## DB Instance    ##

variable "database-instance-class" {
  default     = "db.t3.micro"
  description = "The Database Instance type"
  type        = string
}

##  multi_AZ   ##

variable "multi-az-deployment" {
  default     = false
  description = "Create a Standby DB Instance"
  type        = bool
}

## DB Username ##

variable "username" {
  default = "user01"
  type = string
}

## DB Password ##

variable "password" {
  default = "password01"
  type = string
}