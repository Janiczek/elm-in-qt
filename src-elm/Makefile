.SILENT: build
.PHONY: build
build: prepare-deps
	# TODO --optimize and check the Elm<->QML connection still works
	./node_modules/.bin/elm make src/Main.elm --output elm.js

	# change beginning of the file:
	# - import setTimeout
	# - wrap everything in a function that we'll call explicitly
	# - return the previous IIFE in that new function
	/usr/bin/sed -i '1i const {setTimeout, clearTimeout} = SetTimeout;\nfunction initElmApp() {\nreturn' elm.js
	/usr/bin/nvim -u NONE \
		  -c 'normal ggjjJ' \
			-c 'wq' \
			elm.js # sed added a newline after `return` which this vim line deletes

	# change _Platform_export:
	# - return scope['Elm'] because QML doesn't let the scripts have any notion of this / global / window.
	/usr/bin/nvim -u NONE \
		  -c 'normal gg' \
		  -c '/_Platform_export.exports' \
			-c '/}' \
			-c "normal Oreturn scope['Elm'];" \
			-c 'wq' \
			elm.js

	# change end of the file:
	# - add `return ` to the _Platform_export call
	# - change `this` to `{}`
	# - add `}` at the end to balance the extra wrapping function
	/usr/bin/nvim -u NONE \
		  -c 'normal gg' \
		  -c '/_Platform_export({' \
			-c 'normal Ireturn ' \
			-c 'normal VG' \
			-c 's/this.../{}));}/' \
			-c 'wq' \
			elm.js

.SILENT: format
.PHONY: format
format: prepare-deps
	yarn elm-format --yes ./src

.SILENT: prepare-deps
.PHONY: prepare-deps
prepare-deps: package.json
	yarn

