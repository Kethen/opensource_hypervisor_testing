VM_PATH=/home/katharine/VMs/pts
vm_name=post_vm_id1

ip tuntap add name test_tap mode tap
ip link set test_tap master HOME_BRIDGE
ip link set test_tap down
ip link set test_tap up

acrn-dm -A -m 20480M --cpu_affinity 0,1,2,3 -s 0:0,hostbridge \
	-U d2795438-25d6-11e8-864e-cb7a18b34643 \
	-s 3:0,passthru,01/00/0,keep_gsi \
	-s 3:1,passthru,01/00/1 \
	-s 4,passthru,00/14/0,d3hot_reset \
	-s 5,virtio-blk,$VM_PATH/maindisk.img \
	-s 6,virtio-net,test_tap,mac=a2:0e:1f:c9:1c:d7 \
	--ovmf $VM_PATH/OVMF_acrn.fd \
	$vm_name
ip link del test_tap
