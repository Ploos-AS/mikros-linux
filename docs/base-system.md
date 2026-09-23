# Base system design

MikrOS Linux uses a deliberately small, conventional Unix-like base. The goal is to remain understandable on old hardware and scriptable on modern build hosts.

## Init

The M0 default is **BusyBox init**.

Reasons:

- already present in the base userspace;
- extremely small;
- simple inittab/script model;
- no additional runtime dependency;
- suitable across the initial architecture set.

MikrOS does not use systemd in the minimum/base profiles.

A later profile may qualify another small init when it provides a concrete benefit, but the boot contract must remain simple.

## Boot sequence

Initial model:

1. kernel starts;
2. root filesystem mounts;
3. BusyBox init reads `/etc/inittab`;
4. `/etc/init.d/rcS` performs early system setup;
5. configured services are started;
6. console getty/login or shell becomes available.

The M0 image should keep boot scripts POSIX-shell compatible where practical.

## Filesystem layout

Use a conventional compact Linux hierarchy:

```
/
├── bin
├── dev
├── etc
│   ├── init.d
│   └── mikros
├── home
├── lib
├── mnt
├── proc
├── root
├── run
├── sbin
├── sys
├── tmp
├── usr
│   ├── bin
│   ├── lib
│   └── sbin
└── var
    ├── lib
    ├── log
    └── run
```

Do not create directories or compatibility symlinks without a demonstrated need on the target.

## Configuration

MikrOS configuration is plain text.

Distribution-specific configuration belongs under `/etc/mikros/`. Standard software should continue to use its conventional configuration locations rather than being patched merely to fit a MikrOS namespace.

## Profiles

### minimal

The smallest useful recovery/embedded system.

Expected capabilities:

- boot to console;
- shell;
- essential filesystem/process commands;
- mount/umount;
- `/proc` and `/sys` where applicable;
- basic device management suitable for the target;
- shutdown/reboot;
- enough tooling to inspect and repair the system.

Networking is not required.

### base

The normal MikrOS installation.

Includes `minimal`, plus:

- persistent user/login support;
- basic networking;
- DNS resolver configuration;
- DHCP/static network configuration where supported;
- logging appropriate to the machine;
- basic text editor;
- archive/compression utilities selected by footprint;
- package/install tooling once M3 defines it.

### net

A later extension of `base` for network-centric machines and appliances.

### dev

Development/debugging tools where target resources make local development sensible. Cross-development remains the preferred workflow for the smallest systems.

## Service policy

No daemon runs merely because a package was installed.

Profiles explicitly enable required services. Services should be individually disableable and configured through small shell-friendly files.

## Device management

Do not assume a full desktop-oriented dynamic device stack. M0 starts with kernel devtmpfs/static-device approaches appropriate to each target and adds complexity only when qualification demonstrates a need.

## Logging

Logging must scale down. A minimal target may use kernel/BusyBox logging with bounded or volatile storage. Persistent logging is profile-specific and must not exhaust small disks or flash devices.

## M0 base-system exit criteria

The base-system design is qualified when at least one Tier-1 architecture can reproducibly boot the `minimal` profile and:

- run the expected shell/core commands;
- mount pseudo-filesystems;
- execute the init sequence;
- provide a console;
- halt/reboot cleanly;
- report measured kernel, rootfs and runtime-memory footprints.
