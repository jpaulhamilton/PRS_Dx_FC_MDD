#!/bin/bash

INPUT="/flush/common/UKbiobank/T1_dset/ukb46737_repaired.txt"
OUTDIR="/flush/common/UKbiobank/fMRI_dset/statistics_new/2026_behave_split_analysis/BEHAVE_EXTENDED"

mkdir -p "$OUTDIR"


############################################################
# FUNCTION
# Find the actual column number corresponding to
# a UKB field-instance identifier, e.g. 2050-2.0
############################################################

get_column() {

    FIELD="$1"

    head -1 "$INPUT" |
    awk -F '\t' -v b="$FIELD" '{
        for (i=1; i<=NF; i++) {
            if ($i == b) {
                print i
                exit
            }
        }
    }'
}


############################################################
# FUNCTION
# Extract one UKB field
#
# Missing/blank values are ignored.
#
# IMPORTANT:
# - Negative values are KEPT
# - Zero values are KEPT
# - No recoding is performed here
#
# All cleaning, exclusion and recoding is done later in R.
############################################################

extract_field() {

    FIELD="$1"
    NAME="$2"

    COL=$(get_column "$FIELD")

    if [ -z "$COL" ]; then
        echo "ERROR: Could not find $FIELD in header."
        return 1
    fi

    echo "$FIELD -> column $COL"

    # > overwrites any existing file
    echo "eid,value" > "$OUTDIR/${NAME}.csv"

    awk -F '\t' -v OFS=',' -v col="$COL" '
        NR > 1 && $col != "" {
            print $1, $col
        }
    ' "$INPUT" >> "$OUTDIR/${NAME}.csv"

    echo "Created/overwritten: $OUTDIR/${NAME}.csv"
    echo
}


############################################################
# FIELDS
############################################################

extract_field "102-2.0" "field_102"

extract_field "46-2.0" "field_46"
extract_field "47-2.0" "field_47"

extract_field "699-2.0" "field_699"
extract_field "709-2.0" "field_709"
extract_field "738-2.0" "field_738"
extract_field "826-2.0" "field_826"
extract_field "816-2.0" "field_816"
extract_field "767-2.0" "field_767"
extract_field "757-2.0" "field_757"
extract_field "796-2.0" "field_796"
extract_field "806-2.0" "field_806"

extract_field "1120-2.0" "field_1120"
extract_field "1160-2.0" "sleep_duration"
extract_field "1170-2.0" "field_1170"
extract_field "1180-2.0" "field_1180"
extract_field "1200-2.0" "field_1200"
extract_field "1220-2.0" "field_1220"

extract_field "1031-2.0" "field_1031"

extract_field "1920-2.0" "field_1920"
extract_field "1930-2.0" "field_1930"
extract_field "1940-2.0" "field_1940"
extract_field "1950-2.0" "field_1950"
extract_field "1960-2.0" "field_1960"
extract_field "1970-2.0" "field_1970"
extract_field "1980-2.0" "field_1980"
extract_field "1990-2.0" "field_1990"
extract_field "2000-2.0" "field_2000"
extract_field "2010-2.0" "field_2010"
extract_field "2020-2.0" "loneliness_isolation"
extract_field "2030-2.0" "field_2030"
extract_field "2040-2.0" "risk_taking"
extract_field "2050-2.0" "depressed_mood"
extract_field "2060-2.0" "field_2060"
extract_field "2070-2.0" "tenseness_restlessness"
extract_field "2080-2.0" "field_2080"

extract_field "2110-2.0" "field_2110"
extract_field "2178-2.0" "field_2178"
extract_field "2247-2.0" "field_2247"
extract_field "2335-2.0" "field_2335"

extract_field "3062-2.0" "field_3062"
extract_field "3063-2.0" "field_3063"

# Stable trait, Instance 0
extract_field "3148-0.0" "field_3148"

extract_field "4079-2.0" "field_4079"
extract_field "4080-2.0" "field_4080"
extract_field "4283-2.0" "field_4283"

extract_field "4526-2.0" "happiness"
extract_field "4537-2.0" "field_4537"
extract_field "4548-2.0" "health_satisfaction"
extract_field "4559-2.0" "family_relationship_satisfaction"
extract_field "4570-2.0" "friendships_satisfaction"
extract_field "4581-2.0" "field_4581"
extract_field "4609-2.0" "field_4609"
extract_field "4620-2.0" "field_4620"
extract_field "4717-2.0" "field_4717"

extract_field "5386-2.0" "field_5386"
extract_field "6333-2.0" "field_6333"
extract_field "6364-2.0" "field_6364"
extract_field "6373-2.0" "field_6373"

extract_field "12338-2.0" "field_12338"

extract_field "22334-2.0" "field_22334"
extract_field "22330-2.0" "field_22330"
extract_field "22338-2.0" "field_22338"

extract_field "12340-2.0" "field_12340"

extract_field "22331-2.0" "field_22331"
extract_field "22332-2.0" "field_22332"
extract_field "22333-2.0" "field_22333"

extract_field "20016-2.0" "field_20016"
extract_field "20018-2.0" "field_20018"
extract_field "20023-2.0" "field_20023"

# Stable trait, Instance 0
extract_field "20127-0.0" "field_20127"

extract_field "20139-2.0" "field_20139"
extract_field "20197-2.0" "field_20197"

extract_field "21001-2.0" "field_21001"
extract_field "21004-2.0" "field_21004"
extract_field "21021-2.0" "field_21021"

extract_field "22040-2.0" "field_22040"
extract_field "23099-2.0" "field_23099"
extract_field "23106-2.0" "field_23106"
extract_field "23324-2.0" "field_23324"


############################################################
# DONE
############################################################

echo "========================================"
echo "All UKB field files created/overwritten."
echo
echo "Input:"
echo "$INPUT"
echo
echo "Output directory:"
echo "$OUTDIR"
echo "========================================"