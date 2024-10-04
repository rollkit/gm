# This Kurtosis package spins up a minimal GM rollup that connects to a DA node

# DA Types
celestia = "celestia"
avail = "avail"
local_da = "local-da"


def run(
    plan,
    da=local_da,
    da_namespace="00000000000000000000000000000000000000000008e5f679bf7116cb",
):
    # Define vars
    da_rpc_address = None
    da_auth_token = None
    da_wallet_address = None
    da_height = None

    # Start up the DA node
    plan.print("Starting up GM rollup with DA: {0}".format(da))
    if da == local_da:
        plan.print("Using local-da")
        da_node = import_module("github.com/rollkit/local-da/main.star@v0.3.1")
        da_rpc_address = da_node.run(
            plan,
        )
    elif da == celestia:
        # Uses arabica by default
        # TODO: add inputs to target mocha
        plan.print("Using celestia for DA")
        da_node = import_module(
            "github.com/rollkit/kurtosis-celestia-da-node/main.star"
        )
        da_rpc_address, da_auth_token, da_wallet_address, da_height = da_node.run(
            plan,
        )
    else:
        fail("Unknown DA: {0}".format(da))

    plan.print("connecting to da layer via {0}".format(da_rpc_address))
    #####
    # GM
    #####

    plan.print("Adding GM service")
    plan.print("NOTE: This can take a few minutes to start up...")

    # Generate start command
    gm_start_cmd = rollkitCMD(
        da,
        da_address=da_rpc_address,
        da_auth_token=da_auth_token,
        da_namespace=da_namespace,
        da_start_height=da_height,
    )
    plan.print("GM start command: {0}".format(gm_start_cmd))

    # Build GM Service Spec
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
            # image="ghcr.io/rollkit/gm:05bd40e",
            image=ImageBuildSpec(
                image_name="gm_temp",
                build_context_dir=".",
            ),
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


def rollkitCMD(
    da, da_address=None, da_auth_token=None, da_namespace=None, da_start_height=None
):
    if da == celestia:
        return [
            "rollkit",
            "start",
            "--rollkit.aggregator",
            "--rollkit.da_address {0}".format(da_address),
            "--rollkit.da_auth_token {0}".format(da_auth_token),
            "--rollkit.da_namespace {0}".format(da_namespace),
            "--rollkit.da_start_height {0}".format(da_start_height),
            "--minimum-gas-prices=0.025stake",
        ]
    elif da == avail:
        fail("Avail DA is not yet supported")
    elif da == local_da:
        return [
            "rollkit",
            "start",
            "--rollkit.aggregator",
            "--rollkit.da_address {0}".format(da_address),
        ]
    else:
        fail("Unknown DA: {0}".format(da))
