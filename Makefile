include .env
export

export PROJECT_ROOT=$(shell pwd)

env-up:
	@docker compose up -d todoapp-postgres

env-down:
	@docker compose down todoapp-postgres

env-port-forward:
	@docker compose up -d port-forwarder

env-port-down:
	@docker compose down port-forwarder

env-cleanup:
	@read -p "Clean all volumes [y/N]: " ans; \
	if [ "$$ans" = "y" ]; then \
	  docker compose down todoapp-postgres && \
	  rm -rf out/pgdata \
	  echo "Volume files been cleaned"; \
	else \
	  echo "Volume clear is stopped"; \
	  fi

migrate-create:
	@if [ -z "${seq}" ]; then \
  		echo "Failed to find seq. Example: make create-migrate seq=name"; \
  		exit 1; \
  	fi;
	@MSYS_NO_PATHCONV=1 docker compose run --rm todoapp-postgres-migrate \
		create \
		-ext sql \
		-dir /migrations \
		-seq "${seq}"

migrate-action:
	@if [ -z "${action}" ]; then \
  		echo "Failed to find action. Example: make migrate-action action=up"; \
  		exit 1; \
  		fi;
	@docker compose run --rm todoapp-postgres-migrate\
		-path /migrations \
		-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable \
		$(action)

migrate-up:
	@make migrate-action action=up

migrate-down:
	@make migrate-action action=down
