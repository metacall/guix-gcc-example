#
#	MetaCall Guix GCC by Parra Studios
#	Guix GCC Proof of Concept for MetaCall.
#
#	Copyright (C) 2016 - 2023 Vicente Eduardo Ferrer Garcia <vic798@gmail.com>
#
#	Licensed under the Apache License, Version 2.0 (the "License");
#	you may not use this file except in compliance with the License.
#	You may obtain a copy of the License at
#
#		http://www.apache.org/licenses/LICENSE-2.0
#
#	Unless required by applicable law or agreed to in writing, software
#	distributed under the License is distributed on an "AS IS" BASIS,
#	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#	See the License for the specific language governing permissions and
#	limitations under the License.
#

.PHONY: all base pull build test help default

# Default target
default: all

# All targets
all:
	@$(MAKE) clear
	@$(MAKE) base
	@$(MAKE) pull
	@$(MAKE) build
	@$(MAKE) test

# Show help
help:
	@echo 'Management commands for metacall-guix-gcc-example:'
	@echo
	@echo 'Usage:'
	@echo '    make base         Builds base image with MetaCall scripts.'
	@echo '    make pull         Updates Guix repository to the latest version.'
	@echo '    make build        Build the tarball for all platforms and architectures.'
	@echo '    make test         Run integration tests for the already built tarballs.'
	@echo '    make clear        Clear all containers and images.'
	@echo '    make help         Show verbose help.'
	@echo

# Build base Docker image
base:
#	Clear the container
	@docker stop metacall_guix_gcc_example 2> /dev/null || true
	@docker rm metacall_guix_gcc_example 2> /dev/null || true
#	Build the base image
	@docker build -t metacall/guix_gcc_example -f Dockerfile .

# Pull latest version of Guix
pull:
#	Clear the container
	@docker stop metacall_guix_gcc_example 2> /dev/null || true
	@docker rm metacall_guix_gcc_example 2> /dev/null || true
#	Install the additional channels and pull
	@docker run --privileged --name metacall_guix_gcc_example metacall/guix_gcc_example sh -c 'guix pull'
	@docker commit metacall_guix_gcc_example metacall/guix_gcc_example
	@docker rm -f metacall_guix_gcc_example
	@echo "Done"

# Build tarball
build:
#	Clear the container
	@docker stop metacall_guix_gcc_example 2> /dev/null || true
	@docker rm metacall_guix_gcc_example 2> /dev/null || true
#	Patch the script (build.sh) with latest version
	@docker run -v `pwd`/scripts:/metacall/patch --privileged --name metacall_guix_gcc_example metacall/guix_gcc_example cp /metacall/patch/build.sh /metacall/scripts/build.sh
	@docker commit metacall_guix_gcc_example metacall/guix_gcc_example
	@docker rm -f metacall_guix_gcc_example
#	Build tarball and store it into out folder
	@docker run --rm -v `pwd`/out:/metacall/pack --privileged --name metacall_guix_gcc_example metacall/guix_gcc_example /metacall/scripts/build.sh
	@echo "Done"

# Test tarballs
test:
#	Generate a unique id for invalidating the cache of test layers
	$(eval CACHE_INVALIDATE := $(shell date +%s))
#	Run tests
	docker build --build-arg CACHE_INVALIDATE=${CACHE_INVALIDATE} -t metacall/guix_gcc_example_test:busybox -f tests/busybox/Dockerfile .
	@echo "Done"

# Clear images and containers
clear:
#	Clear the tarball
	@rm -rf out/* && touch out/.gitkeep
#	Clear the container
	@docker stop metacall_guix_gcc_example 2> /dev/null || true
	@docker rm metacall_guix_gcc_example 2> /dev/null || true
#	Clear the images
	@docker images | grep metacall/guix_gcc_example_test | tr -s ' ' | cut -d ' ' -f 2 | xargs -I {} docker rmi metacall/guix_gcc_example_test:{} 2> /dev/null || true
	@docker rmi metacall/guix_gcc_example 2> /dev/null || true

# Empty target do nothing
%:
	@:
