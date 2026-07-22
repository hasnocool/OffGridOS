IMAGE_NAME=offgridos-base

.PHONY: docker-build build run

docker-build:
	docker build -t $(IMAGE_NAME) .

build:
	bash ./scripts/build-base-image.sh

run:
	docker run --rm -it $(IMAGE_NAME)
