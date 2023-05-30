source common.sh
component=payment

roboshop_app_password=$1
if [ -z "$roboshop_app_password" ]; then
  echo "Roboshop_app_password Is Missing"
fi

python