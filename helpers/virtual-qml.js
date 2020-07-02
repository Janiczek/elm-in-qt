/**************************
 ******* PUBLIC API *******
 **************************/

function applyPatch(patch, element) {
    switch (patch.type) {
        case 'NoOp': break;
        case 'Create': _create(patch.element, element); break;
        case 'Remove': _remove(element); break;
        case 'ReplaceWith': _replaceWith(patch.element, element); break;
        case 'Update': _update(patch.attrs, patch.children, element); break;
        case 'SetAttr': _setAttr(patch.name, patch.attr, element); break;
        case 'RemoveAttr': _removeAttr(patch.name, element); break;
        default: throw `Patch type ${patch.type} not implemented!`;
    }
}

/**************************
 ********* CREATE **********
 **************************/

function _create(element, parent) {
    switch (element.type) {
        case 'empty': return;
        case 'node': _createNode(element, parent);
    }
}

function _createJsSignalCode(eventId) {
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
                        .join('\n');

    const signals = Object.keys(node.signals)
                          .map(key => `on${key}: { ${_createJsSignalCode(node.signals[key])} }`)
                          .join('\n');

    const content = [props, signals].filter(x => x !== '')
                                    .join('\n');

    return `${preamble}\n${node.tag} {\n${content}\n}`;
}

function _createNode(node, parent) {
    const object = Qt.createQmlObject(
        _createQmlCode(node),
        parent,
        node.tag
    );

    // TODO maybe don't create recursively but all in one go?
    node.children.forEach(child => {
        _create(child, object);
    });
}

/**************************
 ******** REMOVE **********
 **************************/

function _remove(element) {
    element.destroy();
}

/**************************
 ****** REPLACE WITH ******
 **************************/

function _replaceWith(newElement, oldElement) {
    const parent = oldElement.parent;
    _remove(oldElement);
    _create(newElement, parent);
}

/**************************
 ******** UPDATE **********
 **************************/

function _update(attrs, children, element) {
    _updateAttrs(attrs, element);
    _updateChildren(children, element);
}

function _updateAttrs(attrs, element) {
    attrs.forEach(patch => {
        applyPatch(patch, element);
    });
}

function _updateChildren(children, element) {
    children.forEach((patch, i) => {
        applyPatch(patch, element.data[i]);
    });
}

/**************************
 ******** SET ATTR ********
 **************************/

function _setAttr(name, attr, element) {
    switch (attr.type) {
        case 'Property':
            element[name] = attr.qmlValue;
            break;
        case 'EventHandler':
            throw 'SetAttr(EventHandler) not implemented yet'; // TODO
        default:
            throw `Unknown attribute type: ${attr.type}`;
    }
}

/**************************
 ****** REMOVE ATTR *******
 **************************/

function _removeAttr(name, element) {
    console.log("DIDN'T TEST THIS YET!!!!!");
    console.log(`remove attr ${name}`);
    console.log(`current value: ${element[name]}`);
    delete element[name];
}
