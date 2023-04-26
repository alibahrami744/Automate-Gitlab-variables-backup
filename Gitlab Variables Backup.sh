#!/bin/bash

#backup all gitlab repositories variables backup
mkdir /root/gitlab_var_backup/archive/Gitlab_project_variables

curl --header "PRIVATE-TOKEN: PRIVATE_TOKEN" "https://gitlab.test.com/api/v4/projects?per_page=100" | json_pp | grep -e "^      \"id\" : " | grep -Eo '[0-9]{1,4}' > /root/gitlab_var_backup/archive/Gitlab_project_variables/All_projects_id
for i in `cat /root/gitlab_var_backup/archive/Gitlab_project_variables/All_projects_id`;
do
	curl --header "PRIVATE-TOKEN: PRIVATE_TOKEN" "https://gitlab.test.com/api/v4/projects/$i/variables/" | json_pp | yq e -P - > /root/gitlab_var_backup/archive/Gitlab_project_variables/Project_id_$i.yaml
done
#local backup
zip -P SECRET_KEY -r /root/gitlab_var_backup/archive/Gitlab_project_variables-$(date +"%b-%d-%Y").zip /root/gitlab_var_backup/archive/Gitlab_project_variables/
#backup at NFS (/mnt)
zip -P SECRET_KEY -r /mnt/ngmi-backup/preprod/gitlab/variables/Gitlab_project_variables-$(date +"%b-%d-%Y").zip /root/gitlab_var_backup/archive/Gitlab_project_variables/
rm -rf /root/gitlab_var_backup/archive/Gitlab_project_variables/

#backup all gitlab admin variables backup

mkdir /root/gitlab_var_backup/archive/Gitlab_admin_variables

curl --header "PRIVATE-TOKEN: PRIVATE_TOKEN" "https://gitlab.test.com/api/v4/admin/ci/variables?per_page=100" | json_pp | yq e -P - > /root/gitlab_var_backup/archive/Gitlab_admin_variables/ngmy-gitlab-admin-vars-$(date +"%b-%d-%Y").yaml
#local backup
zip -P SECRET_KEY -r /root/gitlab_var_backup/archive/Gitlab_admin_variables-$(date +"%b-%d-%Y").zip /root/gitlab_var_backup/archive/Gitlab_admin_variables/
#backup at NFS (/mnt)
zip -P SECRET_KEY -r /mnt/ngmi-backup/preprod/gitlab/variables/Gitlab_admin_variables-$(date +"%b-%d-%Y").zip /root/gitlab_var_backup/archive/Gitlab_admin_variables/
rm -rf /root/gitlab_var_backup/archive/Gitlab_admin_variables
