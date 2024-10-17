import csv
import matplotlib.pyplot as plt
import numpy as np
import os
import sys

if len(sys.argv) != 2:
    print('Usage: python plot.py <benchmark_name>')
    sys.exit(1)

results_folder = f'{sys.argv[1]}'

# Read execution times from the CSV file
tools = []
execution_times = []

with open(os.path.join(results_folder, 'execution_times.csv'), 'r') as csvfile:
    csvreader = csv.reader(csvfile)
    next(csvreader)  
    for row in csvreader:
        tools.append(row[0])
        execution_times.append(float(row[1]))

# Create the bar plot for execution times
plt.figure(figsize=(10, 6))
bars = plt.bar(tools, execution_times, color='green',width=0.7)
plt.title('Execution Times for Different Tools')
plt.xlabel('Tool')
plt.ylabel('Execution Time (s)')
plt.xticks(rotation=45, ha='right')
plt.grid(axis='y', linestyle='--', alpha=0.7)

# Add exact values at the top of each bar
for bar, value in zip(bars, execution_times):
    plt.text(bar.get_x() + bar.get_width() / 2, bar.get_height(), str(value), ha='center', va='bottom')

# Save the graph as an image file
plt.tight_layout()
plt.savefig(os.path.join(results_folder, 'execution_times_chart.png'))  # Saving

# Read data for precisions from the CSV file
precision_tool_names = []
precisions = []

with open(os.path.join(results_folder, 'precisions.csv'), 'r') as csvfile:
    csvreader = csv.reader(csvfile)
    next(csvreader) 
    for row in csvreader:
        precision_tool_names.append(row[0])
        precisions.append(float(row[1]))

# Read data for recalls from the CSV file
recall_tool_names = []
recalls = []

with open(os.path.join(results_folder, 'recalls.csv'), 'r') as csvfile:
    csvreader = csv.reader(csvfile)
    next(csvreader) 
    for row in csvreader:
        recall_tool_names.append(row[0])
        recalls.append(float(row[1]))



# Create the bar plot for precisions and recalls
bar_width = 0.35  

precision_indices = np.arange(len(precision_tool_names))  # X locations for precision bars
recall_indices = [x + bar_width for x in precision_indices]  # X locations for recall bars

plt.figure(figsize=(10, 6))
precision_bars = plt.bar(precision_indices, precisions, width=bar_width, color='blue', label='Precision')
recall_bars = plt.bar(recall_indices, recalls, width=bar_width, color='orange', label='Recall')
plt.title('Precision and Recall Values for Different Tools')
plt.xlabel('Tool')
plt.ylabel('Value')
plt.xticks(precision_indices + bar_width / 2, precision_tool_names, rotation=45, ha='right')
plt.ylim(0, 100)
plt.grid(axis='y', linestyle='--', alpha=0.7)
plt.legend()

# Add the exact values at the top of each bar for precision and recall
for bar, value in zip(precision_bars, precisions):
    plt.text(bar.get_x() + bar.get_width() / 2, bar.get_height(), str(value), ha='center', va='bottom', fontsize=8)
for bar, value in zip(recall_bars, recalls):
    plt.text(bar.get_x() + bar.get_width() / 2, bar.get_height(), str(value), ha='center', va='bottom', fontsize=8)

# Save the graph as an image file
plt.tight_layout()
plt.savefig(os.path.join(results_folder, 'precision_recall_chart.png'))
