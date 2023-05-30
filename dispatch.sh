source common.sh
component=dispatch
echo -e "${color} Install Golang  ${nocolor}"
yum install golang -y &>>${log_file}

app_presetup

echo -e "${color} Install Golang Dependencies  ${nocolor}"
go mod init $component &>>${log_file}
go get &>>${log_file}
go build &>>${log_file}

systemd_setup