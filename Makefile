.PHONY: setup build test lint gem install uninstall clean docserver

# Retrieve operating system name
OS=$(shell uname -s)
# Define the flags for libsecp256k1
LIBSECP256K1_FLAGS=

# On macOS we need to prefix to homebrew OpenSSL path before building
ifeq ($(OS),Darwin)
	COMPILE_PREFIX=PKG_CONFIG_PATH="/usr/local/opt/openssl/lib/pkgconfig"
endif

# Enable recovery module
ifeq ($(WITH_RECOVERY), 1)
	LIBSECP256K1_FLAGS+=--enable-module-recovery
endif

# Enable EC Diffie-Hellman module
ifeq ($(WITH_ECDH), 1)
	LIBSECP256K1_FLAGS+= --enable-module-ecdh --enable-experimental
endif

all: test

deps:
	cd vendor/secp256k1 && \
	./autogen.sh && \
	./configure --disable-benchmark --disable-exhaustive-tests --enable-shared=no --disable-tests --disable-debug $(LIBSECP256K1_FLAGS) && \
	make && \
	sudo make install

uninstall-deps:
	cd vendor/secp256k1 && \
	sudo make uninstall

setup:
	bundle install

build:
	$(COMPILE_PREFIX) bundle exec rake compile

test: build
	bundle exec rspec

lint:
	bundle exec rubocop

gem:
	gem build rbsecp256k1.gemspec

install: gem
	gem install rbsecp256k1-*.gem

uninstall:
	gem uninstall rbsecp256k1

clean:
	rm -rf *~ rbsecp256k1-*.gem lib/rbsecp256k1/rbsecp256k1.so tmp .yardoc

docserver:
	bundle exec yard server --reload
