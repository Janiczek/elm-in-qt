/**************************
 ******* PUBLIC API *******
 **************************/

function create(element, root) {
    _createElement(element, root);
}

/* TODO it's unclear whether we'll need this function at all
   later when we implement the actuall patching
*/
function clear(root) {
    for (let i = 0; i < root.data.length; i++) {
        root.data[i].destroy();
    }
}

/**************************
 ********* CREATE **********
 **************************/

function _createElement(element, parent) {
    switch (element.type) {
        case 'empty': return;
        case 'node': _createNode(element, parent);
    }
}

function _createJsSignalCode(signalName, eventId) {
    // TODO mainwindow ... abstract it somehow
    return `mainwindow.elm.ports.qtToElm.send({ tag: 'EventEmitted', eventId: ${eventId} });`;
}

function _createQmlPropValueCode(propValue) {
    return propValue.rawValue
        ? propValue.rawValue
        : JSON.stringify(propValue);
}

function _createQmlCode(node) {
    // TODO different preamble for different node tags
    // TODO are all of these needed? which when?
    const preamble = "import QtQuick 2.14; import QtQuick.Controls 2.14; import QtQuick.Layouts 1.14";

    const props = Object.keys(node.props)
                        .map(key => `${key}: ${_createQmlPropValueCode(node.props[key])}`)
                        .join('; ');

    const signals = Object.keys(node.signals)
                          .map(key => `on${key}: { ${_createJsSignalCode(key, node.signals[key])} }`)
                          .join('; ');

    const content = [props, signals].filter(x => x !== '')
                                    .join('; ');

    return `${preamble}; ${node.tag} { ${content} }`;
}

function _createNode(node, parent) {
    const object = Qt.createQmlObject(
        _createQmlCode(node),
        parent,
        node.tag
    );

    node.children.forEach(child => {
        _createElement(child, object);
    });
}
