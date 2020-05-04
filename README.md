# Elm in Qt

![Screenshot of Elm in Qt](https://raw.githubusercontent.com/Janiczek/qt-elm-starter/master/doc/elm-in-qt.png)

This is an example project that runs Elm inside Qt 5 (more precisely, QML).

It gives you the declarative `Model -> View` way to do layouts, that you know
and love from Elm, React etc.

### Requirements

* make
* qmake / QT Creator
* yarn

For the QT part you'll need `qmake` and `make` (or the whole ); for the Elm part you'll need `yarn`

Note that compiling the QT project needs the `src-elm/elm.js` file to exist.
Tweak your QT target configs to run `make -C src-elm` before building!

![Build step screenshot](https://raw.githubusercontent.com/Janiczek/qt-elm-starter/master/doc/build-step.png)

### TODO

* decoders in events, to be able to get props from the objects... TextInput etc.
* proper VDOM diffing and patching, to do less stuff. Our Counter demo is not
  very snappy right now!
* find out how to do statically built binaries
