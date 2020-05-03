![Screenshot of Elm and QT in a conversation](https://raw.githubusercontent.com/Janiczek/qt-elm-starter/master/doc/success.png)

### TODO

* decoders in events, to be able to get props from the objects... TextInput etc.
* proper VDOM diffing and patching, to do less stuff

### Notes

Note that this needs the `src-elm/elm.js` file to exist. Tweak your QT target
configs to run `make -C src-elm` before building the C++ and QML!

