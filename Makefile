maDEP := $(shell command -v dep 2> /dev/null)
SUM := $(shell which shasum)

COMMIT := $(shell git rev-parse HEAD)
CAT := $(if $(filter $(OS),Windows_NT),type,cat)
export GO111MODULE=on

GithubTop=github.com

Version=v0.19.6
CosmosSDK=v0.39.2
Tendermint=v0.33.9
Iavl=v0.14.3
Name=cherry
ServerName=exchaind
ClientName=exchaincli


# process linker flags
ifeq ($(VERSION),)
    VERSION = $(COMMIT)
endif

build_tags = netgo

ifeq ($(WITH_CLEVELDB),yes)
  build_tags += gcc
endif
build_tags += $(BUILD_TAGS)
build_tags := $(strip $(build_tags))



ldflags = -X $(GithubTop)/cosmos/cosmos-sdk/version.Version=$(Version) \
	-X $(GithubTop)/cosmos/cosmos-sdk/version.Name=$(Name) \
  -X $(GithubTop)/cosmos/cosmos-sdk/version.ServerName=$(ServerName) \
  -X $(GithubTop)/cosmos/cosmos-sdk/version.ClientName=$(ClientName) \
  -X $(GithubTop)/cosmos/cosmos-sdk/version.Commit=$(COMMIT) \
  -X $(GithubTop)/cosmos/cosmos-sdk/version.CosmosSDK=$(CosmosSDK) \
  -X $(GithubTop)/cosmos/cosmos-sdk/version.Tendermint=$(Tendermint) \
  -X "$(GithubTop)/cosmos/cosmos-sdk/version.BuildTags=$(build_tags)" \
  -X $(GithubTop)/tendermint/tendermint/types.startBlockHeightStr=$(GenesisHeight) \
  -X $(GithubTop)/cosmos/cosmos-sdk/types.MILESTONE_MERCURY_HEIGHT=$(MercuryHeight)


BUILD_FLAGS := -ldflags '$(ldflags)'  -gcflags "all=-N -l"

all: install

install:
	go install -v $(BUILD_FLAGS) -tags "$(BUILD_TAGS)" .


get_vendor_deps:
	@echo "--> Generating vendor directory via dep ensure"
	@rm -rf .vendor-new
	@dep ensure -v -vendor-only

update_vendor_deps:
	@echo "--> Running dep ensure"
	@rm -rf .vendor-new
	@dep ensure -v -update

go-mod-cache: go.sum
	@echo "--> Download go modules to local cache"
	@go mod download
.PHONY: go-mod-cache

go.sum: go.mod
	@echo "--> Ensure dependencies have not been modified"
	@go mod verify
	@go mod tidy


build:
	go build $(BUILD_FLAGS) -o ship .

.PHONY: build
