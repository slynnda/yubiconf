dir := $(shell git rev-parse --show-toplevel)
dirname := $(shell basename -a ${dir})

docker_runtime_base_image := archlinux/base:latest
docker_runtime_lang := en_US.UTF-8
docker_runtime_lc_all := en_US.UTF-8
docker_runtime_username := user
docker_image_tag_org := slynnda
docker_image_tag_name := ${dirname}

build:
	docker build \
	  --build-arg docker_runtime_base_image=${docker_runtime_base_image} \
	  --build-arg docker_runtime_lang=${docker_runtime_lang} \
	  --build-arg docker_runtime_lc_all=${docker_runtime_lc_all} \
	  --build-arg docker_runtime_username=${docker_runtime_username} \
	  --tag ${docker_image_tag_org}:${docker_image_tag_name} \
	  --file ${dir}/Dockerfile \
	  .

run: build
	docker run \
	  -e "lang=${docker_runtime_lang}" \
	  --name "${docker_image_tag_name}-run" \
	  -it \
	  --rm \
	  ${docker_image_tag_org}:${docker_image_tag_name} \
	  bash
