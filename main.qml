import QtQuick 2.12
import QtQuick.Window 2.12
import 'helpers/setTimeout.js' as SetTimeout
import 'src-elm/elm.js' as Elm

Window {
    id: mainwindow
    visible: true
    width: 640
    height: 480
    title: "QT + Elm Spreadsheet!"

    Component.onCompleted: {
        console.log("=====================================================");
        console.log("This is JavaScript inside the C++/QML QT application!");
        console.log("JavaScript you say? That means it can run Elm!");
        console.log("----------------------------------------------");
        const elmApp = Elm.initElmApp().Main.init();
        elmApp.ports.elmToQML.subscribe((value) => {
            console.log("----------------------------------------------");
            console.log(`Got message from Elm! ${JSON.stringify(value)}`);
            switch (value.tag) {
               case 'JustStarted':
                   console.log('Elm just told QML that it started! \\o/');
                   elmApp.ports.qmlToElm.send({tag: 'hi to Elm from QML', someData: 42});
                   break;
               case 'Echo':
                   console.log('Elm echoed our Msg!');
                   break;
               default:
                   console.log(`Unknown Elm message to QML! ${value.tag}`);
            }
        });
    }

    Grid {
        id: grid
        x: 0
        y: 0
        width: 640
        height: 480
        rows: 4
        columns: 3

        Timer {
            id: removeGridItemTimer
            interval: 1000
            repeat: true
            // no onTriggered: this will happen in Grid.onCompleted
        }

        Rectangle { color: "red"; width: 50; height: 50 }
        Rectangle { color: "green"; width: 20; height: 50 }
        Rectangle { color: "blue"; width: 50; height: 20 }
        Rectangle { color: "cyan"; width: 50; height: 50 }
        Rectangle { color: "magenta"; width: 10; height: 10 }

        Component.onCompleted: {
            console.log("-------------------------------------------------------------------------------");
            console.log("Grid has finished initializing, let's start removing items in a sec (literally)");
            console.log("This is outside the Elm<->QML experiment, and only serves to prove we can change the contents of the widgets from JavaScript.");
            console.log("We'll likely need to make some kind of VDom for QT?");

            let i = grid.children.length - 1;
            removeGridItemTimer.triggered.connect(() => {
                console.log(`--------------- destroying: ${i}`);
                grid.children[i].destroy();
                if (i === 0) {
                    removeGridItemTimer.stop();
                }
                i--;
            })
            removeGridItemTimer.start();

        }
    }
}
