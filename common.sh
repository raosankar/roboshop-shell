color="\e[36m"
nocolor="\e[0m"
log_file="/tmp/roboshop.log"
app_path="/app"

user_id=$(id -u)
if [ $user_id -ne 0 ]; then
      echo Script Should Be Running With Sudo
      exit 1
fi

stat_check(){
  if [ $1 -eq 0 ]; then
      echo SUCCESS
  else
      echo FAILURE
  fi
}
app_presetup(){
  echo -e "${color} Add Application User ${nocolor}"

  id roboshop &>>${log_file}
  if [ $? -eq 1 ]; then
    useradd roboshop &>>${log_file}
  fi

  stat_check $?

  echo -e "${color} Create Application Directory ${nocolor}"
  rm -rf ${app_path} &>>${log_file}
  mkdir ${app_path} &>>${log_file}

  stat_check $?

  echo -e "${color} Downloading Application Content ${nocolor}"
  curl -o /tmp/$component.zip https://roboshop-artifacts.s3.amazonaws.com/$component.zip &>>${log_file}

  stat_check $?

  cd ${app_path} &>>${log_file}

  echo -e "${color} Extract Application Content ${nocolor}"
  unzip /tmp/$component.zip &>>${log_file}

  stat_check $?
}

systemd_setup(){
    echo -e "${color} Setup SystemD Service ${nocolor}"
    cp /home/centos/roboshop-shell/$component.service /etc/systemd/system/$component.service &>>${log_file}
    stat_check $?

    sed -i -e "s/roboshop_app_password/$roboshop_app_password" /etc/systemd/system/$component.service
    stat_check $?

    if [ $component == cart ]; then
    echo -e "${color} Start $component Daemon Service ${nocolor}"
    systemctl daemon-reload &>>${log_file}
    else
      echo Failure To Load Daemon Service
    fi

    echo -e "${color} Start $component Service ${nocolor}"
    systemctl enable $component &>>${log_file}
    systemctl restart $component &>>${log_file}
    stat_check $?
}


nodejs(){
  echo -e "${color} Configuring NodeJS Repos ${nocolor}"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log_file}
  stat_check $?
  echo -e "${color} Install NodeJS ${nocolor}"
  yum install nodejs -y &>>${log_file}
  stat_check $?
  app_presetup

  echo -e "${color} Install NodeJS Dependencies ${nocolor}"
  npm install &>>${log_file}
  stat_check $?
  systemd_setup
}

mongo_schema_setup(){
  echo -e "${color} Copy MongoDB Repo File ${nocolor}"
  cp /home/centos/roboshop-shell/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${log_file}
  stat_check $?

  echo -e "${color} Installing MongoDB Client ${nocolor}"
  yum install mongodb-org-shell -y &>>${log_file}
  stat_check $?

  echo -e "${color} Load Schema ${nocolor}"
  mongo --host mongodb-dev.devopsbrs73.store <${app_path}/schema/$component.js &>>${log_file}
  stat_check $?
}

mysql_schema_setup(){
     echo -e " ${color} Install MySql Client  ${nocolor} "
     yum install mysql -y &>>${log_file}
     stat_check $?

     echo -e " ${color} Load Schema  ${nocolor} "
     mysql -h mongodb-dev.devopsbrs73.store -uroot -pRoboShop@1 < ${app_path}/schema/$component.sql &>>${log_file}
     stat_check $?
}

maven(){
   echo -e " ${color} Install Maven  ${nocolor} "
   yum install maven -y &>>${log_file}
   stat_check $?
   app_presetup

   echo -e " ${color} Download Maven Dependencies  ${nocolor} "
   mvn clean package &>>${log_file}
   stat_check $?
   mv target/$component-1.0.jar $component.jar &>>${log_file}
   stat_check $?
   mysql_schema_setup

   systemd_setup

}

python(){
  echo -e " ${color} Install $component  ${nocolor}"
  yum install python36 gcc python3-devel -y &>>${log_file}

  stat_check $?

  app_presetup

  echo -e " ${color} Install Application Dependencies  ${nocolor}"
  cd ${app_path} &>>${log_file}
  pip3.6 install -r requirements.txt &>>${log_file}

  stat_check $?

  systemd_setup
}