#!/bin/bash

PSQL="psql -U freecodecamp -d periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

INPUT=$1

if [[ $INPUT =~ ^[0-9]+$ ]]
then
  CONDITION="atomic_number = $INPUT"
else
  CONDITION="LOWER(symbol) = LOWER('$INPUT') OR LOWER(name) = LOWER('$INPUT')"
fi

ELEMENT=$($PSQL "
SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius
FROM elements
JOIN properties USING(atomic_number)
JOIN types USING(type_id)
WHERE $CONDITION;
")

if [[ -z $ELEMENT ]]
then
  echo "I could not find that element in the database."
  exit
fi

IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELT BOIL <<< "$ELEMENT"

echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
