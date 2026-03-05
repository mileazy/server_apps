# Makefile for managing Docker containers

define docker_rebuild
	docker compose -p $(1) -f $(2)/docker_compose.yml down && \
	docker compose -p $(1) -f $(2)/docker_compose.yml rm -f && \
	docker compose -p $(1) -f $(2)/docker_compose.yml pull && \
	docker compose -p $(1) -f $(2)/docker_compose.yml build --no-cache && \
	docker compose -p $(1) -f $(2)/docker_compose.yml up -d
endef

# Initialize Docker network
init:
	docker network create --driver bridge reverse-proxy

# Portainer
portainer:
	docker volume create portainer_data
	$(call docker_rebuild, "portainer","docker/portainer")
# Nginx Proxy Manager
nginxpm:
	docker volume create nginxpm_data
	docker volume create nginxpm_letsencrypt
	$(call docker_rebuild, "nginxpm","docker/nginxpm")