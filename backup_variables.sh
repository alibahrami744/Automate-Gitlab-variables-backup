#!/bin/bash

#Access token from Gitlab to get data using API
GITLAB_ACCESS_TOKEN=""

#Gitlab URL, Example: https://gitlab.testing.com
GITLAB_URL=""

#A directory to get all data and other actions, Example: /root/Gitlab-Backup-Variables
BACKUP_DIR=""

#A password to set on zip files just for security of the backup
ZIP_FILE_PASSWORD=""

######################################
mkdir $BACKUP_DIR
#Get all projects ID which is required for the API calls
curl --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" "$GITLAB_URL/api/v4/projects?per_page=100" | json_pp | grep -e "^      \"id\" : " | grep -Eo '[0-9]{1,4}' > $BACKUP_DIR/All_projects_id
#Get all variables in each gitlab's projects as json format
for i in `cat $BACKUP_DIR/All_projects_id`;
do
	curl --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" "$GITLAB_URL/api/v4/projects/$i/variables/" | json_pp | yq e -P - > $BACKUP_DIR/Project_id_$i.yaml
done
#Compress all the files and set a password for the zip file
zip -P $ZIP_FILE_PASSWORD -r $BACKUP_DIR-$(date +"%b-%d-%Y").zip $BACKUP_DIR/
#Delete all the created folders
rm -rf $BACKUP_DIR/
######################################
#Admin variables are separated from the projects
mkdir $BACKUP_DIR/admin_vars
#Get admin variables as json format into a file
curl --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" "$GITLAB_URL/api/v4/admin/ci/variables?per_page=100" | json_pp | yq e -P - > $BACKUP_DIR/admin_vars/Admin_variables-$(date +"%b-%d-%Y").json
#Compress the file and set a password for the zip file
zip -P $ZIP_FILE_PASSWORD -r $BACKUP_DIR/admin_vars-$(date +"%b-%d-%Y").zip $BACKUP_DIR/admin_vars/
#Delete all the created folders
rm -rf $BACKUP_DIR/admin_vars
