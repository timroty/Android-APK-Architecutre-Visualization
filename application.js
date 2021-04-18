// Include the fs module
var fs = require('fs');
var xmlParser = require('xml-js');

const dir = './Messenger.xml'
let middleObject = {};

let outputObject = {
    xADL: {
        structure: {
            component: []
        },
        "_xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
        "_xmlns:hints_3_0": "http://www.archstudio.org/xadl3/schemas/hints-3.0.xsd",
        "_xmlns:structure_3_0": "http://www.archstudio.org/xadl3/schemas/structure-3.0.xsd",
        "_xmlns:xadlcore_3_0": "http://www.archstudio.org/xadl3/schemas/xadlcore-3.0.xsd",
        "__prefix": "xadlcore_3_0"
    }
}



async function readCovertFile() {
    return new Promise((resolve, reject) => {
        let covertFile = undefined;

        fs.readFile(dir, 'utf8', function(error, data) {
            if (error) {
                reject(error);
            }
            covertFile = data;

            resolve(xmlParser.xml2js(covertFile));
        });
    }).catch(error => {
        console.log(error)
    });
}

async function buildArchStudioObject() {

    var keys = Object.keys(middleObject.components);

    for (let i in keys) {

        let tempComponent = {
            "interface": [],
            "ext": {
                "hint": [{
                        "_hints_3_0:hint": "org.eclipse.swt.graphics.Rectangle:" + middleObject.components[keys[i]].x_coord + "," + middleObject.components[keys[i]].y_coord + "," + middleObject.components[keys[i]].width + "," + middleObject.components[keys[i]].height,
                        "_hints_3_0:name": "bounds",
                        "__prefix": "hints_3_0"
                    },
                    {
                        "_hints_3_0:hint": "org.eclipse.swt.graphics.RGB:197,203,245",
                        "_hints_3_0:name": "color",
                        "__prefix": "hints_3_0"
                    }
                ],
                "_xsi:type": "hints_3_0:HintsExtension",
                "__prefix": "structure_3_0"
            },
            '__prefix': "structure_3_0",
            '_structure_3_0:id': middleObject.components[keys[i]].id,
            '_structure_3_0:name': middleObject.components[keys[i]].name,
        }

        for (let j = 0; j < middleObject.components[keys[i]].interface.length; j++) {
            // TODO CHANGE THE JS POINT 2D

            let x = 0;
            let y = 0;

            // set coordinates for in and out interfaces
            if (middleObject.components[keys[i]].interface[j].direction == 'in') {

                x = 0;
                y = 0;

            } else if (middleObject.components[keys[i]].interface[j].direction == 'out') {

                x = 4651444358887768064;
                y = 4651444358887768064;

            }

            let interfaceObject = {
                "ext": {
                    "hint": {
                        "_hints_3_0:hint": "java.awt.geom.Point2D:1," + x + "," + y,
                        "_hints_3_0:name": "location",
                        "__prefix": "hints_3_0"
                    },
                    "_xsi:type": "hints_3_0:HintsExtension",
                    "__prefix": "structure_3_0"
                },
                "_structure_3_0:direction": middleObject.components[keys[i]].interface[j].direction,
                "_structure_3_0:id": middleObject.components[keys[i]].interface[j].id,
                "_structure_3_0:name": "[New Interface]",
                "__prefix": "structure_3_0"
            }

            tempComponent.interface.push(interfaceObject)
        }

        outputObject.xADL.structure.component.push(tempComponent)
    }
}

async function parseCovertFile() {
    const json = await readCovertFile();

    const jsonElements = json["elements"][0]["elements"]
    const jsonComponents = jsonElements[1]["elements"]
    const jsonIntents = jsonElements[2]["elements"]

    middleObject.components = [];
    middleObject.links = [];

    const HEIGHT = 80;
    const WIDTH = 100;
    const OFFSET = 25;
    const NUM_WIDE = 4;

    let componentNum = 1;
    jsonComponents.forEach(element => {

        let name = element["elements"][1]["elements"][0]["text"]
        let type = element["elements"][0]["elements"][0]["text"]
        let id = "componentId" + componentNum;

        let x = ((componentNum * WIDTH) + (componentNum * OFFSET)) % ((WIDTH + OFFSET) * NUM_WIDE);
        let y = (HEIGHT + OFFSET) * Math.floor(componentNum / NUM_WIDE);

        var component = {
            "name": name,
            "type": type,
            "id": id,
            "x_coord": x,
            "y_coord": y,
            "height": HEIGHT,
            "width": WIDTH
        }

        middleObject.components[name] = component
        middleObject.components[name].interface = [];

        componentNum++;
    });

    let interfaceNum = 1;
    jsonIntents.forEach(element => {

        let sender = element["elements"][1]["elements"][0]["text"]
        let component = element["elements"][2]["elements"][0]["text"]

        let senderInterfaceId = "interfaceOut" + interfaceNum;
        let componentInterfaceId = "interfaceIn" + interfaceNum;
        let linkId = "linkId" + interfaceNum;

        var sendInterface = {
            direction: "out",
            id: senderInterfaceId
        }

        var componentInterface = {
            direction: "in",
            id: componentInterfaceId
        }

        var linkInformation = {
            id: linkId,
            interface1: senderInterfaceId,
            interface2: componentInterfaceId
        }

        middleObject.components[sender].interface.push(sendInterface);
        middleObject.components[component].interface.push(componentInterface);

        middleObject.links.push(linkInformation);

        interfaceNum++;

    });
}

async function main() {
    await parseCovertFile();

    buildArchStudioObject();

    //ar keys = Object.keys(middleObject.components);

    // for(let i in keys){
    //     console.log(middleObject.components[keys[i]])
    // }

    //console.log(middleObject)

}

main();