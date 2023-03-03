# Compile with Go version go1.18.2 darwin/arm64

export PATH=$PATH:~/go/bin
set -eux
git clone git@github.com:minvws/nl-covid19-coronacheck-mobile-core-private.git tmp-clcore
cd tmp-clcore
git checkout v0.4.5
git submodule init
git submodule update
go mod download golang.org/x/mobile
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init
gomobile bind -target ios,iossimulator -o clcore.xcframework -iosversion 11.0 github.com/minvws/nl-covid19-coronacheck-mobile-core
cd ../
rm -rf clcore.framework # cleanup previous location
rm -rf Frameworks # cleanup previous location
cp -R tmp-clcore/clcore.xcframework Packages/CryptoCore/Frameworks/
rm -rf tmp-clcore
