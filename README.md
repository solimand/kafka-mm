# kafka-mm
A simple Kafka Mirror Maker.

## Requirements
- Docker
- ```sudo pip install docker compose```

## _Compose_ Version
Compose creates 4 services (zookeeperSource, zookeeperDest, sourcebro, destbro): 
- 2 Kafka broker (ksource, kdest) 
- 2 Zookeeper (zsource, zdest)
Change addresses, container names, and ports accordingly to your config. 

1. Clean prev. tests: ```docker-compose down && docker-compose rm```
1. Run compose: ```docker-compose up -d```
1. Create topic on source: ```docker-compose exec sourcebro kafka-topics --create --topic foo --partitions 1 --replication-factor 1 --if-not-exists --bootstrap-server localhost:9092```
1. Write Msg on source topic: ```docker-compose exec sourcebro kafka-console-producer --topic foo --bootstrap-server localhost:9092``` > CTRL-c at the end
1. [Test producer] Check messagges in topic foo on broker source: ```docker-compose exec sourcebro kafka-console-consumer --topic foo --bootstrap-server localhost:9092 --from-beginning```
1. [Test topic creation] List topics on source: ```docker-compose exec sourcebro kafka-topics --bootstrap-server=localhost:9092 --list```
1. [Test topic creation] List topics on dest: ```docker-compose exec destbro kafka-topics --bootstrap-server=localhost:9093 --list```
1. Add ACLs to source topic ```docker-compose exec sourcebro kafka-acls --authorizer kafka.security.authorizer.AclAuthorizer --authorizer-properties zookeeper.connect=zsource:2181 --add --allow-principal User:ANONYMOUS --operation Read --operation Describe --topic foo --resource-pattern-type prefixed```
1. cd MMaker > ```docker build -f .\Dockerfile-mm -t myrep .``` > ```docker run --net=kafka-mm_default --name therep -dt myrep```
1. [Test mirroring] Check messagges on broker dest: ```docker-compose exec destbro kafka-console-consumer --topic foo.mirror --bootstrap-server localhost:9093 --from-beginning```

## TODO
- [Replicator] a lot of unmapped configs (investigate file /etc/replicator/replication.properties)
- [Replicator] to match topic name with regex and whitelist, the resource topic needs DESCRIBE ACL

## NOTES
- check ACLs ```docker-compose exec sourcebro kafka-acls --authorizer kafka.security.authorizer.AclAuthorizer --authorizer-properties zookeeper.connect=zsource:2181 --list```. Expected output:        
        
        Current ACLs for resource `ResourcePattern(resourceType=TOPIC, name=foo, patternType=PREFIXED)`:
        (principal=User:ANONYMOUS, host=*, operation=DESCRIBE, permissionType=ALLOW)
        (principal=User:ANONYMOUS, host=*, operation=READ, permissionType=ALLOW)

## References
1. Confluent Replicator: 
    - [Replicator Docs](https://docs.confluent.io/platform/current/multi-dc-deployments/replicator/index.html)
    - [Config Options](https://docs.confluent.io/platform/current/multi-dc-deployments/replicator/configuration_options.html)
    - [Replicator Tutorial](https://docs.confluent.io/platform/current/multi-dc-deployments/replicator/replicator-quickstart.html)