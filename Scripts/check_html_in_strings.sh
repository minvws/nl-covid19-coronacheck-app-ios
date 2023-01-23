## This script is triggered from the Makefile, do not run directly.

# exit when any command fails
set -e

TEMP_DIR=`mktemp -d`

#Compile script:
xcrun --sdk macosx swiftc Scripts/strings_checker.swift -o $TEMP_DIR/strings_checker

#Run script:

array=( "tmp/localization_downloads/Holder/nl.lproj/Localizable.strings" "tmp/localization_downloads/Holder/en.lproj/Localizable.strings" "tmp/localization_downloads/Verifier/en.lproj/Localizable.strings" "tmp/localization_downloads/Verifier/nl.lproj/Localizable.strings" )
 
for i in "${array[@]}"
do
    echo "Checking HTML in ${i}..."
    $TEMP_DIR/strings_checker "${i}"
done

echo "HTML check complete"