# kafka-mm
A simple Kafka Mirror Maker.

## Requirements
- Docker
- Docker-Compose: ```sudo pip install docker compose```

## Start Compose Demo
Change addresses, container names, and ports accordingly to your system config. 

1. Clean prev. tests: ```docker-compose down && docker-compose rm```
1. Run compose: ```docker-compose up -d```
1. Create topic on source: ```docker-compose exec sourcebro kafka-topics --create --topic foo --partitions 1 --replication-factor 1 --if-not-exists --bootstrap-server localhost:9092```
1. Add ACLs to source topic ```docker-compose exec sourcebro kafka-acls --authorizer kafka.security.authorizer.AclAuthorizer --authorizer-properties zookeeper.connect=zsource:2181 --add --allow-principal User:ANONYMOUS --operation Read --operation Describe --topic foo --resource-pattern-type prefixed```
1. cd MMaker > ```docker build -f .\Dockerfile-mm -t myrep .``` > ```docker run --net=kafka-net --name therep -dt myrep```
1. [Test mirroring] Check messagges on broker dest: ```docker-compose exec destbro kafka-console-consumer --topic foo.mirror --bootstrap-server localhost:9093 --from-beginning```

## TODOs
- [CI] Automate topic/ACL creation
- [Standalone-Replicator] Install JAVA and other deps of ```connect-mirror-maker.sh```
- [Replicator] a lot of unmapped configs (investigate file /etc/replicator/replication.properties)
- [Replicator] to match topic name with regex and whitelist, the resource topic needs DESCRIBE ACL

## Cheatsheet
Some useful commands.

### Check and lists
- check ACLs ```docker-compose exec sourcebro kafka-acls --authorizer kafka.security.authorizer.AclAuthorizer --authorizer-properties zookeeper.connect=zsource:2181 --list```. Expected output:
        
        Current ACLs for resource `ResourcePattern(resourceType=TOPIC, name=foo, patternType=PREFIXED)`:
        (principal=User:ANONYMOUS, host=*, operation=DESCRIBE, permissionType=ALLOW)
        (principal=User:ANONYMOUS, host=*, operation=READ, permissionType=ALLOW)

- List Topics on Kafka Source: ```docker-compose exec sourcebro kafka-topics --bootstrap-server=localhost:9092 --list```
- List Topics on Kafka Dest: ```docker-compose exec destbro kafka-topics --bootstrap-server=localhost:9093 --list```

### Prod/Cons
- Start a producer on Kafka Source (topic foo): ```docker-compose exec sourcebro kafka-console-producer --topic foo --bootstrap-server localhost:9092``` > CTRL-c at the end
- Start a consumer on Kafka Source (topic foo): ```docker-compose exec sourcebro kafka-console-consumer --topic foo --bootstrap-server localhost:9092 --from-beginning```
- Start a consumer on Kafka Dest (topic foo.mirror): ```docker-compose exec destbro kafka-console-consumer --topic foo.mirror --bootstrap-server localhost:9092 --from-beginning``` 


## References
1. Confluent Replicator: 
    - [Replicator Docs](https://docs.confluent.io/platform/current/multi-dc-deployments/replicator/index.html)
    - [Config Options](https://docs.confluent.io/platform/current/multi-dc-deployments/replicator/configuration_options.html)
    - [Replicator Tutorial](https://docs.confluent.io/platform/current/multi-dc-deployments/replicator/replicator-quickstart.html)