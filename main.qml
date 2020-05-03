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
        elm = Elm.initElmApp().Main.init();
        //elm.ports.qtToElm.send({tag: 'hi to Elm from Qt', someData: 42});
        elm.ports.elmToQt.subscribe((value) => {
            console.log('----------------------------------------------');
            console.log(`Got message from Elm! ${value.tag}`);
            switch (value.tag) {
                case 'ElmInitFinished':
                    VirtualQML.create(value.initialView, mainwindow, elm);
                    break;
                case 'NewView':
                    // TODO be more efficient with new views... diff, patch, do only minimum necessary work
                    VirtualQML.clear(mainwindow);
                    VirtualQML.create(value.view, mainwindow, elm);
                    break;
                default:
                    console.error(`Unknown Elm message to Qt! ${value.tag}`);
            }
        });
    }
}
