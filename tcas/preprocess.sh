#!/bin/bash

# Among UNRESOLVED(0), UPWARD_RA(1), DOWNWARD_RA(2), we only keep when the right code returns UNRESOLVED(0) and wrong code returns UPWARD_RA(1)
# v9, v14 is skipped because the right code does not return UNRESOLVED
# v8 is skipped because wrong code doees not return UPWARD_RA
declare -A versions
versions["v1"]="958 1 1 2597  574 4253 0  399  400 0 0 1" # unitest0
versions["v2"]="934 1 0 343 30 545 0 5 121 0 0 1" # unitest1182
versions["v3"]="779 1 0 4175   94 5280 1  739  499 0 1 1" # unitest112
versions["v4"]="940 1 1  203  198  885 0  499  500 0 0 0" # unitest110
versions["v5"]="34 1 0 533 30 545 3 765 621 0 0 1" # unitest1178
versions["v6"]="634 1 0 433 300 433 0 445 350 1 0 1" # unitest1322
versions["v7"]="635 1 0 1142  411 4704 1  740  500 0 0 1" # unitest1021
versions["v10"]="934 1 0 433 400 433 0 445 350 1 0 0" # unitest1323
versions["v11"]="934 1 0 433 400 433 1 445 350 1 0 0" # unitest1324
versions["v12"]="890 0 1 4178  598 5835 2  741  401 1 0 1" # unitest114
versions["v13"]="845 1 1 667 661 683 1 446 404 2 2 0" # unitest571
versions["v15"]="592 1 0 1045  226 4721 2  640  401 0 0 1" # unitest150
versions["v16"]="644 1 1 1886  596 2348 0  741  400 1 0 0" # unitest1001

for version in "${!versions[@]}"; do
    file="./versions.alt/versions.orig/$version/tcas.c"
    if [ -f "$file" ]; then
        echo "Processing $file"

        # Split the version's values into an array
        IFS=' ' read -ra values <<< "${versions[$version]}"

        sed -i '
            # Replace the function signature and remove extra brace
            /main(argc, argv)/,/^{/{
                /main(argc, argv)/{
                    N;N;N;
                    s/main(argc, argv)\s*\nint argc;\s*\nchar \*argv\[\];\s*\n{/int main(int argc, char *argv[])\n{/
                }
            }
            # Delete the specified lines
            /if(argc < 13)/,/exit(1);/d
            # Remove any remaining closing brace after the opening one
            /^int main(int argc, char \*argv\[\])/,/^{/{
                /^    }/d
            }
            # Remove exit
            /    exit(0);/d
            # Replace variable assignments
            s/Cur_Vertical_Sep = atoi(argv\[1\]);/Cur_Vertical_Sep = '"${values[0]}"';/
            s/High_Confidence = atoi(argv\[2\]);/High_Confidence = '"${values[1]}"';/
            s/Two_of_Three_Reports_Valid = atoi(argv\[3\]);/Two_of_Three_Reports_Valid = '"${values[2]}"';/
            s/Own_Tracked_Alt = atoi(argv\[4\]);/Own_Tracked_Alt = '"${values[3]}"';/
            s/Own_Tracked_Alt_Rate = atoi(argv\[5\]);/Own_Tracked_Alt_Rate = '"${values[4]}"';/
            s/Other_Tracked_Alt = atoi(argv\[6\]);/Other_Tracked_Alt = '"${values[5]}"';/
            s/Alt_Layer_Value = atoi(argv\[7\]);/Alt_Layer_Value = '"${values[6]}"';/
            s/Up_Separation = atoi(argv\[8\]);/Up_Separation = '"${values[7]}"';/
            s/Down_Separation = atoi(argv\[9\]);/Down_Separation = '"${values[8]}"';/
            s/Other_RAC = atoi(argv\[10\]);/Other_RAC = '"${values[9]}"';/
            s/Other_Capability = atoi(argv\[11\]);/Other_Capability = '"${values[10]}"';/
            s/Climb_Inhibit = atoi(argv\[12\]);/Climb_Inhibit = '"${values[11]}"';/
            s/    return alt_sep;/    if (alt_sep == UPWARD_RA) fprintf(stdout, "%d\\n", 43210);\n    return alt_sep;/
        ' "$file"

        echo "Finished processing $file"
    else
        echo "File not found: $file"
    fi
done