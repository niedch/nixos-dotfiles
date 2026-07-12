command -v go &>/dev/null || return
export PATH="$PATH:$(go env GOPATH)/bin"
