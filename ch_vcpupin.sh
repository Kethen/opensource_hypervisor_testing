PID=$1
CPUS_LIST="$(echo $2 | sed 's/,/ /g')"

set -x

declare -a cpu_list
idx=0
for cpu in $CPUS_LIST
do
	cpu_list[idx]=$cpu
	idx=$((idx + 1))
done
cpu_count=$idx

vcpu_lines=""
set -e
while [ -z "$vcpu_lines" ]
do
	sleep 5
	vcpu_lines="$(ps -p $PID -L | grep vcpu)"
	cpus=$(echo "$vcpu_lines" | wc -l)
	if [ "$cpus" != "$cpu_count" ]
	then
		echo expected cpu count is $cpu_count, found $cpus cpus
		echo retrying...
		vcpu_lines=""
	fi
done

echo "$vcpu_lines" | while read -r line
do
	lwpid=$(echo $line | awk '{print $2}')
	cpu=$(echo $line | awk '{print $5}' | sed 's/vcpu//')
	taskset -c -p ${cpu_list[$cpu]} $lwpid
done


