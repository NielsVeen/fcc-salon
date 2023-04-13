#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICES=$($PSQL "SELECT service_id,name FROM services")
function MAIN_MENU(){
echo "$SERVICES" | while IFS='|' read -r service_id name; do
  echo "$(echo $service_id | sed -E 's/^ *|//g;s/ *$//g' )) $(echo $name | sed -E 's/^ *|//g;s/ *$//g')"
done

echo -e "\nWhich service would you like?"
read SERVICE_ID_SELECTED

SERVICE_ID_SELECTED_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
echo $SERVICE_ID_SELECTED_RESULT

# if service doesn't exits
if [[ -z $SERVICE_ID_SELECTED_RESULT ]]
then
MAIN_MENU
# send to main menu
else
# get phone number
echo -e "\nWhat is your phone number?"
read CUSTOMER_PHONE

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
# if phone number doesn't exist
if [[ -z $CUSTOMER_ID ]]
then
# get the name
echo -e "\nWhat is your name?"
read CUSTOMER_NAME
# enter into the database
  INSERT_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
fi

# ask for the time
echo -e "\nWhat time would you like to book your appointment?"
read SERVICE_TIME

# insert appointment into the db
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
echo -e "\nI have put you down for a $(echo $(echo $SERVICE_NAME | sed -E 's/^ *|//g;s/ *$//g' )) at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *|//g;s/ *$//g' )."

fi
}

MAIN_MENU

