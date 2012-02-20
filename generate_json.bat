@ECHO OFF
SET ROOT_PATH=%~dp0
SET ROOT_PATH=%ROOT_PATH:\=/%


rem %1 is the name of the cookbook for which we want to generate the metadata.json file
knife cookbook metadata %1 -o %ROOT_PATH%/cookbooks