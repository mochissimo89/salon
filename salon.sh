#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e '\nWelcome to My Salon, how can I help you?\n'

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) BOOK_APPT 1;;
    2) BOOK_APPT 2;;
    3) BOOK_APPT 3;;
    4) BOOK_APPT 4;;
    *) MAIN_MENU 'I could not find that service. What would you like today?' ;;
  esac
}

BOOK_APPT(){
  SERVICE_ID=$1

  case $SERVICE_ID in
    1) SERVICE_NAME="Wash" ;;
    2) SERVICE_NAME="Dry" ;;
    3) SERVICE_NAME="Cut" ;;
    4) SERVICE_NAME="Dye" ;;
    *) MAIN_MENU 'Try again.' ;;
  esac

  echo -e "\nWhat's your phone number?\n"
  read CUSTOMER_PHONE

  # check if existing customer
  EXISTING_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # not a customer
  if [[ -z $EXISTING_CUSTOMER_NAME ]]
  then
    # get their name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # add to customers table
    ADD_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
    # ask for appt time
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # create the appt
    APPT_CREATION=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES ('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID)")
    
    # tell the customer
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  else
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # ask for appt time
    echo -e "\nWhat time would you like your $SERVICE_NAME, $EXISTING_CUSTOMER_NAME?"
    read SERVICE_TIME

    # create the appt
    APPT_CREATION=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES ('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID)")
   
    # tell the customer
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $EXISTING_CUSTOMER_NAME."
  fi

}



MAIN_MENU
