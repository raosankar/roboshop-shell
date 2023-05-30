source common.sh
component=catalogue

roboshop_app_password=$1
if [ -z "$roboshop_app_password" ]; then
  echo "roboshop_app_password Is Missing"
fi
python