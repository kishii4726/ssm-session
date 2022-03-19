#!/bin/bash
function usage() {
  echo "Usage: ./$(basename "${BASH_SOURCE[0]}") <AWS profile name>"
  exit 1
}

if [ $# -ne 1 ]
then
    usage
fi

echo "Getting running instances..."
PROFILE=$1
INSTANCE_LIST=$(aws ec2 describe-instances --filter "Name=instance-state-name,Values=running" \
                --query 'Reservations[].Instances[].[Tags[?Key==`Name`] | [0].Value, LaunchTime]')

echo -n "No."
printf %2s
echo -n "InstanceName"
printf %13s
echo "LaunchTime"

INSTANCE_LIST_LENGTH=$(echo "${INSTANCE_LIST}" | jq length)
declare -A INSTANCE_NAME_MAP
count=1
for i in $( seq 0 $(("${INSTANCE_LIST_LENGTH}" - 1)) ); do
  echo -n $count
  printf %$(( 5 - ${#count} ))s
  name_tag=$(echo "${INSTANCE_LIST}" | jq .["${i}"][0])
  launch_time=$(echo "${INSTANCE_LIST}" | jq .["${i}"][1])
  echo -n "${name_tag}"
  printf %$(( 25 - ${#name_tag} ))s
  echo "${launch_time}"
  INSTANCE_NAME_MAP[$count]="${name_tag}"
  count=$((++count))
done

echo ""
echo "Enter the number of the instance for which you want to start a session."
echo -n "InstanceNumber: "
read -r INSTANCE_NUMBER

INSTANCE_NAME="${INSTANCE_NAME_MAP[$INSTANCE_NUMBER]}"
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${INSTANCE_NAME}" \
              "Name=instance-state-name,Values=running" \
              --query 'Reservations[].Instances[].InstanceId' --output text)
echo "Connecting to ${INSTANCE_NAME}(${INSTANCE_ID})..."
aws ssm start-session --target "${INSTANCE_ID}"