#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
RESULTS_DIR=$THIS_DIR/results

# Organize the results
declare -A data

max_vm_type_length=0

for file in $RESULTS_DIR/*.txt; do
  file_name=$(basename "$file")
  vm_type=$(echo "$file_name" | cut -d'_' -f1)
  thread=$(echo "$file_name" | cut -d'_' -f2)

  benchmark="SET"
  throughput=$(cat "$file" | tail -n 4 | head -1 | sed -E 's,^[^0-9]*([0-9]+.[0-9]+).*$,\1,')
  data["$benchmark,$vm_type,$thread"]=$throughput
  benchmark="GET"
  throughput=$(cat "$file" | tail -n 3 | head -1 | sed -E 's,^[^0-9]*([0-9]+.[0-9]+).*$,\1,')
  data["$benchmark,$vm_type,$thread"]=$throughput
  benchmark="TOTAL"
  throughput=$(cat "$file" | tail -n 1 | sed -E 's,^[^0-9]*([0-9]+.[0-9]+).*$,\1,')
  data["$benchmark,$vm_type,$thread"]=$throughput

  if [[ ${#vm_type} -gt max_vm_type_length ]]; then
    max_vm_type_length=${#vm_type}
  fi
done

benchmarks=$(echo "${!data[@]}" | tr ' ' '\n' | cut -d',' -f1 | sort -u)
vm_types=$(echo "${!data[@]}" | tr ' ' '\n' | cut -d',' -f2 | sort -u)
thread_nums=$(echo "${!data[@]}" | tr ' ' '\n' | cut -d',' -f3 | sort -n -u)

# Output the results to csv (all threads in 1 csv)
for benchmark in $benchmarks; do
  for vm_type in $vm_types; do
    csv_file="$RESULTS_DIR/"$benchmark"_"$vm_type".csv"
    # write the header of the csv
    printf "Threads," > $csv_file
    for thread in $thread_nums; do
      printf "%s," "$thread" >> $csv_file
    done
    truncate -s-1 $csv_file # remove last comma
    printf "\n" >> $csv_file

    printf "Throughput (ops/sec)," >> $csv_file
    for thread in $thread_nums; do
      key="$benchmark,$vm_type,$thread"
      if [ -n "${data[$key]}" ]; then
        printf "%.4f," "${data[$key]}" >> $csv_file
      else
        printf "," >> $csv_file
      fi
    done
    truncate -s-1 $csv_file # remove last comma
    printf "\n" >> $csv_file
  done
done

# Output the results to csv (each thread count as a separate experiment)
for benchmark in $benchmarks; do
  for vm_type in $vm_types; do
    for thread in $thread_nums; do
      csv_file="$RESULTS_DIR/"$benchmark"-"$thread"_"$vm_type".csv"
      printf "Threads," > $csv_file
      printf "%s\n" "$thread" >> $csv_file
      printf "Throughput (ops/sec)," >> $csv_file
      key="$benchmark,$vm_type,$thread"
      if [ -n "${data[$key]}" ]; then
        printf "%.4f\n" "${data[$key]}" >> $csv_file
      else
        printf "\n" >> $csv_file
      fi
    done
  done
done

# Pretty print the results to stdout
for benchmark in $benchmarks; do
  printf "$benchmark (measurements in ops/sec)\n"
  header="VM Type\Threads"
  if [[ ${#header} -gt max_vm_type_length ]]; then
    max_vm_type_length=${#header}
  fi

  printf "%-${max_vm_type_length}s\t" "$header"
  for thread in $thread_nums; do
    printf "%s\t\t" "$thread"
  done
  printf "\n"

  for vm_type in $vm_types; do
    printf "%-${max_vm_type_length}s\t" "$vm_type"
    for thread in $thread_nums; do
      key="$benchmark,$vm_type,$thread"
      if [ -n "${data[$key]}" ]; then
        printf "%.8f\t" "${data[$key]}"
      else
        printf "N/A\t\t"
      fi
    done
    printf "\n"
  done
done