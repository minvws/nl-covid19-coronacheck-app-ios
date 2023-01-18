## This script is triggered from the Makefile, do not run directly.

## localizations: 
array=( "nl" "en" )


for i in "${array[@]}"
do
    mkdir -p "Packages/Shared/Sources/Shared/Resources/Localization/${i}.lproj"

    COMBINED_PATH="Packages/Shared/Sources/Shared/Resources/Localization/${i}.lproj/Localizable.strings"
	PLURAL_PATH="Packages/Shared/Sources/Shared/Resources/Localization/${i}.lproj/Localizable.stringsdict"

    cat tmp/localization_downloads/Holder/$i.lproj/Localizable.strings > $COMBINED_PATH
	cat tmp/localization_downloads/Holder/$i.lproj/Localizable.stringsdict > $PLURAL_PATH
    cat tmp/localization_downloads/Verifier/$i.lproj/Localizable.strings >> $COMBINED_PATH
	#cat Localizations/Verifier/$i.lproj/Localizable.stringsdict >> $PLURAL_PATH

    # Count duplicate lines
    DUPLICATE_LINE_COUNT=$(sort $COMBINED_PATH | sed '/\/\*/d' | sed '/^$/d' | uniq -d | wc -l | xargs)

    if (( $DUPLICATE_LINE_COUNT != 0 )); then
    echo "warning: The ${i} localized copy has ${DUPLICATE_LINE_COUNT} duplicate keys"
    fi
done
