##### Set up important variables for communicating with Fitbit API #####
CLIENT_ID=#your client id
CLIENT_SECRET=#your client secret
USER_ID=# your Fitbit user ID
client_id_and_secret_base64=$(echo -n $CLIENT_ID:$CLIENT_SECRET | base64)
refresh_url=https://api.fitbit.com/oauth2/token
steps_url=https://api.fitbit.com/1/user/$USER_ID/activities/date/today.json
REFRESH_TOKEN_FILE=#location of .txt file to read/write refresh token
REFRESH_TOKEN=$(cat $REFRESH_TOKEN_FILE)

##### Refresh the Access Token #####
refresh_results=$(curl --silent -H "Content-Type: application/x-www-form-urlencoded" -H "Authorization: Basic $client_id_and_secret_base64" --data "grant_type=refresh_token&refresh_token="$REFRESH_TOKEN"" ${refresh_url})
ACCESS_TOKEN=$(echo "$refresh_results" | jq -r '.access_token')
REFRESH_TOKEN=$(echo "$refresh_results" | jq -r '.refresh_token')

##### Write latest refresh token to file #####
echo $REFRESH_TOKEN > $REFRESH_TOKEN_FILE

##### Fetch today's activity #####
RESULT=$(curl --silent -H "Authorization: Bearer "$ACCESS_TOKEN"" ${steps_url})

##### Parse out activity data to display (steps, floors, distance, etc) #####
steps=$(jq -r '.summary.steps' <<< "$RESULT")

##### Show errors in i3bar #####
if [ $steps == null ]
then
  error=$(jq -r '.errors[0].message' <<< "$RESULT")
  echo "ERROR: $error" " " #short
  echo "ERROR: $error" " " #long
else

##### Finally, output what you want to show in i3bar #####
  echo "$steps" " " #short
  echo "$steps" " " #long

fi

##### Use Fitbit theme color for text #####
echo "#00B5C0" #color
