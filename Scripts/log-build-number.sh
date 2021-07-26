echo 
echo "✨ ⭐️ ✨ ⭐️ ✨ ⭐️ ✨ ⭐️ ✨"
echo 
echo
echo "BUILD_NUMBER:" `git rev-list --all --count` 
cat project.yml| grep "MARKETING_VERSION:" | sed -e 's/^[ \t]*//'
echo 
echo 
echo "✨ ⭐️ ✨ ⭐️ ✨ ⭐️ ✨ ⭐️ ✨"
echo 
