# This Kurtosis package spins up a minimal GM rollup that connects to a local DA


def run(plan):
    # TODO: this can be pulled into the local da repo and then imported here
    plan.print("Adding Local DA service")
    local_da = plan.add_service(
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
    # Set the local DA address for the GM service
    # TODO: this would be returned by the local DA package
    local_da_address = "http://{0}:{1}".format(
        local_da.ip_address, local_da.ports["jsonrpc"].number
    )

    plan.print("Adding GM service")
    plan.print("NOTE: This can take a few minutes to start up...")
    gm_start_cmd = [
        "rollkit",
        "start",
        "--rollkit.aggregator",
        "--rollkit.da_address {0}".format(local_da_address),
    ]
    gm = plan.add_service(
        name="gm",
        config=ServiceConfig(
            image="ghcr.io/rollkit/gm:1359143",
            cmd=["/bin/sh", "-c", " ".join(gm_start_cmd)],
            ports={
                "jsonrpc": PortSpec(
                    number=26657,
                    transport_protocol="TCP",
                    application_protocol="http",
                ),
            },
            public_ports={
                "jsonrpc": PortSpec(
                    number=26657,
                    transport_protocol="TCP",
                    application_protocol="http",
                )
            },
            ready_conditions=ReadyCondition(
                recipe=ExecRecipe(
                    command=["rollkit", "status"],
                    extract={
                        "output": "fromjson | .node_info.network",
                    },
                ),
                field="extract.output",
                assertion="==",
                target_value="gm",
                interval="1s",
                timeout="5m",
            ),
        ),
    )
