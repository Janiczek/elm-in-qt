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

    Timer {
        id: removeGridItemTimer
        interval: 1000
        repeat: true
        // no onTriggered: this will happen in Grid.onCompleted
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

            let i = grid.children.length - 1;
            removeGridItemTimer.triggered.connect(() => {
                console.log(`destroying: ${i}`);
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
