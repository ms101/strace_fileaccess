# Strace Fileaccess Monitoring Script

Monitor a program's file system access by collecting filenames that are being accessed and opened (sudo/root required)

Utilizes Linux strace to trace syscalls (access & openat)

### Usage
- `strace.sh -p [prozess name to attach to]`
- `strace.sh -s [prozess name to start strace with]`
- `strace.sh -c [output file for cleanup]` sort, dedup and beautify
- Writes all accessed files into a file (\$date-\$time_\$processname)
