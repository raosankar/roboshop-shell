source common.sh
component=frontend
echo -e "${color} Installing Nginx Server ${nocolor} "
yum install nginx -y &>>${log_file}
stat_check $?

echo -e "${color} Removing Old App Content ${nocolor} "
rm -rf /usr/share/nginx/html/* &>>${log_file}
stat_check $?

echo -e "${color} Downloading  $component  Content ${nocolor} "
curl -o /tmp/$component.zip https://roboshop-artifacts.s3.amazonaws.com/$component.zip &>>${log_file}
stat_check $?

echo -e "${color} Extracting $component  Content ${nocolor} "
cd /usr/share/nginx/html &>>${log_file}
unzip /tmp/$component.zip &>>${log_file}
stat_check $?

echo -e "${color} Copy  $component  Conf File ${nocolor} "
cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>>${log_file}
stat_check $?

echo -e "${color} Starting Nginx Server ${nocolor} "
systemctl enable nginx &>>${log_file}
systemctl restart nginx &>>${log_file}
stat_check $?