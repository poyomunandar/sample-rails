This small application will do these:
1. Merge all js file under www\components per folder (each folder will only have one merged js file) and remove files that have been merged before
2. Modify the index.html in www. It will remove all obsolote links to js file that has been removed before and replace it with the links to the merged js file

Prerequisite: java 8, nodejs, webpack (using this command to install: 'npm install webpack -g')
Steps (windows):
1. Open command console
2. Change directory to the jar location (webpack.jar)
3. Run this: java -jar webpack.jar <base folder> <full path of webpack executable>
	<base folder> is the root folder of the MF8 application, example: C:\\apkcontest
	<full path of webpack executable> is the full path of the executable webpack. In windows, the file should be webpack.cmd. example: C:\\Users\\Prudential\\AppData\\Roaming\\npm\\webpack.cmd
	
Notes:
- In case the js load mechanism is changed, then this application is no longer valid since it assumes that all js will be loaded in index.html in www