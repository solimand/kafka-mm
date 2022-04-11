# Kafka SSL demo
The dedicated branch ```ssl-demo``` contains the deployment of Kafka SSL-enabled and MirrorMaker.

The [IT Layer folder](./IT-Layer) contains the deployment of the destination Kafka broker (SSL-enabled). 
- Copy the Kafka dest broker secrets in the folder ```./IT-Layer/Kafka-dest/secrets``` and the secrets of the Zookeeper orchestrator in the folder ```./IT-Layer/Zoo-dest/secrets```.

The [OT Layer folder](./OT-Layer) contains the deployment of the source Kafka broker and of the MirrorMaker connector.
- Copy the MirrorMaker secrets in the folder ```./OT-Layer/LMM/secrets```.
