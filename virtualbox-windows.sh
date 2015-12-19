#!/bin/bash

# instructions adapted from http://www.perkin.org.uk/posts/create-virtualbox-vm-from-the-command-line.html

# set the profile name
VM='Windows-10'

# set the location where the VM will be created
VM_DIR="${HOME}/VirtualBox VMs/$VM"

# set the path to the install ISO
ISO_PATH="${HOME}/Desktop/Win10_SingleLang_English_x64.iso"

# create the VM directory
mkdir "$VM_DIR"

# copy the installer ISO
cp "$ISO_PATH" "$VM_DIR/$(basename $ISO_PATH)"
ISO_PATH="$VM_DIR/$(basename $ISO_PATH)"

# create a new virtual disk
VBoxManage createhd --filename "$VM_DIR/$VM".vdi --variant fixed --size 32768

# attach the virtual disk
RAW_DISK=$(./vdi-attach.sh "$VM_DIR/$VM.vdi" | tail -n1)

# format the virtual disk
diskutil eraseDisk UFSD_NTFS "$VM" "$RAW_DISK"

# detach the virtual disk
hdiutil detach "$RAW_DISK"

# create an OSX 10.00 El Capitan x64 profile
VBoxManage createvm --register --name "$VM" --ostype Windows10_64

# create a new virtual SATA controller,  attach the virtual disk and installation iso
VBoxManage storagectl "$VM" --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage storageattach "$VM" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VM_DIR/$VM.vdi"
VBoxManage storageattach "$VM" --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium "$ISO_PATH"

# modify some system settings
VBoxManage modifyvm "$VM" --chipset piix3
VBoxManage modifyvm "$VM" --firmware efi
VBoxManage modifyvm "$VM" --memory 4096 --vram 128
VBoxManage modifyvm "$VM" --mouse usbtablet --keyboard usb

# start the VM
VBoxManage startvm "$VM" --type gui