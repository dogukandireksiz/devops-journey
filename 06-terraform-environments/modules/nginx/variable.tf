variable "environment"{
    type = string
    description = "Environment name (dev,prod). Used in the namespace name: nginx-<environment>"
    validation {
        condition= contains(["dev","prod"],var.environment)
        error_message= "Environment must be dev or prod."
    }
}

variable "replicas"{
    type = number
    description = "Number of nginx pods to run."
}

variable "node_port"{
    type = number
    description = "NodePort to open nginx from outside. Must be between 30000 and 32767, and different for each environment."
    validation {
        condition = var.node_port >= 30000 && var.node_port <= 32767 
        error_message = "NodePort must be between 30000 and 32767, You gave ${var.node_port}."
    }

}

