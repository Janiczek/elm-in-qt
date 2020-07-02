import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14
import 'helpers/polyfills/setTimeout.js' as SetTimeout
import 'helpers/virtual-qml.js' as VirtualQML
import 'src-elm/elm.js' as Elm

Window {
    id: mainwindow // TODO this is being used in vdom.js! somehow encapsulate this
    visible: true
    width: 640
    height: 480
    title: "Elm in Qt"

    property var elm

    Component.onCompleted: {
        // create an element dynamically that will be Elm's root (and change etc.)
        // if we created it outside JS, we couldn't .destroy() it...
        Qt.createQmlObject('import QtQuick 2.14; Text {}', mainwindow, 'root');

        elm = Elm.initElmApp().Main.init();

        elm.ports.elmToQt.subscribe((value) => {
            switch (value.tag) {
                case 'ViewChanged':
                    VirtualQML.applyPatch(value.patch, mainwindow.data[0]);
                    break;
                default:
                    throw(`Unknown Elm message to Qt: ${value.tag}`);
            }
        });
    }
}
