variable "db_name" {
    type = string
    description = "Name of the MySQL database for WordPress. MySQL creates it on the first start."
}

variable "db_user"{
    type = string
    description = "User name"
    default = "Normal (not root) MySQL user for WordPress. Do not use 'root' here."
}

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

variable "wordpress_port"{
    type = number
    description = 	"Port on your computer for opening WordPress (http://localhost:PORT)."
    default = 8080
}