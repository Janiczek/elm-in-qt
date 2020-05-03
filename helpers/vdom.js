/**************************
 ********* STATE **********
 **************************/

// TODO unclear if we even need this. Right now it's just for convenience:
let nodeId = 0;

/**************************
 ******* PUBLIC API *******
 **************************/

function create(element, parent) {
    console.log('creating Elm-controlled view in QT');
    _createElement(element, parent);
}

/* TODO it's unclear whether we'll need this function at all
   later when we implement the actuall patching
*/
function clear(parent) {
    console.log('clearing the whole Elm-controlled view');
    for (let i = 0; i < parent.data.length; i++) {
        parent.data[i].destroy();
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

function _createQmlString(node) {
    const preamble = 'import QtQuick 2.14';

    const attrs = Object.keys(node.attrs)
                        .map(key => `${key}: ${JSON.stringify(node.attrs[key])}`)
                        .join('; ');

    return `${preamble}; ${node.tag} { ${attrs} }`;
}

function _createNodeName(tag) {
    const id = nodeId;
    nodeId++;
    return `${tag}#${id}`;
}

function _createNode(node, parent) {
    const object = Qt.createQmlObject(
        _createQmlString(node),
        parent,
        _createNodeName(node.tag)
    );

    node.children.forEach(child => {
        _createElement(child, object);
    });
}
