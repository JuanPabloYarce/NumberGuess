#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=game -t --no-align -c"

echo Enter your username:
read USERNAME_INPUT

USERNAME_INFO=$($PSQL "select * from games where username='$USERNAME_INPUT'" )
USERNAME=" "
if  [[ -z $USERNAME_INFO ]] 
then
  echo Welcome, $USERNAME_INPUT! It looks like this is your first time here.
  GAMES_PLAYED=0
  BEST_GAME=1000
  USERNAME=$USERNAME_INPUT
else
  IFS='|' read -r USERNAME GAMES_PLAYED BEST_GAME <<< "$USERNAME_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi


RANDOM_NUMBER=$((1 + RANDOM % 1000))
TRIES=0
FLAG_FOUND=false
echo Guess the secret number between 1 and 1000:
while [ "$FLAG_FOUND" = false ] 
do

  read CHOICE
  if [[ ! $CHOICE =~ ^[0-9]+$ ]]
  then
    echo That is not an integer, guess again:
    (( TRIES++ ))
  else
    (( TRIES++ ))

    if [[ $CHOICE -eq  $RANDOM_NUMBER ]]
    then
      FLAG_FOUND=true
      if [[ $BEST_GAME -gt $TRIES ]]
      then
        BEST_GAME=$TRIES
        (( GAMES_PLAYED++ ))
      fi

      if  [[ -z $USERNAME_INFO ]] 
      then
        INSERT_GAME_RESULT=$($PSQL "insert into games(username,games_played,best_game) values ('$USERNAME','$GAMES_PLAYED','$BEST_GAME')")
      else
        UPDATE_GAME_RESULT=$($PSQL "update games set games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")
      fi
      echo "You guessed it in $TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"

    elif [[ $CHOICE -lt $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    else 
      echo "It's lower than that, guess again:"
    fi
  fi
done
