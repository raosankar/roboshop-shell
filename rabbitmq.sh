source common.sh

echo -e "${color} Configure Errlang Repos  ${nocolor}"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>/tmp/roboshop.log

echo -e "${color} Configure RabbisMQ Repos  ${nocolor}"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>/tmp/roboshop.log

echo -e "${color} Install RabbisMQ Server  ${nocolor}"
yum install rabbitmq-server -y &>>/tmp/roboshop.log

echo -e "${color} Start RabbitMQ Service  ${nocolor}"
systemctl enable rabbitmq-server &>>/tmp/roboshop.log
systemctl start rabbitmq-server &>>/tmp/roboshop.log

echo -e "${color} Add RabbitMQ Application User  ${nocolor}"
rabbitmqctl add_user roboshop $1 &>>/tmp/roboshop.log
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>/tmp/roboshop.log