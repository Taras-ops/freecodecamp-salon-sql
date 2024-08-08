#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")

  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "\n~~~~~ MY SALON ~~~~~\n"
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi

  echo "$SERVICES" | while read SERVICE_ID TAB NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  CURRENT_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $CURRENT_SERVICE ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else 
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    
    CURRENT_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CURRENT_CUSTOMER_ID ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      CUSTOMER_INSERTED=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CURRENT_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    echo -e "\nWhat time would you like your$CURRENT_SERVICE_NAME,$CUSTOMER_NAME?"
    read SERVICE_TIME

    CURRENT_APPOINTED=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $CURRENT_SERVICE, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a$CURRENT_SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
  fi
}

MAIN_MENU