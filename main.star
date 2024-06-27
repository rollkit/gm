def run(plan):
    plan.print("Running plan")

    # TODO: this can be pulled into the local da repo and then imported here
    plan.print("Adding Local DA service")
    plan.add_service(
        name="local-da",
        config=ServiceConfig(
            image="ghcr.io/rollkit/local-da:aa37274",
            ports={
                "jsonrpc": PortSpec(
                    number=7980,
                    transport_protocol="TCP",
                    application_protocol="http",
                    wait="4s",
                ),
            },
            public_ports={
                "jsonrpc": PortSpec(
                    number=7980, transport_protocol="TCP", application_protocol="http"
                )
            },
        ),
    )
    plan.print("Adding GM service")
    #TODO: Need to figure out how to replicate the network_mode: host setup of docker compose
    plan.add_service(
        name="gm",
        config=ServiceConfig(
            image="ghcr.io/rollkit/gm:19b894c",
        ),
    )
