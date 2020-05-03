/**************************
 ********* STATE **********
 **************************/

let nodeId = 0; // TODO unclear if we even need this. Right now it's just for convenience:

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

function _createQmlCode(node) {
    // TODO different preamble for different node tags
    // TODO are all of these needed? which when?
    const preamble = "import QtQuick 2.14; import QtQuick.Controls 2.14; import 'virtual-qml.js' as VirtualQML";

    const props = Object.keys(node.props)
                        .map(key => `${key}: ${JSON.stringify(node.props[key])}`)
                        .join('; ');

    const signals = Object.keys(node.signals)
                          .map(key => `on${key}: { ${_createJsSignalCode(key, node.signals[key])} }`)
                          .join('; ');

    const content = [props, signals].filter(x => x !== '')
                                    .join('; ');

    return `${preamble}; ${node.tag} { ${content} }`;
}

function _createNodeName(tag) {
    const id = nodeId;
    nodeId++;
    return `${tag}#${id}`;
}

function _createNode(node, parent) {
    const object = Qt.createQmlObject(
        _createQmlCode(node),
        parent,
        _createNodeName(node.tag)
    );

    node.children.forEach(child => {
        _createElement(child, object);
    });
}
