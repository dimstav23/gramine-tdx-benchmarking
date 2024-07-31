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
  file_size=$(echo "$file_name" | cut -d'_' -f4 | cut -d'.' -f1)
  # get the numbers for every clients case
  while read -r line; do
    clients=$(echo "$line" | sed -E 's,^[^0-9]*([0-9]+).*$,\1,')
    throughput=$(echo "$line" | cut -d'=' -f6 )
    data["$file_size,$vm_type,$clients"]=$throughput
  done < $file

  if [[ ${#vm_type} -gt max_vm_type_length ]]; then
    max_vm_type_length=${#vm_type}
  fi
done

file_sizes=$(echo "${!data[@]}" | tr ' ' '\n' | cut -d',' -f1 | sort -u)
vm_types=$(echo "${!data[@]}" | tr ' ' '\n' | cut -d',' -f2 | sort -u)
clients_nums=$(echo "${!data[@]}" | tr ' ' '\n' | cut -d',' -f3 | sort -n -u)

# Output the results to csv
for file_size in $file_sizes; do
  for vm_type in $vm_types; do
    csv_file="$RESULTS_DIR/"$file_size"_"$vm_type".csv"
    # write the header of the csv
    printf "Clients," > $csv_file
    for clients in $clients_nums; do
      printf "%s," "$clients" >> $csv_file
    done
    truncate -s-1 $csv_file # remove last comma
    printf "\n" >> $csv_file

    printf "Throughput (requests/sec)," >> $csv_file
    for clients in $clients_nums; do
      key="$file_size,$vm_type,$clients"
      if [ -n "${data[$key]}" ]; then
        printf "%f," "${data[$key]}" >> $csv_file
      else
        printf "," >> $csv_file
      fi
    done
    truncate -s-1 $csv_file # remove last comma
    printf "\n" >> $csv_file
  done
done

# Pretty print the results to stdout
for file_size in $file_sizes; do
  printf "$file_size (measurements in reqs/sec)\n"
  header="VM Type\Benchmark clients"
  if [[ ${#header} -gt max_vm_type_length ]]; then
    max_vm_type_length=${#header}
  fi

  printf "%-${max_vm_type_length}s\t" "$header"
  for clients in $clients_nums; do
    printf "%s\t\t" "$clients"
  done
  printf "\n"

  for vm_type in $vm_types; do
    printf "%-${max_vm_type_length}s\t" "$vm_type"
    for clients in $clients_nums; do
      key="$file_size,$vm_type,$clients"
      if [ -n "${data[$key]}" ]; then
        printf "%f\t" "${data[$key]}"
      else
        printf "N/A\t"
      fi
    done
    printf "\n"
  done
done
