cat $SCRIPT_INPUT_FILE_0 > $SCRIPT_OUTPUT_FILE_0
cat $SCRIPT_INPUT_FILE_1 >> $SCRIPT_OUTPUT_FILE_0

# Count duplicate lines
DUPLICATE_LINE_COUNT=$(sort $SCRIPT_OUTPUT_FILE_0 | sed '/\/\*/d' | sed '/^$/d' | uniq -d | wc -l | xargs)

if (( $DUPLICATE_LINE_COUNT != 0 )); then
echo "warning: The ${SCRIPT_OUTPUT_FILE_0} localized copy has ${DUPLICATE_LINE_COUNT} duplicate keys"
fi
