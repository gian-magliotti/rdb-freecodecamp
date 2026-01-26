#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -A -t -c"
VALID=""

echo -e "\n~~~~ MY SALON ~~~~\n"
echo -e "Welcome to my salon. How can I help you?\n"

# Get services
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")

until [[ -n $VALID ]]
do
  # Print services
  echo "$SERVICES" | while IFS="|" read ID NAME
  do
    echo "$ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  # Validate that the chosen service exists
  VALID=$(echo "$SERVICES" | grep -E "^$SERVICE_ID_SELECTED\|")

  if [[ -z $VALID ]]; then
    echo -e "\nI could not find that service. Please choose again."
  fi
done

# Get customer phone
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")

if [[ -z $CUSTOMER_NAME ]] 
then
  # Create customer
  echo -e "\nWhat's your name?"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE');" > /dev/null
fi

# Get service name
SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;" | xargs)

# Ask for time
echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
read SERVICE_TIME

# Get customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';" | xargs)

# Insert appointment
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');" > /dev/null

# Confirmation message
echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
