# -- Main entrypoint

dev: install_dev_deps install_githooks remove_old_rswift generate_project compile_mobilecore open_project

# -- Setup Environment --

install_dev_deps: homebrew_dev bundler mint
	@echo "All dev dependencies are installed"

# -- -- Homebrew
homebrew_dev:
ifeq (, $(shell which brew))
$(error "You must install homebrew on your system before setup can continue. Visit: https://brew.sh to get started with that.")
endif
	@brew bundle --file Brewfile

homebrew_ci:
	@brew bundle --file Brewfile_CI

homebrew_ci_imagemagick: # only needed for specific context & takes time, so not adding to Brewfile_CI.
	@brew install imagemagick

# -- -- Ruby

bundler: 
ifeq (, $(shell which bundle))
$(error "You must install bundler on your system before setup can continue. You could try running 'gem install bundler'.")
endif
	bundle config set --local path 'vendor/bundle'
	bundle install

# -- -- SPM

mint:
	@mint bootstrap --mintfile ./Mintfile

mint_ci:
	@mint bootstrap --mintfile ./Mintfile_CI

# -- -- Generate MobileCore framework -- 

compile_mobilecore: 
	Scripts/fetch_ctcl.sh

# -- -- Generate Xcode project -- 

generate_project: 
	mint run xcodegen  --spec project.yml

open_project: 
	open CTR.xcodeproj

# -- Linting -- 

run_swiftlint:
	mint run swiftlint --quiet --strict --config=./.swiftlint.yml
	
# -- Install Git Hooks: -- 

install_githooks: install_githooks_gitlfs install_githooks_xcodegen
	@echo "All githooks are installed"

install_githooks_xcodegen:
	@echo "\nxcodegen generate --spec project.yml --use-cache" >> .git/hooks/post-checkout
	@chmod +x .git/hooks/post-checkout

install_githooks_gitlfs:
	@git lfs install --force

# -- Sync with Public Repo -- 

sync_repo:
	@mint bootstrap
	@repotools sync-repo --public-github-path minvws/nl-covid19-coronacheck-app-ios --private-github-path minvws/nl-covid19-coronacheck-app-ios-private    --matching-tags-pattern "Holder-" --matching-tags-pattern "Verifier-"  --excluding-tag-pattern \\-RC .

# -- Lokalize: -- 
# Create an API key here: https://app.lokalise.com/profile
# add export LOKALISE_API_KEY="--your value here--" to your ~/.zshrc file
# run source ~/.zshrc to load in that exported value
# then you can run `make download_translations` each time you want to download the latest copy.

download_translations:
	@mkdir -p tmp/localization_downloads
# Holder: 
	@lokalise2 file download --token ${LOKALISE_API_KEY} --project-id "5229025261717f4fcb81c1.73606773" --format strings --unzip-to tmp/localization_downloads/Holder --export-empty-as skip --original-filenames false
# Verifier: 
	@lokalise2 file download --token ${LOKALISE_API_KEY} --project-id "243601816196631318a279.00348152" --format strings --unzip-to tmp/localization_downloads/Verifier --export-empty-as skip --original-filenames false
# Merge Verifier and Holder into one file for each NL and EN: 
	@Scripts/merge_localizations.sh
# Check the HTML within the strings:
	@Scripts/check_html_in_strings.sh
# Cleanup:
	@rm -rf "tmp/localization_downloads"

# -- Periphery --

scan_unused_code:
	periphery scan --index-exclude "Sources/CTR/Infrastructure/Resources/R.generated.swift"

remove_old_rswift:
	@rm Sources/CTR/Infrastructure/Resources/R.generated.swift || true

generate_diagrams:
	@d2 Diagrams/packages-withouttests.d2 Diagrams/packages-withouttests.png --layout=elk --sketch