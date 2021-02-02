export PATH=$PATH:~/go/bin
git clone git@github.com:minvws/nl-covid19-coronatester-ctcl-core-private.git tmp-ctcl
cd tmp-ctcl
git checkout app-integration
gomobile bind -target ios -o ctcl.framework github.com/minvws/nl-covid19-coronatester-ctcl-core/clmobile
cd ../
rm -rf ctcl.framework
cp -R tmp-ctcl/ctcl.framework .
rm -rf tmp-ctcl