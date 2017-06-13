COMPONENT := featurebalancer
CONTAINER := phpfarm
IMAGES ?= false
PHP_VERSION ?: false
APP_ROOT := /app/feature-balancer
CODE_COVERAGE_FORMAT ?= clover

all: dev logs

dev:
	@docker-compose -p ${COMPONENT} -f ops/docker/docker-compose.yml up -d

enter:
	@docker exec -ti ${COMPONENT}_${CONTAINER}_1 /bin/bash

kill:
	@docker-compose -p ${COMPONENT} -f ops/docker/docker-compose.yml kill

nodev:
	@docker-compose -p ${COMPONENT} -f ops/docker/docker-compose.yml kill
	@docker-compose -p ${COMPONENT} -f ops/docker/docker-compose.yml rm -f
ifeq ($(IMAGES),true)
	@docker rmi ${COMPONENT}_${CONTAINER}
endif

deps:
	@docker exec -t $(shell docker-compose -p ${COMPONENT} -f ops/docker/docker-compose.yml ps -q ${CONTAINER}) \
	 php-5.5 /usr/bin/composer install

test: unit
unit:
	make dev
	make deps
	@docker exec -t ${COMPONENT}_${CONTAINER}_1 ${APP_ROOT}/ops/scripts/unit.sh ${PHP_VERSION}

code-coverage:
	make dev
	make deps
	@docker exec -t ${COMPONENT}_${CONTAINER}_1 php-7.0 ${APP_ROOT}/bin/app code-coverage:run ${CODE_COVERAGE_FORMAT}

ps: status
status:
	@docker-compose -p ${COMPONENT} -f ops/docker/docker-compose.yml ps

logs:
	@docker-compose -p ${COMPONENT} -f ops/docker/docker-compose.yml logs

tag: # List last tag for this repo
	@git tag -l | sort -r |head -1

restart: nodev dev logs