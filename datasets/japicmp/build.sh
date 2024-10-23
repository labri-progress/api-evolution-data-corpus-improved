#!/usr/bin/env bash

mvn clean
mvn package

[ -d "output/build" ] || mkdir -p "output/build"
cp v1/target/japicmp-test-v1-0.23.1-SNAPSHOT.jar output/build/v1.jar
cp v2/target/japicmp-test-v2-0.23.1-SNAPSHOT.jar output/build/v2.jar
