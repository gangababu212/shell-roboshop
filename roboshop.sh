#!/bin/bash

SG_ID="sg-06264c970c7d1ae80"
AMI_ID="ami-0220d79f3f480ecf5"

for instance in $@
do
  INSTANCE_ID=$( aws ec2 run-instance \
  --image-id $AMI_ID\
  --instnace-type"t3.micro" \
  --security-group-ids $SG_ID \
  --tag-sepecification "ResourceType=instance,Tags=[{key=Name,Value=$instnace}]" \
  --query 'Instnace[0].InstnaceId' \
  --output text )


if [$instance == "frontend"]; then
IP=$
   (aws ec2 describe-instance \
   --instnace-ids $INSTANCE_ID \
   --query 'Reservation[].Instance[].PublicIpAddress' \
   --output text 
   )
else
   IP=$
   (aws ec2 describe-instance \
   --instnace-ids $INSTANCE_ID \
   --query 'Reservation[].Instance[].PrivateIpAddress' \
   --output text 
   )
fi

echo "IP Adress: $IP"

aws route53 change-resource-recod-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch'
    {
        "Comment": "Updating record",
        "Changes":[
        {
        "Action": "UPSERT",
        "ResourceRecordSet": {
             "Name": "'$RECORD_NAME'",
             "Type": "A",
             "TTL": 1,
             "ResourceRecords":[
             {
                "value": "'$IP'"
             }
             ]
         }
         }
     ]
}
,

echo "record update for $instance"

done