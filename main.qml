import QtQuick 2.14
import QtQuick.Window 2.14
import 'helpers/polyfills/setTimeout.js' as SetTimeout
import 'helpers/vdom.js' as VDOM
import 'src-elm/elm.js' as Elm

Window {
    id: mainwindow // this is used in helpers/vdom.js! TODO better encapsulation?
    visible: true
    width: 640
    height: 480
    title: "QT + Elm Spreadsheet!"

    Component.onCompleted: {
        const elmApp = Elm.initElmApp().Main.init();
        //elmApp.ports.qmlToElm.send({tag: 'hi to Elm from QML', someData: 42});
        elmApp.ports.elmToQML.subscribe((value) => {
            console.log('----------------------------------------------');
            console.log(`Got message from Elm! ${value.tag}`);
            switch (value.tag) {
                case 'ElmInitFinished':
                    VDOM.create(value.initialVDOM, mainwindow);
                    break;
                case 'NewVDOM':
                    // TODO be more efficient with new views... diff, patch, do only minimum necessary work
                    VDOM.clear(mainwindow);
                    VDOM.create(value.vdom, mainwindow);
                    break;
                default:
                    console.error(`Unknown Elm message to QML! ${value.tag}`);
            }
        });
    }
}
