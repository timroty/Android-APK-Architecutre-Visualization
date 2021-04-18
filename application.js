// Include the fs module
var fs = require('fs');
var xmlParser = require('xml-js');
var xml2js = require('xml2js');

const dir = './Messenger.xml'
let middleObject = {};
const path = './ArchStudioXML.xml'

let outputObject = {
	"xadlcore_3_0:xADL": {
		"structure_3_0:structure": {
			"structure_3_0:component": [],
            "structure_3_0:link":[],
            attr:{
                "structure_3_0:id":"structure1",
                "structure_3_0:name":"Program_Structure"
            }
        },
        attr: {
            "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
            "xmlns:hints_3_0": "http://www.archstudio.org/xadl3/schemas/hints-3.0.xsd",
            "xmlns:structure_3_0": "http://www.archstudio.org/xadl3/schemas/structure-3.0.xsd",
            "xmlns:xadlcore_3_0": "http://www.archstudio.org/xadl3/schemas/xadlcore-3.0.xsd",
        }
       
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

async function buildArchStudioFile() {
    return new Promise((resolve, reject) => {

        var builder = new xml2js.Builder({attrkey: "attr"});
        var xml = builder.buildObject(outputObject); 

        resolve(
            fs.writeFile(path, xml, function(error) {
                if (error) {
                    reject(error);
                }
            }));
    }).catch(error => {
        console.log(error)
    });
}

async function buildArchStudioObject() {

    var keys = Object.keys(middleObject.components);

    for (let i in keys) {
        
        let tempComponent = {
            "structure_3_0:interface": [],

            "structure_3_0:ext" : {
                "hints_3_0:hint" : {
                    attr : {
                        "_hints_3_0:hint": "org.eclipse.swt.graphics.Rectangle:" + middleObject.components[keys[i]].x_coord + "," + middleObject.components[keys[i]].y_coord + "," + middleObject.components[keys[i]].width + "," + middleObject.components[keys[i]].height,
                        "_hints_3_0:name": "bounds",
                    }
                },
                "hints_3_0:hint" : {
                    attr : {
                        "hints_3_0:hint": "org.eclipse.swt.graphics.RGB:197,203,245",
                        "hints_3_0:name": "color",
                    }
                },
                attr : {
                    "xsi:type":"hints_3_0:HintsExtension"
                }
            },
            attr : {
                'structure_3_0:id': middleObject.components[keys[i]].id,
                'structure_3_0:name': middleObject.components[keys[i]].name
            }
        }


        for (let j = 0; j < middleObject.components[keys[i]].interface.length; j++) {
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
                "structure_3_0:ext": {
                    "hints_3_0:hint": {
                        attr : {
                            "hints_3_0:hint": "java.awt.geom.Point2D:1," + x + "," + y,
                            "hints_3_0:name": "location"
                        },
                    },
                    attr :{
                        "xsi:type": "hints_3_0:HintsExtension"
                    }
                },
                attr : {
                    "structure_3_0:direction": middleObject.components[keys[i]].interface[j].direction,
                    "structure_3_0:id": middleObject.components[keys[i]].interface[j].id,
                    "structure_3_0:name": "[New Interface]",
                }
            }

            tempComponent["structure_3_0:interface"].push(interfaceObject)
        }

        outputObject["xadlcore_3_0:xADL"]["structure_3_0:structure"]["structure_3_0:component"].push(tempComponent)
    }	
    
    for(let i = 0; i < middleObject.links.length; i ++){
        let linkObject = { 
            "structure_3_0:point1": middleObject.links[i].interface1,
            "structure_3_0:point2": middleObject.links[i].interface2,
            attr :{
                "structure_3_0:id": middleObject.links[i].id,
                "structure_3_0:name": "[New Link]",
            }
        }
        outputObject["xadlcore_3_0:xADL"]["structure_3_0:structure"]["structure_3_0:link"].push(linkObject)
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
    const NUM_WIDE = Math.ceil(jsonComponents.length);

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

    buildArchStudioFile();

}

main();

