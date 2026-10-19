.DEFAULT_GOAL := help
PYTHON ?= python3

.PHONY: help up down logs front-install front-dev front-build front-test back-install back-test

help:
	@printf '%s\n' \
	  'up             Build and start the local Docker stack' \
	  'down           Stop the local Docker stack, retaining data' \
	  'logs           Follow local service logs' \
	  'front-install  Install frontend dependencies with npm ci' \
	  'front-dev      Start the frontend development server on port 9001' \
	  'front-build    Compile the local frontend into taiga-front/dist' \
	  'front-test     Run the frontend CI build and browser tests' \
	  'back-install   Install backend runtime and test dependencies into the active virtualenv' \
	  'back-test      Run backend tests (local PostgreSQL required)' \
	  'See docs/DEVELOPMENT.md for prerequisites and Git subtree commands.'

up:
	docker compose up --build -d --wait

down:
	docker compose down

logs:
	docker compose logs -f

front-install:
	cd taiga-front && npm ci

front-dev:
	cd taiga-front && npm start

front-build:
	cd taiga-front && npx --no-install gulp deploy

front-test:
	cd taiga-front && npm run ci:test

back-install:
	cd taiga-back && $(PYTHON) -m pip install -r requirements.txt -r requirements-devel.txt

back-test:
	cd taiga-back && $(PYTHON) -m pytest $(ARGS)
