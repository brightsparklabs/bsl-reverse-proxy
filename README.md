# brightSPARK Labs Reverse Proxy

An `appcli` based project for standing up a reverse proxy to manage traffic for multiple `docker-compose` projects running on the same machine.

## Overview

The idea of this project is to have a central ingress point for all the `docker-compose` / `appcli` projects that are part of your tech stack.

```mermaid
  graph TD

    U["User"]

    %% Reverse Proxy stack.
    subgraph RP ["Reverse Proxy"]
        P["Proxy"]
    end

    %% StackX
    subgraph SX ["StackX"]
        A["AppA"]
        B["AppB"]
    end

    %% StackY
    subgraph SY ["StackY"]
        C["AppC"]
        D["AppD"]
    end

    %% Edges
    U -->|"https#58;//mydomain.example.com"| P
    P -->|"http#58;//appa.stackx:8080"| A
    P -->|"http#58;//appb.stackx:5432"| B
    P -->|"http#58;//appc.stacky:8080"| C
    P -->|"http#58;//appd.stacky:1234"| D
```

It provides the following benefits:

- Stops nested services fighting over the `80/443` port allocation.
- Central place to manage `TLS` certificates and keys.
- Central point to offload `AuthZ/AuthN` verification.
- Central place to manage `DNS` based routing.

## Configuration

See [appcli](https://github.com/brightsparklabs/appcli) for information on basic `appcli` setup.

The projects can be configured in the `settings.yml` file.
