#!/bin/bash
# monitor a program's file system access by collecting filenames that are being accessed and opened
# utilizes Linux strace to trace syscalls (currently access & openat)

function usage() {
   echo "Usage:"
   echo -e "\t$0 -p [prozess name to attach to]"
   echo -e "\t$0 -s [prozess name to start strace with]"
   echo -e "\t$0 -c [output file for cleanup (sort, dedup and beautify)]"
   echo -e "Writes all accessed files into a file (\$date-\$time_\$processname)"
   exit 1
}

# argument given?
if [ $# -lt 1 ]
then
	usage
fi

date=`date +"%Y%m%d-%H%M"`
filename="${date}_${2}"

# attach strace to process name (first PID)
if [ $1 = "-p" ] && [ $# -eq 2 ]
then
	prog="$2"
	pid=`pgrep $2 | head -n1`
	echo "[*] attaching strace to $2 ($pid), writing to $filename, terminate with Ctrl+C"
	#sudo strace -p $pid 2>&1 | grep -E "openat|access" | tee "$filename"
	sudo strace -p $(pgrep "$prog" | head -n1) -e trace=openat,access 2>&1 | tee "$filename"

# start program via strace
elif [ $1 = "-s" ] && [ $# -eq 2 ]
then
	prog="$2"
	echo "[*] Starting $prog with strace, writing to $filename, terminate with Ctrl+C"
	#sudo strace "$prog" 2>&1 | grep -E "openat|access" | tee "$filename"
	sudo strace  "$prog" -e trace=openat,access 2>&1 | tee "$filename"

# cleanup an output file
elif [ $1 = "-c" ] && [ $# -eq 2 ]
then
	filename="$2"
	newfn="${filename}_clean"
	echo "[*] deduplicating and sorting output file $filename"
	sorted=$(grep -v strace "$filename" | sort | uniq -c | sort -r)

	echo -e "Count\tType\tFile" > "$newfn"

	oldifs=$IFS
	IFS=$'\n'
	
	for line in $sorted
	do
		line=$(echo "$line" | sed 's/^ *//g')
		count=$(echo "$line" | cut -d" " -f 1)
		type=$(echo "$line" | cut -d" " -f 2 | cut -d"(" -f 1)
		file=$(echo "$line" | cut -d"\"" -f 2)
		echo -e "$count\t$type\t$file" >> "$newfn"
	done

	echo "[*] done, results in $newfn"
	IFS=$oldifs
	less "$newfn"

else
	usage
fi
