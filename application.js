// Include the fs module
var fs = require('fs');
var xmlParser = require('xml-js');

  
const dir = './Messenger.xml'

async function parseCovertFile() {
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

async function readCovertFile() {
    const json = await parseCovertFile();
    console.log(json);
}

readCovertFile();

  

