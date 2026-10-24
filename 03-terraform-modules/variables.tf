variable "db_password"{
    type = string
    description = "Password for db_user. WordPress uses it to connect to MySQL. Changing it later does not update an existing database."
    sensitive = true
}

variable "db_root_password"{
    type = string
    description = "Password for the MySQL root (admin) user. Required: MySQL does not start without it."
    sensitive = true
}