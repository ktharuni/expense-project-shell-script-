#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIME_STAMP.log"

mkdir -p $LOGS_FOLDER

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
then 
    echo "$R Please run this script with root privileges $N" | tee -a $LOG_FILE
    exit 1
fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is $R failed $N" | tee -a $LOG_FILE
        exit 1
    else  
       echo -e "$2 is $G successful $N" | tee -a $LOG_FILE
    fi
}

echo "Script started execution at $(date)" | tee -a $LOG_FILE

CHECK_ROOT

dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>> $LOG_FILE
VALIDATE $? "Enabling mysql server"

systemctl start mysqld &>> $LOG_FILE
VALIDATE $? "started mysql server"

mysql -h 172.31.19.36 -u root -pExpenseApp@1 -e 'show databases;' &>> $LOG_FILE
if [ $? -ne 0 ]
then
    echo "MySQL root password is not setup, setting now" &>>$LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting UP root password"
else
    echo -e "MySQL root password is already setup...$Y SKIPPING $N" | tee -a $LOG_FILE
fi

