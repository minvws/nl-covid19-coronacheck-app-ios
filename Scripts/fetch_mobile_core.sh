# Compile with the latest stable Go version

set -eux

export PATH=$PATH:~/go/bin
commit_hash="0b1d6d8c2a699449f614e90a0e2e5cc643fa67a1" # v0.4.5
destination_path="Packages/CryptoCore/Frameworks/mobilecore.xcframework"
temp_path="tmp-mobile-core"

git clone git@github.com:minvws/nl-covid19-coronacheck-mobile-core-private.git "$temp_path"

pushd "$temp_path"
git checkout "$commit_hash"
go mod download golang.org/x/mobile
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init
gomobile bind -target ios,iossimulator -o mobilecore.xcframework -iosversion 11.0 github.com/minvws/nl-covid19-coronacheck-mobile-core
popd

rm -rf mobilecore.framework Frameworks # TODO: I don't think these are necessary

rm -rf "$destination_path"
cp -r "${temp_path}/mobilecore.xcframework" "$destination_path"
rm -rf "$temp_path"
