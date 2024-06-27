def run(plan):
    plan.print("Running plan")
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
    # plan.add_service(
    #     name="gm",
    #     config=ServiceConfig(
    #         image=ImageBuildSpec(image_name="gm", build_context_dir="./"),
    #     ),
    # )
