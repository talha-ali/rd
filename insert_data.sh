#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Script to insert data from games.csv into worldcup database

echo $($PSQL "TRUNCATE teams, games RESTART IDENTITY")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != "winner" ]]
  then
    # get team_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name ='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name ='$OPPONENT'")
    echo $WINNER_ID : $WINNER
    echo $OPPONENT_ID : $OPPONENT
    echo "line 25 : team_id and name block executed for both winner and opponent"
    echo -e "\n"

    # if not found
    if [[ -z $WINNER_ID && -z $OPPONENT_ID ]]
    then
      # insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams (name) VALUES('$WINNER'), ('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 2" ]]
      then
        echo "Inserted WINNER & OPPNENT BOTH into teams, $WINNER, $OPPONENT"
        echo -e "\n\n"
      fi
      # get new winner_id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name ='$WINNER'")

      # get new opponent_id
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name ='$OPPONENT'")
    fi
    
    if [[ -z $WINNER_ID  ]]
    then
      # insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams (name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted WINNER ONLY into teams, $WINNER"
        echo -e "\n\n"
      fi
      # get new winner_id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name ='$WINNER'")
    fi

    if [[ -z $OPPONENT_ID  ]]
    then
      # insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams (name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted OPPONENT ONLY into teams, $OPPONENT"
        echo -e "\n\n"
      fi
      # get new opponent_id
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name ='$OPPONENT'")
    fi

    # insert games
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into games, $YEAR $ROUND $WINNER $OPPONENT $WINNER_GOALS $OPPONENT_GOALS
    fi
  fi
done