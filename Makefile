# Makefile for managing Docker containers

define docker_rebuild
	docker compose -p $(1) -f docker$(1)/docker-compose.yml down && \
	docker compose -p $(1) -f docker$(1)/docker-compose.yml rm -f && \
	docker compose -p $(1) -f docker$(1)/docker-compose.yml pull && \
	docker compose -p $(1) -f docker$(1)/docker-compose.yml build --no-cache && \
	docker compose -p $(1) -f docker$(1)/docker-compose.yml up -d
endef

# Initialize Docker network
init:
	docker network create --driver bridge reverse-proxy

# Portainer
portainer:
	docker volume create portainer_data
	$(call docker_rebuild, "portainer")

# Nginx Proxy Manager
nginxpm:
	docker volume create nginxpm_data
	docker volume create nginxpm_letsencrypt
	$(call docker_rebuild, "nginxpm")

# it-tools
it-tools:
	$(call docker_rebuild, "it-tools")

# Jellyfin
jellyfin:
	docker volume create jellyfin_config
	docker volume create jellyfin_cache
	$(call docker_rebuild, "jellyfin")