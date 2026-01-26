#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
awk -F',' 'NR>1 {print $3; print $4}' games.csv | sort | uniq | while read TEAM
do
  # Insert team
  echo $($PSQL "INSERT INTO teams(name) VALUES('$TEAM');")
done

awk -F',' 'NR>1 {print $1","$2","$3","$4","$5","$6}' games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WG OG
do
  # Get team's IDs
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

  # Insert game
  echo $($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WG, $OG);")
done