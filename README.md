# kafka-mm
A simple Kafka Mirror Maker.

## Requirements
- Docker
- ```sudo pip install docker compose```

## _Standalone_ Version
- Create NET ```docker network create confluent```
- ZOOKEEPER Container ```docker run -d --net=confluent --name=zookeeper -e ZOOKEEPER_CLIENT_PORT=2181 confluentinc/cp-zookeeper```
- KAFKA Source Container ```docker run -d --net=confluent --name=kafkasource -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafkasource:9092 -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 confluentinc/cp-kafka```
- KAFKA Dest Container ```docker run -d --net=confluent --name=kafkadest -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafkadest:9092 -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 confluentinc/cp-kafka```
- TOPIC Creation [run from KAFKA Source container] ```kafka-topics --create --topic foo --partitions 1 --replication-factor 1 --if-not-exists --bootstrap-server localhost:9092```

## _Compose_ Version
Compose creates 4 services (zookeeperSource, zookeeperDest, sourcebro, destbro): 
- 2 Kafka broker (ksource, kdest) 
- 2 Zookeeper (zsource, zdest)
Change addresses, container names, and ports accordingly to your config. 

1. Clean prev. tests: ```docker-compose down && docker-compose rm```
1. Run compose: ```docker-compose up -d```
1. Create topic on source: ```docker-compose exec sourcebro kafka-topics --create --topic foo --partitions 1 --replication-factor 1 --if-not-exists --bootstrap-server localhost:9092```
1. [Test topic creation] List topics on source: ```docker-compose exec sourcebro kafka-topics --bootstrap-server=localhost:9092 --list```
1. [Test topic creation] List topics on dest: ```docker-compose exec destbro kafka-topics --bootstrap-server=localhost:9093 --list```
1. Add ACLs to source topic ```docker-compose exec sourcebro kafka-acls --authorizer kafka.security.authorizer.AclAuthorizer --authorizer-properties zookeeper.connect=zsource:2181 --add --allow-principal User:ANONYMOUS --operation Read --operation Describe --topic foo --resource-pattern-type prefixed```
1. 


## TODO
- [Replicator] a lot of unmapped configs (investigate file /etc/replicator/replication.properties)
- [Replicator] to match topic name with regex and whitelist, the resource topic needs DESCRIBE ACL

## NOTES
- check ACLs ```docker-compose exec sourcebro kafka-acls --authorizer kafka.security.authorizer.AclAuthorizer --authorizer-properties zookeeper.connect=zsource:2181 --list```. Expected output:        
        
        Current ACLs for resource `ResourcePattern(resourceType=TOPIC, name=foo, patternType=PREFIXED)`:
        (principal=User:ANONYMOUS, host=*, operation=DESCRIBE, permissionType=ALLOW)
        (principal=User:ANONYMOUS, host=*, operation=READ, permissionType=ALLOW)
