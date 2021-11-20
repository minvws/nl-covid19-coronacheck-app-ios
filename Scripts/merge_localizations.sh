
## localizations: 
shortname=( "nl" "en" )
longname=( "nl-NL" "en-EN" )

for i in "${!shortname[@]}"; do
    COMBINED_PATH="Sources/CTR/Infrastructure/Resources/Localization/${shortname[i]}.lproj/Localizable.strings"

    cat "Localizations/Holder/${longname[i]}.lproj/Localizable.strings" > $COMBINED_PATH
    cat "Localizations/Verifier/${longname[i]}.lproj/Localizable.strings" >> $COMBINED_PATH

    # Count duplicate lines
    DUPLICATE_LINE_COUNT=$(sort $COMBINED_PATH | sed '/\/\*/d' | sed '/^$/d' | uniq -d | wc -l | xargs)

    if (( $DUPLICATE_LINE_COUNT != 0 )); then
    echo "warning: The ${i} localized copy has ${DUPLICATE_LINE_COUNT} duplicate keys"
    fi
done