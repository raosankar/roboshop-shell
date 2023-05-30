source common.sh

echo -e "${color} Disable MySql Version ${nocolor}"
yum module disable mysql -y &>>${log_file}
stat_check $?

echo -e "${color} Copy MySql Repo File  ${nocolor}"
cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>>${log_file}
stat_check $?

echo -e "${color} Install MySql Community Server ${nocolor}"
yum install mysql-community-server -y &>>${log_file}
stat_check $?

echo -e "${color} Start MySQl Service ${nocolor}"
systemctl enable mysqld &>>${log_file}
systemctl restart mysqld &>>${log_file}
stat_check $?

echo -e "${color} SetUp MySql Password ${nocolor}"
mysql_secure_installation --set-root-pass $1 &>>${log_file}
stat_check $?