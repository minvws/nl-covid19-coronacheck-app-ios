
## localizations: 
array=( "nl" "en" )

for i in "${array[@]}"
do
    COMBINED_PATH="Sources/CTR/Infrastructure/Resources/Localization/${i}.lproj/Localizable.strings"
	PLURAL_PATH="Sources/CTR/Infrastructure/Resources/Localization/${i}.lproj/Localizable.stringsdict"

    cat Localizations/Holder/$i.lproj/Localizable.strings > $COMBINED_PATH
	cat Localizations/Holder/$i.lproj/Localizable.stringsdict > $PLURAL_PATH
    cat Localizations/Verifier/$i.lproj/Localizable.strings >> $COMBINED_PATH
	#cat Localizations/Verifier/$i.lproj/Localizable.stringsdict >> $PLURAL_PATH

    # Count duplicate lines
    DUPLICATE_LINE_COUNT=$(sort $COMBINED_PATH | sed '/\/\*/d' | sed '/^$/d' | uniq -d | wc -l | xargs)

    if (( $DUPLICATE_LINE_COUNT != 0 )); then
    echo "warning: The ${i} localized copy has ${DUPLICATE_LINE_COUNT} duplicate keys"
    fi
done
