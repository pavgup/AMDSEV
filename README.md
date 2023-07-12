This repository contains scripts used to build a kernel + userspace to support
SEV-SNP isolated nested guests using KVM on Azure's DCa_cc_v5/ECa_cc_v5 instances.

## Deploy an Azure VM

A preconfigured VM image based on Ubuntu 20.04 has been published to a publicly accessible
community gallery for quick validation. The VM gallery image is present in East US.

Deploy the SNP host VM using azure cli:
```
az group create -g <group> -l eastus
az vm create -g <group> -n <name> \
  --image /CommunityGalleries/cocopreview-91c44057-c3ab-4652-bf00-9242d5a90170/Images/ubuntu2004-snp-host/Versions/latest \
  --accept-term --size Standard_DC8as_cc_v5 --accelerated-networking true
```

## Verify SNP functionality

Once the VM has been provisioned, ssh into it.

Check dmesg for correct SNP initialization in the SNP host VM:
```
$ uname -r
5.19.0-rc6-snp-host-46751c721588

$ sudo dmesg | grep -Ee 'SEV|SNP|ccp|kvm'
[    0.647052] SEV-SNP: RMP table physical address 0x00000008b7300000 - 0x00000008bfffffff
[    2.137453] ccp psp: sev enabled
[    2.137499] ccp psp: psp enabled
[    2.137501] ccp psp: enabled
[    2.143452] ccp psp: SEV: failed to INIT error 0x11, rc -5
[    2.145240] ccp psp: SEV-SNP API:1.42 build:42
[    2.446670] kvm: Nested Virtualization enabled
[    2.446671] SVM: kvm: Nested Paging enabled
[    2.446676] SEV supported: 0 ASIDs
[    2.446677] SEV-ES and SEV-SNP supported: 16 ASIDs
[    2.446678] SVM: kvm: Hyper-V enlightened NPT TLB flush enabled
[    2.446678] SVM: kvm: Hyper-V Direct TLB Flush enabled
```

Only SEV-SNP is supported, not SEV or SEV-ES (hence the "SEV: failed to init" error).

Double check support using snphost (https://github.com/virtee/snphost):
```
$ sudo snphost ok
[ PASS ] - AMD CPU
[ PASS ]   - Microcode support
[ PASS ]   - Secure Memory Encryption (SME)
[ PASS ]   - Secure Encrypted Virtualization (SEV)
[ PASS ]     - Encrypted State (SEV-ES)
[ PASS ]     - Secure Nested Paging (SEV-SNP)
[ PASS ]       - VM Permission Levels
[ PASS ]         - Number of VMPLs: 4
[ PASS ]     - Physical address bit reduction: 5
[ PASS ]     - C-bit location: 51
[ PASS ]     - Number of encrypted guests supported simultaneously: 16
[ PASS ]     - Minimum ASID value for SEV-enabled, SEV-ES disabled guest: 17
[ PASS ]     - Reading /dev/sev: /dev/sev readable
[ PASS ]     - Writing /dev/sev: /dev/sev writable
[ PASS ]   - Page flush MSR: ENABLED
[ PASS ] - KVM supported: API version: 12
[ PASS ]   - SEV enabled in KVM: enabled
[ PASS ]   - SEV-ES enabled in KVM: enabled
[ PASS ]   - SEV-SNP enabled in KVM: enabled
[ PASS ] - Memlock resource limit: Soft: 67108864 | Hard: 67108864
```

## Start Qemu SNP guest

A script is provided that boots an SNP isolated nested guest using qemu with
SNP support. Inspect the output for the required CLI flags.
```
$ sudo launch-qemu.sh -sev-snp -smp 1 -mem 1024
```

Login to the SNP isolateed nested guest using username `root` (no password)

Check dmesg for correct SEV-SNP initialization:
```
root@debian:~# dmesg | grep SEV
[    0.527729] Memory Encryption Features active: AMD SEV SEV-ES SEV-SNP
[    0.756045] SEV: Using SNP CPUID table, 31 entries present.
[    1.286659] SEV: SNP guest platform device initialized.
[    1.571301] sev-guest sev-guest: Initialized SEV guest driver (using vmpck_id 0)
```

Fetch SNP attestation report using `snpguest` (https://github.com/virtee/snpguest):
```
root@debian:~# snpguest report --random
root@debian:~# snpguest display report
Attestation Report (1184 bytes):
Version:                      2
Guest SVN:                    0

    Guest Policy (196608):
    ABI Major:     0
    ABI Minor:     0
    SMT Allowed:   1
    Migrate MA:    0
    Debug Allowed: 0
    Single Socket: 0
Family ID:
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

Image ID:
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

VMPL:                         1
Signature Algorithm:          1
Current TCB:

TCB Version:
  Microcode:   206
  SNP:         8
  TEE:         0
  Boot Loader: 3


Platform Info (1):
  TSME Enabled: 1
  SMT Enabled:  0

Author Key Encryption:        false
Report Data:
01 8e 35 b6 c4 01 28 f5 91 45 fe 8a 3b 34 d3 63
ac 57 c6 77 e5 ef ed ae 5e 34 07 c0 05 ce 3f 19
b8 e4 3f bb e7 a2 e6 03 4a d1 ec 7b 66 fd bd 0d
3c e5 45 6d 8b 24 97 4e 70 6e 09 2f 7a b3 30 59

Measurement:
b5 d1 00 7b 59 06 ca d0 5d 41 63 37 23 94 a3 cc
06 a3 d1 09 43 26 e4 30 41 53 dc 2d d9 b6 b2 e6
88 bf b7 00 08 9f 44 88 55 03 fb f4 dc 19 b8 0c

Host Data:
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

ID Key Digest:
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

Author Key Digest:
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

Report ID:
58 1d 06 30 4e cc 48 e5 d8 6f b9 ca b6 aa 29 3d
9a a6 5a 59 a7 0e c3 4b ed 54 81 f7 f6 8a 02 d0

Report ID Migration Agent:
ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff

Reported TCB:
TCB Version:
  Microcode:   115
  SNP:         8
  TEE:         0
  Boot Loader: 3

Chip ID:
ed 97 60 ac 8e 4f 51 82 2f e6 44 e0 6b 26 88 0d
56 ad b8 6f 46 13 60 4e 69 c4 db 9d b8 b2 a9 74
ed 2a a6 6b 60 a7 aa 4d 64 84 1b fc df 4c 52 0d
81 29 f2 cd ef 66 67 ca 79 a4 18 19 94 2b 03 ce

Committed TCB:

TCB Version:
  Microcode:   115
  SNP:         8
  TEE:         0
  Boot Loader: 3

Current Build:                4
Current Minor:                52
Current Major:                1
Committed Build:              4
Committed Minor:              52
Committed Major:              1
Launch TCB:

TCB Version:
  Microcode:   115
  SNP:         8
  TEE:         0
  Boot Loader: 3


Signature:
  R:
4c 3a 09 cc 5d ab 2e c1 6d bd ab 17 f2 ec da 78
1e 44 61 58 e2 88 38 e0 01 0f 6e b4 d8 66 c4 e1
44 5b b9 8a 40 b2 e5 2a b4 50 96 ee 2e 0d 95 2a
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00

  S:
ec 83 c4 28 7b 46 a0 44 de 3d 65 d4 df 57 f2 bd
ba ef a3 bc a5 ee a3 7b 34 99 88 31 9d c2 0f 93
e0 81 46 02 d6 5a 51 38 b9 6d 7d 0d 94 1b b5 19
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00
```

Verify the SNP attestation report signature and certificate chain:
```
root@debian:~# snpguest fetch vcek Milan .
root@debian:~# snpguest fetch ca Milan .
root@debian:~# snpguest verify signature .
VCEK signed the Attestation Report!
root@debian:~# snpguest verify certs .
The AMD ARK was self-signed!
The AMD ASK was signed by the AMD ARK!
The VCEK was signed by the AMD ASK!
```

## Building

Only the host VM kernel is different compared to AMD's reference stack for
baremetal SNP. The same SNP guest kernel/ovmf/qemu can be used as on baremetal.

For more details on building kernel/userspace refer to README-baremetal.md or
https://github.com/AMDESE/AMDSEV/tree/sev-snp-devel.

### Gallery

Install packer and then:

```
# export these variables before the build
export AZURE_SUBSCRIPTION_ID=...
export AZURE_RESOURCE_GROUP=...
cd packer
make resourcegroup
make gallery
make packer
```

### Kernel

Install docker and then:
```
# this builds the host VM kernel
./build-host.sh 

# this builds the SNP guest VM firmware/kernel/disk image + SNP capable qemu
./run.sh
```

These scripts exist for convenience and wrap the `./build.sh` build script.
