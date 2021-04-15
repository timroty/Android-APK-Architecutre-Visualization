// Include the fs module
var fs = require('fs');
var xmlParser = require('xml-js');

const dir = './Messenger.xml'
let middleObject = {};

async function readCovertFile() {
    return new Promise((resolve,reject) => {
        let covertFile = undefined;

        fs.readFile(dir, 'utf8', function (error, data){
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

async function parseCovertFile() {
    const json = await readCovertFile();

    const jsonElements = json["elements"][0]["elements"]
    const jsonComponents = jsonElements[1]["elements"]
    const jsonIntents = jsonElements[2]["elements"]

    middleObject.components = [];
    middleObject.links = [];

    let componentNum = 1;
    jsonComponents.forEach(element => {
        
        let name = element["elements"][1]["elements"][0]["text"]
        let type = element["elements"][0]["elements"][0]["text"]
        let id = "componentId" + componentNum;

        var component = {
            "name" : name,
            "type" : type,
            "id" : id
        }

        middleObject.components[name] = component
        middleObject.components[name].interface = [];

        componentNum ++;
    });

    let interfaceNum = 1;
    jsonIntents.forEach(element => {

        let sender = element["elements"][1]["elements"][0]["text"]
        let component = element["elements"][2]["elements"][0]["text"]

        let senderInterfaceId = "interfaceOut" + interfaceNum;
        let componentInterfaceId = "interfaceIn" + interfaceNum;
        let linkId = "linkId" + interfaceNum;

        var sendInterface = {
            direction : "out",
            id : senderInterfaceId
        }

        var componentInterface = {
            direction : "in",
            id : componentInterfaceId
        }

        var linkInformation = {
            id : linkId,
            interface1 : senderInterfaceId,
            interface2 : componentInterfaceId
        }

        middleObject.components[sender].interface.push(sendInterface);
        middleObject.components[component].interface.push(componentInterface);

        middleObject.links.push(linkInformation);

        interfaceNum ++;
        
    });
}

async function main() {
    await parseCovertFile();
    
    var keys = Object.keys(middleObject.components);

    // for(let i in keys){
    //     console.log(middleObject.components[keys[i]])
    // }

    // console.log(middleObject)

}

main();

  

