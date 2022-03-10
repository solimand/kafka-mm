#!/bin/bash

echo "Creation of foo topic on Kafka Source."

#docker-compose exec sourcebro 
kafka-topics --create --topic foo --partitions 1 --replication-factor 1 --if-not-exists --bootstrap-server localhost:9092

printf "Topic foo created.\n\t Adding ACLs to topic foo\n"

#docker-compose exec sourcebro 
kafka-acls --authorizer kafka.security.authorizer.AclAuthorizer --authorizer-properties zookeeper.connect=zsource:2181 --add --allow-principal User:ANONYMOUS --operation Read --operation Describe --topic foo --resource-pattern-type prefixed

