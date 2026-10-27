run "dev_values"{
    
    command = plan

    variables {
        environment = "dev"
        replicas = 1
        node_port = 30001
    }

    assert {
        condition = "nginx-dev" == kubernetes_namespace_v1.nginx.metadata[0].name
        error_message = "Namespace name should be nginx-dev."
    }

    assert {
        condition= kubernetes_service_v1.nginx.spec[0].port[0].node_port == 30001
        error_message = "Service NodePort should be 30001"
    }
}



run "invalid_node_port"{
  
  command = plan

  variables {
    environment = "dev"
    replicas = 1
    node_port = 8080
  }

  expect_failures = [var.node_port]
}