# Function: Docker Rebuild
# [execute: down, remove, pull, build, up]
# $(call docker_rebuild,"stack_name")
define docker_rebuild
	docker compose -p $(1) -f docker/$(1)/docker-compose.yml down && \
	docker compose -p $(1) -f docker/$(1)/docker-compose.yml rm -f && \
	docker compose -p $(1) -f docker/$(1)/docker-compose.yml pull && \
	docker compose -p $(1) -f docker/$(1)/docker-compose.yml build --no-cache && \
	docker compose -p $(1) -f docker/$(1)/docker-compose.yml up -d
endef
# Function: Docker Remove (images only)
# [execute: down, remove, delete images]
# $(call docker_remove,"stack_name")
define docker_remove
	docker compose -p $(1) -f docker/$(1)/docker-compose.yml down --rmi all && \
	docker compose -p $(1) -f docker/$(1)/docker-compose.yml rm -f
endef
# Function: Docker Remove (images and volumes)
# [execute: down, remove, delete images and volumes]
# $(call docker_remove_full,"stack_name")
define docker_remove_full
	docker compose -p $(1) -f docker/$(1)/docker-compose.yml down --rmi all --volumes && \
	docker compose -p $(1) -f docker/$(1)/docker-compose.yml rm -f
endef
# Initialization
init:
	docker network create --driver bridge reverse-proxy
# Remove Stack
remove:
	@if [ -z "$(stack)" ]; then echo "usage: make remove stack=portainer"; exit 1; fi
	@read -p "Rimuovere anche i volumi? (s/n): " choice; if [ "$$choice" = "s" ] || [ "$$choice" = "S" ]; then $(call docker_remove_full,$(stack)); else $(call docker_remove,$(stack)); fi
# Portainer
portainer:
	docker volume create portainer_data
	$(call docker_rebuild,"portainer")
# NGINX Proxy Manager
nginxpm:
	docker volume create nginxpm_data
	docker volume create nginxpm_letsencrypt
	$(call docker_rebuild,"nginxpm")
# it-tools
it-tools:
	$(call docker_rebuild,"it-tools")

# Jellyfin
jellyfin:
	docker volume create jellyfin_config
	docker volume create jellyfin_cache
	$(call docker_rebuild,"jellyfin")