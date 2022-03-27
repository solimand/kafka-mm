# kafka-mm
A simple Kafka Mirror Maker.

## Why two versions
The HEAVY version of Mirror Maker, namely the Replicator, has a lot of dependencies and binaries not required in our use case (edge computing).

We built a novel container with Kafka binaries and dependencies needed by the Mirror Maker 2 tool, a lighter Kafka Mirror Maker.

## Requirements
- Docker
- Docker-Compose: ```sudo pip install docker compose```
- __SSL certificates and secrets__ (ask to repo owner)

## Start Compose Demo
Change _addresses_, container _names_, and _ports_ accordingly to your system config. 

1. Clean prev. tests: ```docker-compose down && docker-compose rm```
1. Copy SSL "secrets" folders in ```./Kafka-dest``` (for SSL broker config) and in ```./LMM``` for the Light Mirror Maker config.
1. Run compose: ```docker-compose up -d``` (automatically run the MirrorMaker2)    
1. Test mirroring
    - Produce on broker source (auto create topic): ```docker-compose exec sourcebro kafka-console-producer --topic foo --bootstrap-server localhost:9092```
    - Check messagges on broker dest (if you enabled localhost __PLAINTEXT__ listener): ```docker-compose exec destbro kafka-console-consumer --topic source.foo --bootstrap-server localhost:9092 --from-beginning```
    - Check messagges on broker dest (with credentials on __SASL__ listening port): ```docker-compose exec destbro kafka-console-consumer --topic source.foo --bootstrap-server localhost:9094 --from-beginning --consumer.config /etc/kafka/secrets/consumer.properties```

## Cheatsheet
Some useful commands.

### Check and lists
- check ACLs ```docker-compose exec sourcebro kafka-acls --authorizer kafka.security.authorizer.AclAuthorizer --authorizer-properties zookeeper.connect=zsource:2181 --list```. Expected output:
        
        Current ACLs for resource `ResourcePattern(resourceType=TOPIC, name=foo, patternType=PREFIXED)`:
        (principal=User:ANONYMOUS, host=*, operation=DESCRIBE, permissionType=ALLOW)
        (principal=User:ANONYMOUS, host=*, operation=READ, permissionType=ALLOW)

- List Topics on Kafka Source: ```docker-compose exec sourcebro kafka-topics --bootstrap-server=localhost:9092 --list```
- List Topics on Kafka Dest (if PLAINTEXT enabled): ```docker-compose exec destbro kafka-topics --bootstrap-server=localhost:9092 --list```
- Delete ALL topics on source: ```docker-compose exec sourcebro kafka-topics --bootstrap-server=localhost:9092 --delete --topic '.*'```

### Prod/Cons
- Create topic on source: ```docker-compose exec sourcebro kafka-topics --create --topic foo --partitions 1 --replication-factor 1 --if-not-exists --bootstrap-server localhost:9092```
- Start a console-producer on Kafka Source (topic foo): ```docker-compose exec sourcebro kafka-console-producer --topic foo --bootstrap-server localhost:9092``` > CTRL-c at the end
- Start a console-consumer on Kafka Dest (topic foo.mirror, PLAINTEXT enabled): ```docker-compose exec destbro kafka-console-consumer --topic foo.mirror --bootstrap-server localhost:9092 --from-beginning``` 


## References
1. [Confluent Replicator](./MMaker/): 
    - [Replicator Docs](https://docs.confluent.io/platform/current/multi-dc-deployments/replicator/index.html)
    - [Config Options](https://docs.confluent.io/platform/current/multi-dc-deployments/replicator/configuration_options.html)
    - [Replicator Tutorial](https://docs.confluent.io/platform/current/multi-dc-deployments/replicator/replicator-quickstart.html)

1. [MirrorMaker 2](./LMM/):
    - [Mirror Maker 2 Usage](https://cwiki.apache.org/confluence/display/KAFKA/KIP-382%3A+MirrorMaker+2.0#KIP382:MirrorMaker2.0-Walkthrough:RunningMirrorMaker2.0)
    - [A small tutorial](https://medium.com/larus-team/how-to-setup-mirrormaker-2-0-on-apache-kafka-multi-cluster-environment-87712d7997a4)
    - [Distributed Worker Configuration](https://docs.confluent.io/platform/current/connect/references/allconfigs.html#distributed-worker-configuration)
    - [Kafka Connect Internal Topics](https://docs.confluent.io/home/connect/self-managed/userguide.html#kconnect-internal-topics)