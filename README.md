# VirtualBox Windows Image - Creation Tool

Creating Virtual Machines can be a painful process, especially for those who don't have a strong background in system administration.

While there is a lot of good information to be found online, virtually every tutorial/guide requires a non-trivial amount of manual tweaking to get a working system up and running.

This project completely automates the process of creating a Windows virtual machine that will run on Apple hardware.

### Usage

```bash
./virtualbox-windows.sh [iso-path]
```

***[iso-path]*** - The path to the Windows install ISO


*Note: The script will output to `~/VirtualBox VMs/Windows-10`*

### How it works

1. The install ISO is copied to the VM directory
2. A VirtualBox VDisk file is created
3. The VDisk is attached (ie not mounted) as a fake physical disk
4. The VDisk is formatted as a NTFS volume
5. The VDisk is detached
5. A new VirtualBox VM is created with the VDisk + Windows-10.iso attached and a few 'sane' defaults

*Note: The VM will boot into the Windows installer. After installation is complete, don't forget to detach the install disc (ie `Windows-10.iso`).*

### Default Settings

- VDisk - 32GB (fixed)
- Architecture - x64
- Chipset - PIIX3
- BootType - EFI
- RAM - 4GB
- VRAM - 128MB

*Note: This setup has been verified on an iMac (Late2009). The settings are currently hardcoded in `virtualbox-windows.sh` if you need/want to make changes.* 

### Scripts

- `virtualbox-windows.sh`

  Creates a Windows virtualbox profile + vdisk image

- `vdi-attach.sh [vdi-path]`

  Attaches a VirtualBox VDI (Virtual Disk Image) as if it were a physical disk using fairy dust and magic

### Nerd Stuff

**[Puppies Farting Rainbows and a Bodybuilding Unicorn](http://i.imgur.com/BmGsO.jpg)**

Fairy dust and magic can be both wonderful and terrifying. Seeing a comment that says `// here be magic` is usually a really, really bad sign. Since you're still reading (such a trooper, you are) I'll attempt to explain the details of mounting a VDI as a fake disk sans any excessive 'hand waving'.

Mounting disk images is nothing new. At the OS level, it simply maps a new volume and uses the contents of the image as if it were raw disk data.

Virtual Disks don't work with standard mounting tools because they contain additional metadata at the head of the raw binary data. To make things more comples, the metadata length is not fixed.

The `vdi-attach.sh` script solves that issue by decoding the header length field using nothin but standard POSIX CLI tools.

To attach the disk, it calls `hdid` (ie the precursor to hdiutil) including an offset (calculated previously) where it can start reading the raw disk data.

*Note: While `hdiutil` is an obvious improvement from `hdid`, it would be really cool if they would add this functionality back in. `hdid` is officially deprecated so there's no telling how long until it's removed altogether.*
