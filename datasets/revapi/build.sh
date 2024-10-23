#!/usr/bin/env bash

[ -d output/build ] || mkdir -p output/build
[ -d v1/target ] || mkdir -p v1/target
[ -d v2/target ] || mkdir -p v2/target

"$JAVA_HOME"/bin/javac -d v1/target `find v1/src -name '*.java'`
"$JAVA_HOME"/bin/javac -d v2/target `find v2/src -name '*.java'`

cd v1/target && "$JAVA_HOME/bin/jar" -cf ../../output/build/v1.jar `ls`
cd ../..

cd v2/target && "$JAVA_HOME/bin/jar" -cf ../../output/build/v2.jar `ls`
cd ../..
