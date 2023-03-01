#!/bin/sh

#
#	MetaCall Guix GCC by Parra Studios
#	Guix GCC Proof of Concept for MetaCall.
#
#	Copyright (C) 2016 - 2023 Vicente Eduardo Ferrer Garcia <vic798@gmail.com>
#
#	Licensed under the Apache License, Version 2.0 (the "License")
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

export GUILE_WARN_DEPRECATED='detailed'

# Generate a portable package tarball
`# Build` guix build --fallback gcc@2.95 \
`# Test` `# && guix package -i gcc@2.95` \
`# Pack uses --no-grafts option in order to avoid conflicts between duplicated versions` \
`# Pack` && guix pack --no-grafts -S /gnu/bin=bin -S /gnu/etc=etc -S /gnu/lib=lib -RR gcc@2.95 | tee build.log \
`# Copy` && mv `cat build.log | grep "tarball-pack.tar.gz"` /metacall/pack/tarball.tar.gz \
`# Env` && echo 'env' | guix shell gcc@2.95 | grep -e LIBRARY_PATH -e C_INCLUDE_PATH &> /metacall/pack/.env \
`# Exit` && exit 0 || exit 1
