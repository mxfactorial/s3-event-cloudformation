APP_NAME = s3-event
ARTIFACT_BUCKET = mxfactorial-websocket-artifacts-dev
REGION = us-east-1

# delete.js vars
SERVICE_TOKEN=
RESPONSE_URL=
STACK_ID=
REQUEST_ID=
LOGICAL_RESOURCE_ID=
PHYSICAL_RESOURCE_ID=
RESOURCE_TYPE=
OBJECT_NAME=

###################### clean ######################

clean-deps:
		rm -rf bin include lib src/__pycache__ .pytest_cache

clean-artifact:
		rm -f $(APP_NAME)-src.zip

clean: clean-deps clean-artifact

###################### deps ######################

install-env: clean-deps
		@python3 -m venv .; \
		. ./bin/activate; \
		pip install pipenv

install-deps:
		. ./bin/activate; pipenv install --dev

install: install-env install-deps

###################### build and test ######################

test: install test-unit

test-unit:
		. ./bin/activate; \
		LAMBDA_ARN=arn:aws:lambda:neverland:012345678910:function:deploy-lambda-dev \
		ARTIFACTS_BUCKET=some-artifact-dev \
		pytest -vv src

zip: clean-artifact
		zip -r -j $(APP_NAME)-src.zip src/main.py

###################### deploy ######################

deploy: zip deploy-only

deploy-only:
	@ETAG=$$(aws s3api put-object \
		--bucket=$(ARTIFACT_BUCKET) \
		--key=$(APP_NAME)-src.zip \
		--body=$(CURDIR)/$(APP_NAME)-src.zip \
		--region=$(REGION) \
		--output=text | xargs); \
	echo "***Deployed from s3 ETag: $$ETAG"

###################### delete custom cf ######################

delete:
	SERVICE_TOKEN=$(SERVICE_TOKEN) \
	RESPONSE_URL=$(RESPONSE_URL) \
	STACK_ID=$(STACK_ID) \
	REQUEST_ID=$(REQUEST_ID) \
	LOGICAL_RESOURCE_ID=$(LOGICAL_RESOURCE_ID) \
	PHYSICAL_RESOURCE_ID=$(PHYSICAL_RESOURCE_ID) \
	RESOURCE_TYPE=$(RESOURCE_TYPE) \
	OBJECT_NAME=$(OBJECT_NAME) \
		node delete.js