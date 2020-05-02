import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    id: mainwindow
    visible: true
    width: 640
    height: 480
    title: qsTr("QT + Elm Spreadsheet!")

    Component.onCompleted: {
        console.log("This is JavaScript!");
    }

    Grid {
        id: grid
        x: 0
        y: 0
        width: 640
        height: 480
        rows: 4
        columns: 3

        Rectangle { color: "red"; width: 50; height: 50 }
        Rectangle { color: "green"; width: 20; height: 50 }
        Rectangle { color: "blue"; width: 50; height: 20 }
        Rectangle { color: "cyan"; width: 50; height: 50 }
        Rectangle { color: "magenta"; width: 10; height: 10 }

        Component.onCompleted: {
            console.log("Grid has finished initializing, let's start removing items");

            function Timer() {
                return Qt.createQmlObject("import QtQuick 2.0; Timer {}", mainwindow);
            }

            const timer = new Timer();
            let i = grid.children.length - 1;
            timer.interval = 1000;
            timer.repeat = true;
            timer.triggered.connect(() => {
                console.log(`destroying: ${i}`);
                grid.children[i].destroy();
                if (i === 0) {
                    timer.stop();
                }
                i--;
            })
            timer.start();

        }
    }
}
