VM_PATH=/home/katharine/VMs/pts

set -x

echo 0000:00:02.0 > /sys/bus/pci/devices/0000\:00\:02\.0/driver/unbind

cloud-hypervisor \
	--cpus boot=4 \
	--memory size=20480M,hugepages=on,hugepage_size=1G \
	--console off \
	`#--serial tty` \
	`#--device path=/sys/bus/pci/devices/0000:01:00.0/ path=/sys/bus/pci/devices/0000:01:00.1/ path=/sys/bus/pci/devices/0000:00:14.0/` \
	--device path=/sys/bus/pci/devices/0000:01:00.0/ path=/sys/bus/pci/devices/0000:00:14.0/ \
	--disk path=$VM_PATH/maindisk.img,num_queues=4 \
	--net tap=VM_TAP,mac=a2:0e:1f:c9:1c:d7,num_queues=2 \
	--kernel vmlinux-5.13 \
	--cmdline "root=UUID=f531d555-d399-434b-a5e5-7329bdbe7457 intel_pstate=disable kvm_intel.nested=n nvidia-drm.modeset=1" \
	--initramfs initramfs-5.13.13-200.fc34.x86_64.img &

echo VM process launched, now pinning vcpu

PID=$!
bash $VM_PATH/ch_vcpupin.sh $PID 0,1,2,3
wait $PID
