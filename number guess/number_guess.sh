#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guessing -t --no-align -c"

# Ask for username
echo "Enter your username:"
read USERNAME

# Check if player exists
USER_INFO=$($PSQL "SELECT games_played, best_game FROM players WHERE username='$USERNAME';")

if [[ -z $USER_INFO ]]
then
  # New player
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO players(username) VALUES('$USERNAME');"
else
  # Already exists
  GAMES_PLAYED=$(echo $USER_INFO | cut -d"|" -f1 | xargs)
  BEST_GAME=$(echo $USER_INFO | cut -d"|" -f2 | xargs)
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate random number
# Generate random number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"

while true
do
  read GUESS

  # Validate input
  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((NUMBER_OF_GUESSES++))

  if (( GUESS < SECRET_NUMBER ))
  then
    echo "It's higher than that, guess again:"
  elif (( GUESS > SECRET_NUMBER ))
  then
    echo "It's lower than that, guess again:"
  else
    # Update player's stats
    $PSQL "UPDATE players SET games_played = COALESCE(games_played,0) + 1 WHERE username='$USERNAME';"
    $PSQL "UPDATE players SET best_game = $NUMBER_OF_GUESSES WHERE username='$USERNAME' AND (best_game IS NULL OR $NUMBER_OF_GUESSES < best_game);"

    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done