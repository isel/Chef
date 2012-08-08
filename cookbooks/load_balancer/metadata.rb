maintainer       "Cloud Infrastructure"
maintainer_email "ugf_ci@ultimatesoftware.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "ubuntu"

recipe "load_balancer::configure_load_balancer_forwarding", "Adds an entry vhost (frontend) that forwards requests to the next target"
recipe "load_balancer::disconnect_from_haproxy", "Disconnects from each load balancer"
recipe "load_balancer::deregister_with_route53", "Deregisters an ip address with a domain in Route53"
recipe "load_balancer::disconnect_instance_from_haproxy", "Disconnects an instance from the haproxy"
recipe "load_balancer::register_appserver_with_haproxy", "Registers an app server with each load balancer"
recipe "load_balancer::register_webserver_with_haproxy", "Registers a web server with each load balancer"
recipe "load_balancer::register_with_route53", "Registers an ip address with a domain in Route53"
recipe "load_balancer::tag_lb_role", "Tags the load balancer role"

attribute "load_balancer/backend_name",
  :display_name => "backend name",
  :description => "A unique name for each back end e.g. (RS_INSTANCE_UUID)",
  :required => "optional",
  :recipes  => [
    "load_balancer::register_appserver_with_haproxy",
    "load_balancer::register_webserver_with_haproxy",
    "load_balancer::disconnect_from_haproxy"
  ]

attribute "load_balancer/domain",
  :display_name => "domain name",
  :description => "The domain name without the prefix (ie, globalincite.com)",
  :required => "optional",
  :recipes  => [
    "load_balancer::configure_load_balancer_forwarding",
    "load_balancer::register_with_route53",
    "load_balancer::deregister_with_haproxy",
    "load_balancer::deregister_with_route53",
    "load_balancer::register_appserver_with_haproxy",
    "load_balancer::register_webserver_with_haproxy"
  ]

attribute "load_balancer/forwarding_ports",
  :display_name => "forwarding ports",
  :description => "The list of ports to be forwarded by the load balancer (i.e. 80,81,82,443)",
  :required => "required",
  :recipes  => [
    "load_balancer::configure_load_balancer_forwarding",
    "load_balancer::disconnect_instance_from_haproxy"
  ]

attribute "load_balancer/instance_backend_name",
  :display_name => "instance backend name",
  :description => "instance backend name to be disconnected from haproxy",
  :required => "required",
  :recipes  => ["load_balancer::disconnect_instance_from_haproxy"]

attribute "load_balancer/prefix",
  :display_name => "prefix",
  :description => "The prefix to a domain (ie, www or api)",
  :required    => "optional",
  :recipes     => [
    "load_balancer::configure_load_balancer_forwarding",
    "load_balancer::register_with_route53",
    "load_balancer::deregister_with_route53",
    "load_balancer::disconnect_from_haproxy",
    "load_balancer::disconnect_instance_from_haproxy",
    "load_balancer::register_appserver_with_haproxy",
    "load_balancer::register_webserver_with_haproxy",
    "load_balancer::tag_lb_role"
  ]

attribute "load_balancer/private_ssh_key",
  :display_name => "private ssh key",
  :description => "The ssh key used to connect to the load balancer",
  :required => "optional",
  :recipes  => ["load_balancer::register_appserver_with_haproxy"]

attribute "load_balancer/route53_ip",
  :display_name => "Route 53 ip",
  :description => "The ip address to register with Route53",
  :required    => "optional",
  :recipes     => [
    "load_balancer::deregister_with_route53",
    "load_balancer::register_with_route53"
  ]

attribute "load_balancer/route53_additional_ip",
  :display_name => "Route 53 additional ip",
  :description => "An additional ip address to register with Route53",
  :required    => "optional",
  :recipes     => [
    "load_balancer::deregister_with_route53",
    "load_balancer::register_with_route53"
  ]

attribute "load_balancer/should_register_with_lb",
  :display_name => "should register with load balancer",
  :description => "This environment uses loadbalancers (true/false)",
  :required => "optional",
  :default => "false",
  :recipes => [
    "load_balancer::register_appserver_with_haproxy",
    "load_balancer::register_webserver_with_haproxy",
    "load_balancer::disconnect_from_haproxy"
  ]

attribute "load_balancer/ssl_certificate",
  :display_name => "ssl certificate",
  :description => "The contents of the SSL Certificate which can be obtained from the 'mycert.crt' file.",
  :required => "required",
  :recipes => ["load_balancer::configure_load_balancer_forwarding"]

attribute "load_balancer/ssl_key",
  :display_name => "ssl key",
  :description => "The contents of the SSL key file (key.pem) that's required for secure (https) connections.",
  :required => "required",
  :recipes => ["load_balancer::configure_load_balancer_forwarding"]


### attributes used from other cookbooks
attribute "deploy/app_server",
  :display_name => "app server",
  :required => "required",
  :recipes  => ["load_balancer::register_appserver_with_haproxy"]

attribute "deploy/deployment_name",
  :display_name => "deployment name",
  :required => "required",
  :recipes  => [
     "load_balancer::register_appserver_with_haproxy",
     "load_balancer::register_webserver_with_haproxy",
     "load_balancer::deregister_with_haproxy"
  ]

