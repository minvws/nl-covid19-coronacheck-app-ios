
## localizations: 
array=( "nl" "en" )

for i in "${array[@]}"
do
    COMBINED_PATH="Sources/CTR/Infrastructure/Resources/Localization/${i}.lproj/Localizable.strings"

    cat Localizations/CoronaCheck\ holder/$i/Localizable.strings > $COMBINED_PATH
    cat Localizations/CoronaCheck\ verifier/$i/Localizable.strings >> $COMBINED_PATH

    # Count duplicate lines
    DUPLICATE_LINE_COUNT=$(sort $COMBINED_PATH | sed '/\/\*/d' | sed '/^$/d' | uniq -d | wc -l | xargs)

    if (( $DUPLICATE_LINE_COUNT != 0 )); then
    echo "warning: The ${i} localized copy has ${DUPLICATE_LINE_COUNT} duplicate keys"
    fi
done