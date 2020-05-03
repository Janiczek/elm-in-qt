/**************************
 ********* STATE **********
 **************************/

let nodeId = 0;

/**************************
 ******* PUBLIC API *******
 **************************/

function create(element, parent) {
    _createElement(element, parent);
}



/**************************
 ********* PATCH **********
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

function _setProp(target, name, value) { //@

}

function _setProps(target, props) {

}

function _removeProp(target, name, value) { //@

}

function _patchProps(parent, patches) {

}

function _patch(parent, patches, index = 0) { //@

}
