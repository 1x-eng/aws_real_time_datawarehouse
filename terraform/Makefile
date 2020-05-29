planfile = .state/$(env)/terraform.plan
statefile = .state/$(env)/terraform.tfstate
envvars = env/$(env)/env.json
backendvars = env/$(env)/backend.tfvars
globalvars = variables.json

backendbucket = $(shell cat $(envvars) | jq .backend.bucket -r)

.PHONY: tf/init
tf/init:
	@make guard
	terraform init \
		-var-file="$(envvars)" \
		-var-file="$(globalvars)" \
		-backend-config="$(backendvars)" \
		-reconfigure

.PHONY: tf/plan
tf/plan:
	@make guard
	terraform plan \
		-var-file="$(envvars)" \
		-var-file="$(globalvars)" \
		-out="$(planfile)" \
		-state="$(statefile)" \
		$(TF_ARGS)

tf/import:
	@make guard
	terraform import \
		-var-file="$(envvars)" \
		-var-file="$(globalvars)" \
		-state="$(statefile)" \
		$(TF_ARGS)

.PHONY: tf/destroy
tf/destroy:
	@make guard
	terraform destroy \
		-var-file="$(envvars)" \
		-var-file="$(globalvars)"
		
.PHONY: tf/apply
tf/apply:
	@make guard
	terraform apply $(planfile)
	make tf/output

.PHONY: tf/output
tf/output:
	@make guard
	terraform output -json > .output/$(env)/output.json

.PHONT: guard
guard:
ifndef env
	@echo "'env' variable is not defined! \n"
	@exit 1
endif
	@echo "Configured to environment: '$(env)'"
