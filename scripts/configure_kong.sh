#!/bin/bash

# Ensure Kong configuration is only created if it doesn't exist
create_kong_config() {
    local config_file="/etc/kong/kong.yml"

    if [ ! -f "" ]; then
        echo "Creating Kong configuration."
        cat <<EOL > ""
_format_version: "3.0"
services:
  - name: api_service
    url: http://backend-service
    routes:
      - name: api_route
        paths:
          - /api
EOL
    else
        echo "Kong configuration already exists."
    fi
}

create_kong_config
