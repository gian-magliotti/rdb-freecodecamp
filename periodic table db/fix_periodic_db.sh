#!/bin/bash

PSQL="psql -U freecodecamp -d periodic_table -t --no-align -c"

# Set properties.type_id to the correct value from types.
$PSQL "UPDATE properties AS p SET type_id = t.type_id FROM types AS t WHERE p.type = t.type;"
$PSQL "ALTER TABLE properties DROP COLUMN type;"

# Capitalize the first letter of symbols
$PSQL "UPDATE elements SET symbol = UPPER(LEFT(symbol,1)) || LOWER(SUBSTRING(symbol FROM 2));"

# Remove trailing zeros from atomic_mass
$PSQL "ALTER TABLE properties ALTER COLUMN atomic_mass TYPE DECIMAL;"
$PSQL "UPDATE properties SET atomic_mass = TRIM(TRAILING '0' FROM atomic_mass::text)::DECIMAL;"
