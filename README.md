# Overview

This project contains a corpus of data simulating API evolution in Java. The corpus includes two versions of a library, which contain synthetic "dummy" API classes that have evolved after through these versions.

## Purpose

Backward compatibility is an issue to cope with today. To assess the backward compatibility, a lot of tools exist, but the question is how the tools perform. It is not easy to answear without a proper benchmark. Any benchmarks, however, need a **test data**. They are provided here. 

## About this version
In this updated version, several new features were introduced to Kamil Jezek and Jens Dietrich's [original benchmark](https://github.com/kjezek/api-evolution-data-corpus). 
These improvements include the atomization of all the breaking change files for a more granular evaluation, and the incorporation of a new tool named `roseau` alongside the existing ones. In addition to that, the precision, recall and execution time for each tool are now assessed, providing insights into its ability to detect both true and false positives, while also evaluating the overall tool performance.

The results are not only presented in the benchmark.csv file but equally displayed in the bar charts `precision_recall_chart.png` & `execution_times_chart.png` to facilitate visual comparison. 
These metrics are also organized in separate .csv files for convenient data access, namely `precisions.csv`, `recalls.csv` and `execution_times.csv`.

All said files are automatically generated upon running the `./benchmark.sh` command, maintaining the same user-friendly benchmark usage.




## Structure

The corpus contains two main directories:  **lib-v1** and **lib-v2** with API examples in one version and its evolution in a following version. Each directory contains thousands of packages, where each package simulates one API change. The change is projected in the **package name**. 

Directory **client** contains a simple client application that invokes API from the library. Its purpose is to simulate usage of the API.

## Invocation

One can build the corpus simply by typing:
```
ant jar
```
It produces three JAR files: `lib-v1.jar`, `lib-v2.jar` and  `client.jar` containing all API classes and the client compiled in byte-code.

The data  may be used as such to benchmark third-party tools or any other experiments. We provide benchmark of some tools bellow.  

## Compatibility types

A set of other materials is provided to help with using the corpus. First, 
a table with API incompatibility results may be generated. The generation is invoked simply by typing:

```
./compatibility.sh
```

This script tries to commpile and run the client with both library versions and generates a `CSV` file with results. The file lists one-by-one each API change a informs if the change is `source` or `binary` compatible. 

Example showing `unboxing` of a constant and `access modifier`  change, where "1" means compatible while "0" incompatible:

| Change                             | Source | Binary |
|------------------------------------|-------:|-------:|
| dataTypeIfazeConstantUnboxing      |      1 |      0 |
| accessModifierClazzAccessDecrease  |      0 |      0 |


## Benchmark

Third party tools may be benchmarked. Run:

```
./benchmark.sh
```
It will invoke tested tools that are fed with the corpus data and their ability to discover API changes is checked. The results are stored in `benchmark.csv` table, where "1" means that a change was detected while "0" means that it was not. 

The set of tested tools may be extended. Just edit the script `tools/run.sh` and add lines invoking the tool. Make sure the output of the tool is stored in directory `tools/.reports/` in a textual form. The benchamrk script can then grap the report and parse results. Note that a detected API change is obtained simply by string matching. 

Similarly, the set of test data may be extended simply by adding new changes to the `src` dirs. The data shuold only follow the naming pattern already used. 

## Tested Tools

Tools included in th benchmark:
- Japicmp (https://github.com/siom79/japicmp)
- Revapi (http://revapi.org/)
- Roseau (https://github.com/alien-tools/roseau)
 
## Results

| 	                | japicmp | revapi  | roseau  |
|------------------|---------|---------|---------|
| Access Modifiers | 0.00%   | 0.00%   | 0.00%   |
| Data Types       | 0.00%   | 0.00%   | 0.00%   |
| Exceptions       | 0.00%   | 0.00%   | 0.00%   |
| Generics         | 0.00%   | 0.00%   | 0.00%   |
| Inheritance      | 0.00%   | 0.00%   | 0.00%   |
| Members          | 0.00%   | 0.00%   | 0.00%   |
| Other Modifiers  | 0.00%   | 0.00%   | 0.00%   |
| Others           | 0.00%   | 0.00%   | 0.00%   |	
|                  | 0.00%   | 0.00%   | 0.00%   |


