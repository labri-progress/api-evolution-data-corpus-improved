#!/usr/bin/env bash

mvn clean
mvn package

[ -d "output/build" ] || mkdir -p "output/build"
cp v1/target/comp-changes-old-0.0.1.jar output/build/v1.jar
cp v2/target/comp-changes-new-0.0.1.jar output/build/v2.jar
cp client/target/comp-changes-client-0.0.1.jar output/build/client.jar
