git clone git@github.com:minvws/nl-covid19-coronatester-ctcl-core-private.git tmp-ctcl
cd tmp-ctcl
gomobile bind -target ios -o ctcl.framework github.com/minvws/nl-covid19-coronatester-ctcl-core/clmobile
cd ../
cp -R tmp-ctcl/ctcl.framework .
rm -rf tmp-ctcl