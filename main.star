# This Kurtosis package spins up a minimal GM rollup that connects to a local DA


def run(plan):
    ##########
    # local DA
    ##########

    # TODO: this can be pulled into the local da repo and then imported here
    plan.print("Adding Local DA service")
    local_da_port_number = 7980
    local_da_port_spec = PortSpec(
        number=local_da_port_number,
        transport_protocol="TCP",
        application_protocol="http",
    )
    local_da_ports = {
        "jsonrpc": local_da_port_spec,
    }
    local_da = plan.add_service(
        name="local-da",
        config=ServiceConfig(
            image="ghcr.io/rollkit/local-da:v0.2.1",
            ports=local_da_ports,
            public_ports=local_da_ports,
        ),
    )
    # Set the local DA address for the GM service
    # TODO: this would be returned by the local DA package
    local_da_address = "http://{0}:{1}".format(
        local_da.ip_address, local_da.ports["jsonrpc"].number
    )

    #####
    # GM
    #####

    plan.print("Adding GM service")
    plan.print("NOTE: This can take a few minutes to start up...")
    gm_start_cmd = [
        "rollkit",
        "start",
        "--rollkit.aggregator",
        "--rollkit.da_address {0}".format(local_da_address),
    ]
    gm_port_number = 26657
    gm_port_spec = PortSpec(
        number=gm_port_number, transport_protocol="TCP", application_protocol="http"
    )
    gm_frontend_port_spec = PortSpec(
        number=1317, transport_protocol="TCP", application_protocol="http"
    )
    gm_ports = {
        "jsonrpc": gm_port_spec,
        "frontend": gm_frontend_port_spec,
    }
    gm = plan.add_service(
        name="gm",
        config=ServiceConfig(
            # Using rollkit version v0.13.5
            image="ghcr.io/rollkit/gm:05bd40e",
            cmd=["/bin/sh", "-c", " ".join(gm_start_cmd)],
            ports=gm_ports,
            public_ports=gm_ports,
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
                timeout="1m",
            ),
        ),
    )

    #############
    # GM Frontend
    #############
    plan.print("Adding GM Frontend service")
    frontend_port_number = 3000
    frontend_port_spec = PortSpec(
        number=frontend_port_number,
        transport_protocol="TCP",
        application_protocol="http",
    )
    frontend_ports = {
        "server": frontend_port_spec,
    }
    frontend = plan.add_service(
        name="frontend",
        config=ServiceConfig(
            image="ghcr.io/rollkit/gm-frontend:v0.2.0",
            ports=frontend_ports,
            public_ports=frontend_ports,
        ),
    )
