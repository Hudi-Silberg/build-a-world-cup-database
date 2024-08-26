#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Clear existing data
echo "Truncating tables..."
$PSQL "TRUNCATE TABLE games, teams;"

# Read games.csv and insert data into the database
while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  # Skip header line
  if [[ $year != year ]]; then
    # Insert teams (avoid duplicates)
    for team in "$winner" "$opponent"
    do
      # Check if team already exists
      TEAM_EXISTS=$($PSQL "SELECT team_id FROM teams WHERE name='$team'")
      if [[ -z $TEAM_EXISTS ]]; then
        # Insert team if it does not exist
        echo "Inserting team: $team"
        $PSQL "INSERT INTO teams(name) VALUES('$team')"
      fi
    done

    # Get team ids
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")

    # Insert game
    echo "Inserting game: $year, $round, $winner, $opponent, $winner_goals, $opponent_goals"
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals)"
  fi
done < games.csv
