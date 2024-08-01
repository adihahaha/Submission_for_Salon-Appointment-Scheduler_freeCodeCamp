#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo $SERVICES | sed 's/ | /) /g' | xargs -n 2 echo
  read SERVICE_ID_SELECTED
  
  case $SERVICE_ID_SELECTED in
    1|2|3|4|5) SERVICE_MENU $SERVICE_ID_SELECTED;;
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac
}

SERVICE_MENU() {
  
  # get customer phone
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # check if customer exists
  CUSTOMER_INFO=$($PSQL "SELECT customer_id, name, phone FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # if exists
  if [[ -z $CUSTOMER_INFO ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  
  CUSTOMER_INFO=$($PSQL "SELECT customer_id, name, phone FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_ID=$(echo $CUSTOMER_INFO | cut -d '|' -f 1 | xargs)
  CUSTOMER_NAME=$(echo $CUSTOMER_INFO | cut -d '|' -f 2 | xargs)

  APPOINTMENT_MENU $CUSTOMER_ID $CUSTOMER_NAME $CUSTOMER_PHONE
}

APPOINTMENT_MENU() {
  CUSTOMER_ID=$1
  CUSTOMER_NAME=$2
  CUSTOMER_PHONE=$3

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(service_id, time, customer_id) VALUES($SERVICE_ID_SELECTED, '$SERVICE_TIME', $CUSTOMER_ID)")

  if [[ $INSERT_APPOINTMENT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    echo -e "\nThere was an issue scheduling your appointment. Please try again."
  fi
  
}

MAIN_MENU


