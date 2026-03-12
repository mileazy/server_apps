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

# volume lists for each stack (used by remove target)
portainer_volumes := portainer_data
nginxpm_volumes := nginxpm_data nginxpm_letsencrypt
jellyfin_volumes := jellyfin_config jellyfin_cache

# helper to get volumes variable for a stack
volumes_for = $($(1)_volumes)

# Remove Stack
remove:
	@if [ -z "$(stack)" ]; then echo "usage: make remove stack=portainer"; exit 1; fi
	@read -p "Rimuovere anche i volumi? (s/n): " choice; \
	if [ "$$choice" = "s" ] || [ "$$choice" = "S" ]; then \
		vols="$(call volumes_for,$(stack))"; \
		if [ -n "$$vols" ]; then \
			docker volume rm $$vols || true; \
		fi; \
		$(call docker_remove,$(stack)); \
	else \
		$(call docker_remove,$(stack)); \
	fi
# Portainer
portainer:
	docker volume create $(portainer_volumes)
	$(call docker_rebuild,"portainer")

# NGINX Proxy Manager
nginxpm:
	docker volume create $(nginxpm_volumes)
	$(call docker_rebuild,"nginxpm")

# it-tools
it-tools:
	$(call docker_rebuild,"it-tools")

# Jellyfin
jellyfin:
	docker volume create $(jellyfin_volumes)
	$(call docker_rebuild,"jellyfin")