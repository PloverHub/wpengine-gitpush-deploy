#------------------------------------------------------------------------------
# Makefile - WP Engine Deploy (Positional Args UX)
#------------------------------------------------------------------------------
DEPLOY_SCRIPT := ./deploy.sh
VALID_ENVS := dev stag prod
VALID_TASKS := init prep push deploy

.PHONY: help $(VALID_ENVS) $(VALID_TASKS)

help:
	@echo "------------------------------------------------------------------------------"
	@echo "WordPress Deploy Makefile (Positional UX)"
	@echo
	@echo "Usage:"
	@echo "  make <environment> <task>"
	@echo
	@echo "Environments:"
	@echo "  $(VALID_ENVS)"
	@echo
	@echo "Tasks:"
	@echo "  init     - Setup tmp folder, clone repo, optionally decrypt .env"
	@echo "  prep     - Composer install and cleanup, but no push"
	@echo "  push     - Set upstream and force push to WP Engine"
	@echo "  deploy   - Run full init + prep + push"
	@echo
	@echo "Examples:"
	@echo "  make dev init"
	@echo "  make dev prep"
	@echo "  make stag deploy"
	@echo "  ."
	@echo "  OR just do everything in one go:"
	@echo "  make dev deploy"
	@echo "------------------------------------------------------------------------------"

# Positional-style dispatcher
dev stag prod:
	@env=$@; \
	task=$(word 2, $(MAKECMDGOALS)); \
	if [ -z "$$task" ]; then \
		echo "[ERROR] Missing task after environment: $$env"; \
		make help; \
		exit 1; \
	fi; \
	if ! echo "$(VALID_TASKS)" | grep -qw "$$task"; then \
		echo "[ERROR] Invalid task '$$task'"; \
		make help; \
		exit 1; \
	fi; \
	echo "[INFO] Running task '$$task' for environment '$$env'..."; \
	$(DEPLOY_SCRIPT) $$env $$task; \
	exit 0

# Absorb extra second-arg targets so make doesn't warn
init prep push deploy:
	@:
