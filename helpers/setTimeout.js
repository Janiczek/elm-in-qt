const timerComponent = Qt.createComponent(Qt.resolvedUrl('Timeout.qml'))

const TIMEOUT_IMMEDIATELY = 0

let lastId = 0;
const timers = {};

function setTimeout(callback, timeout = 0) {
    const timer = timerComponent.createObject()

    timer.interval = timeout || TIMEOUT_IMMEDIATELY

    timer.triggered.connect(() => {
        timer.destroy()
        callback()
    })

    timer.start()

    lastId++;
    timers[lastId] = timer;
    return lastId;
}

function clearTimeout(id) {
    timers[id].stop();
    timers[id].destroy();
    delete timers[id];
}
