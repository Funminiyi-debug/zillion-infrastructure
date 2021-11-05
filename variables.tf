variable "provider_login" {
    type = object({ 
        subscription_id = string
        tenant_id = string
        client_id = string
        client_secret = string

    })
    description = "Login details for terraform"
    
}

variable "sql_server_login" { 
    type = object({
        username = string
        password = string
    })
}

variable "name" { 
    default = "dev"
    type = string
    description = "name of all resources"
}

variable "environment" { 
    type = string
    description = "work environment"
}

