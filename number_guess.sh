#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER_OF_GUESSES=0
SECRET_NUMBER=$[ 1 + $RANDOM % 1000 ]

echo -e "\nEnter your username:"

while true
do
  read USERNAME
  # if no input
  if [[ -z $USERNAME ]]
  then
    echo -e "\nEnter your username:"
  # if input
  else
    # check the database
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

    # if user in database
    if [[ $USER_ID ]]
    then
    # get games played
    GAMES_PLAYED=$($PSQL "SELECT COUNT (user_id) FROM games INNER JOIN users USING (user_id) WHERE username='$USERNAME'")
    # get best game
    BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games INNER JOIN users USING (user_id) WHERE username='$USERNAME'")

    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

    # if user not in database
    else
      echo Welcome, $USERNAME! It looks like this is your first time here.
    fi
  break
  fi
  done

echo Guess the secret number between 1 and 1000:

while true
do
read INPUT_NUMBER
# if input is a number
if [[ $INPUT_NUMBER =~ ^[0-9]+$ ]]
then
  # if not equal to secret number
  if [[ $SECRET_NUMBER != $INPUT_NUMBER ]]
  then
    # if secret number is lower
    if [[ $SECRET_NUMBER -lt $INPUT_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    # if secret number is bigger
    else
      echo "It's higher than that, guess again:"
    fi
  # increment number of guesses
  ((NUMBER_OF_GUESSES++))
  # if equal
  else
    # increment number of guesses
    ((NUMBER_OF_GUESSES++))
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
  break
  fi

# if input is not a number
else
  echo "That is not an integer, guess again:"
fi
done

# insert into database
# if not a user
if [[ -z $USER_ID ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  INSERT_GAME=$($PSQL "INSERT INTO games (user_id, number_of_guesses, secret_number) VALUES ($USER_ID, $NUMBER_OF_GUESSES, $SECRET_NUMBER)")
# if a user
else
  INSERT_GAME=$($PSQL "INSERT INTO games (user_id, number_of_guesses, secret_number) VALUES ($USER_ID, $NUMBER_OF_GUESSES, $SECRET_NUMBER)")
fi  

