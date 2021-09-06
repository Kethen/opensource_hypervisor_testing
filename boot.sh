PLATFORM="-enable-kvm -cpu host -smp sockets=1,cores=4,threads=1 -M q35"
PLATFORM="$PLATFORM -m 20G -mem-path /dev/hugepages"
PLATFORM="$PLATFORM -global ICH9-LPC.disable_s3=1 -global ICH9-LPC.disable_s4=1"

FIRMWARE="-drive if=pflash,format=raw,file=OVMF_CODE.fd,readonly"
FIRMWARE="$FIRMWARE -drive if=pflash,format=raw,file=OVMF_VARS.fd"

NETWORK="-netdev tap,ifname=VM_TAP,id=eth0,script=no,downscript=no,vhost=on"
NETWORK="$NETWORK -device virtio-net,netdev=eth0,mac=a2:0e:1f:c9:1c:d7,bus=pcie.0,addr=1"

PASS="$PASS -device pcie-root-port,hotplug=false,id=root_port1,bus=pcie.0,slot=0,addr=4"
PASS="$PASS -device vfio-pci,host=01:00.0,romfile=vbios.rom,rombar=1,bus=root_port1,multifunction=on,addr=0.0"
PASS="$PASS -device vfio-pci,host=01:00.1,bus=root_port1,multifunction=on,addr=0.1"

PASS="$PASS -device vfio-pci,host=00:14.0,bus=pcie.0,addr=3"

MISC="-display none -vga none -nodefaults"
MISC="$MISC -name pts_vm,debug-threads=on"

STORAGE="-drive if=none,id=maindisk,format=raw,file=maindisk.img,discard=unmap,cache=directsync -object iothread,id=iomaindisk -device virtio-blk-pci,drive=maindisk,iothread=iomaindisk,bus=pcie.0,multifunction=on,addr=5.0"

bash ../shared_scripts/wait_for_devices

qemu-system-x86_64 $PLATFORM $FIRMWARE $NETWORK $PASS $STORAGE $SWAP $MISC "$@" &
PID=$!
echo qemu process with id $PID
while ! python3 ./qemu_affinity.py $PID -k 0 1 2 3
do
	echo retrying affinity set
	sleep 10
done
echo affinity set, waiting for main process to finish
echo ulimit -l is at $(ulimit -l)
echo I am $(id)
wait $PID
