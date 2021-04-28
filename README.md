# Software Design and Architecture Final Project
 
The folder contains all of the deliverables for Team 3's Software Design and Architecture Final Project. The team consists of Tim Roty, Ian Anderson, Austin Collins, Rachel Nordgren, and Laura Derowitsch.
 
## Submission Details
 
The following are the included files within the submission and their formats.
 
- Sample Covert Output Data : Sample data from the Covert's analysis models that represent the input data for the program.
   - Messenger.xml : XML File
   - weather.xml : XML File
- Sample Android APK Data : Sample data used to run a Covert analysis with.
   - Messenger.apk : APK File
   - weather.apk : APK File 
- application.js : JavaScript File : Contains all the code for the program.
- package.json : JSON File : The NPM packages needed to run the program.
- ArchStudioXML.xml : XML File : A sample output from running the program. This file is overwritten each time the program is run and represents the output of the program.
- Covert : The application used to parse Android APK files and produce the models needed for the application.
 
 
## Program Compilation and Execution
 
The entire pipeline from Android APK to an ArchStudio compatible file requires running a Covert analysis as well as the created application. Neither portion of the pipeline requires compiling. Covert contains precompiled Java binaries and our application is written in JavaScript, which when run with Node, is not required to be compiled before executing.
 
### Running Covert
Covert is not compatible with Java versions 9 or newer, and requires a version of Java 8 to be installed and set as the default version. Currently, the team runs Covert with Java version "1.8.0_281".
 
Before executing Covert, there is some setup that must be completed. First, select which Android APK should be analyzed with Covert. The team has provided two in the "Sample Android APK Data” folder. Next, place all Android APK files that will be analyzed in the demo folder, located at `covert/app_repo/demo`. Once the APK files have been placed in the folder, the Covert analysis can be run. 
 
Covert is run from the command line. In the command line, navigate inside Covert folder. Next, run the following command: `./covert.sh demo`. This will kick off a series of steps that analyzes the Android APKs.
 
To run another Covert analysis, simply remove all the files in the demo folder and place in new Android APK files.
 
More information regarding covert can be found at the following site: https://seal.ics.uci.edu/projects/covert/
 
### Running The Application
The application requires Node to be installed as well as NPM. The application runs on the UNL CSE server on its current version of Node, v8.17.0 and its current version of NPM, 6.13.4.
 
The application is also run from the command line and requires one command line argument, the file path a covert analysis model. The Covert models that resulted from running Covert on the Android APK files can be found at `covert/app_repo/demo/analysis/model`. For the easiest experience, the team copy and pasted those files into the main folder for easier file path specification when testing. If the application is run without specifying a file path, it will exit. If the file path is invalid or the path leads to a file that is not the specified model type, the program will not work properly.
 
The application can be run by the following command: `node ./application.js filePath`. Using the Messenger.apk as an example, the model, named Messenger.xml, would be ran by calling `node ./application.js Messenger.xml`, assuming the model had been copied to the same location as the application.
 
Once the application completes, it will give a prompt confirming the successful output. The application creates a file called "ArchStudioXML.xml" at the same location as the application. This file can then be copied and pasted into an ArchStudio project.
 
### Running ArchStudio
For testing purposes, the team runs ArchStudio on Java version "1.8.0_171", but ArchStudio is more flexible with Java versions. It is also run on Eclipse 4.8. In Eclipse, create a new project. After, drag and drop the "ArchStudioXML.xml" output file from the application into the project. Finally, right click the newly added file and open it with Archipelago v2.0. From there, one is able to double click the program structure and see the Android APK's architecture.
 
## Limitations or Problems
 
The application relies on Covert correctly parsing the Android APK files with no issues. If Covert is not able to parse and APK or cannot create models within the model folder, then the application will not work.
 
Covert is also space intensive, especially on a limited storage resource server like the CSE server. If Covert is too large for the allocated space on the CSE server, either the individual must request more memory or run Covert locally. We have included two example Covert analysis models in the deliverable in case this problem presents an issue.
 
## Dependencies Required
 
The only dependencies required are the NPM packages for the program. These can be installed by running `npm install` in the main folder of the deliverables, where the package.json is located.
