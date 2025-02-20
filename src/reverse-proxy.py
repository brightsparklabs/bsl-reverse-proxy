#!/usr/bin/env python3
# # -*- coding: utf-8 -*-

"""
CLI for BSL Reverse Proxy.
________________________________________________________________________________

Created by brightSPARK Labs
www.brightsparklabs.com
"""

# ------------------------------------------------------------------------------
# IMPORTS
# ------------------------------------------------------------------------------

# Appcli imports.
from appcli.cli_builder import create_cli
from appcli.models.configuration import Configuration
from appcli.models.configuration import Hooks
from appcli.models.cli_context import CliContext
from appcli.variables_manager import VariablesManager
from appcli.logger import logger

# Vendor imports.
import click
import docker


# ------------------------------------------------------------------------------
# CONSTANTS
# ------------------------------------------------------------------------------

NETWORKS_SETTING = "reverse_proxy.routing.networks"
"""Where in `settings.yml` the external networks are defined."""


# ------------------------------------------------------------------------------
# HOOKS
# ------------------------------------------------------------------------------

def get_hooks() -> Hooks:
    """Create and return the hooks."""

    def pre_start(ctx: click.Context):
        """Ensure all the referenced docker-compose networks exist (and create if not)."""
        # Parse the context to get the required networks.
        cli_context: CliContext = ctx.obj
        variables_manager: VariablesManager = cli_context.get_variables_manager()
        # NOTE: This is a `list[dict]` but the `appcli` method signature return is `dict` so we ignore.
        networks: list[dict] = variables_manager.get_variable(NETWORKS_SETTING) # type: ignore

        # Create the networks (if required).
        client = docker.from_env()
        for network_config in networks:

            # Define some variables for the names.
            network = network_config.get('network', "default")
            project = network_config.get('project')
            name = f"{project}_{network}"

            # Query docker to see if the network name exists.
            if not client.networks.list(names=[name]):
                logger.info(f"External network `{name}` does not exist. Creating.")
                client.networks.create(name=name, labels={
                    "com.docker.compose.network": network,
                    "com.docker.compose.project": project,
                })

    return Hooks(pre_start=pre_start)


# ------------------------------------------------------------------------------
# ENTRYPOINT
# ------------------------------------------------------------------------------

def main():
    configuration = Configuration(
        app_name="reverse-proxy",
        docker_image="docker.brightsparklabs.com/brightsparklabs/reverse-proxy",
        hooks=get_hooks(),
    )
    cli = create_cli(configuration)
    cli()

if __name__ == "__main__":
    main()
