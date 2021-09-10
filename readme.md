## Environment
- CPU: Intel(R) Core(TM) i5-6600 CPU
- Memory: 24GB in baremetal, 20GB in test vms
- GPU: ASUS NVIDIA GeForce GTX 1050 2GB

- KVM kernel version: 5.13.12-200.fc34.x86_64
- ACRN version: v2.5
- QEMU version: QEMU emulator version 5.2.0 (qemu-5.2.0-8.fc34)
- Cloud Hypervisor version: cloud-hypervisor v17.0-dirty

- Service vm/kvm runner userspace: Fedora 34 Minimal

KVM boot args:
```
set VMHOST_UUID=ad9ba2e5-bc77-4517-94ef-c41ca37f33f1
set EXTRA_OPTIONS='intel_pstate=disable kvm_intel.nested=n nvidia-drm.modeset=1'
set VM_OPTIONS='intel_iommu=on iommu=pt default_hugepagesz=1G hugepagesz=1G hugepages=20 video=efifb:off'
set VFIO='vfio-pci.ids=10de:1c81,10de:0fb9,8086:a12f'
search --no-floppy --set=root -u $VMHOST_UUID
linuxefi  /boot/vmlinuz root=UUID=$VMHOST_UUID $EXTRA_OPTIONS $VM_OPTIONS $VFIO
initrdefi /boot/initramfs.img
```

ACRN boot args:
```
set PCI_STUBS="pci_stub.ids=10de:1c81,10de:0fb9,8086:a12f"
set BOOT_ARGS="root=/dev/nvme0n1p3 console=ttyS0 idle=halt rw rootwait console=tty0 consoleblank=0 no_timer_check quiet loglevel=3 i915.nuclear_pageflip=1 swiotlb=131072 maxcpus=4 hugepagesz=1G hugepages=20 video=efifb:off"
set HVLOG="hvlog=2M@0xe00000 memmap=0xe00000$2M"
search --no-floppy --set=root -u ad9ba2e5-bc77-4517-94ef-c41ca37f33f1
multiboot2 /boot/acrn/acrn.bin root=PARTUUID="3985eead-24b8-4e92-90b3-92a874c2c181"
module2 /boot/acrn/bzImage Linux_bzImage $PCI_STUBS $BOOT_ARGS $HVLOG
```

ACRN vm mode: `non-rt post launched vm, cpu sharing with service vm`

pts runner boot args:
```
root=UUID=f531d555-d399-434b-a5e5-7329bdbe7457 intel_pstate=disable kvm_intel.nested=n nvidia-drm.modeset=1
```

pts runner kernel version: `Linux fedora 5.13.13-200.fc34.x86_64 #1 SMP Thu Aug 26 17:06:39 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux`

## Test Results
https://openbenchmarking.org/result/2109062-SCOO-MERGE8663

## Test Notes
- There is a noticible stutter while interacting with cloud-hypervisor's vm, it is somewhat observed on acrn as well but way less severe
- cloud-hypervisor outdid bare metal in memory testing somehow
- cloud-hypervisor currently does not support passing through more than one device from an iommu group, only the gpu was passed through
- acrn memory and cpu test has rather big deviations per run, likely a disadvantage of SCHED_BVT between service vm and test vm over linux process scheduler

## Conclusion
- when physical cpu has to be shared between kvm host/acrn service vm, kvm has an edge over acrn
- cloud-hypervisor currently introduces an odd stutter under certain loads

## Other notes
- qemu-affinity can be found on https://github.com/zegelin/qemu-affinity
