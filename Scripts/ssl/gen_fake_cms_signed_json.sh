#!/bin/sh

DIR=./../../nl-covid19-coronacheck-provider-docs*/signing-demo/shellscript

if ! test -d $DIR; then	
	echo Check out https://github.com/minvws/nl-covid19-coronacheck-provider-docs 
	echo or its internal version.
	exit 1
fi
	
$DIR/sign.sh $DIR/example.json 1002.pem 
