<!--
Title: How to benchmark server performance using Speedtest and SysBench
Description: Learn how to benchmark server performance using Speedtest and SysBench.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Reviewers:
Publication date: 2020-07-31T12:39:56.670Z
Listed: true
-->

# How to benchmark server performance using Speedtest and SysBench

[![How to benchmark server performance using Speedtest and SysBench](how-to-benchmark-server-performance-using-speedtest-and-sysbench.png)](https://www.youtube.com/watch?v=zcq2iZUcQQY "How to benchmark server performance using Speedtest and SysBench")

> Heads-up: Speedtest is known for tracking users therefore it is recommended to run the following benchmark tests on staging servers.

## Requirements

- Virtual private server (VPS) or dedicated server running Debian 10 (buster) or Debian 11 (bullseye)

## Caveats

- When copy/pasting commands that start with `$`, strip out `$` as this character is not part of the command
- When copy/pasting commands that start with `cat << "EOF"`, select all lines at once (from `cat << "EOF"` to `EOF` inclusively) as they are part of the same (single) command

## Setup guide

### Step 1: check if [backports](https://backports.debian.org/) repository is enabled

```shell
cat /etc/apt/sources.list | grep "backports"
```

### Step 2: enable backports repository (required if previous command returned nothing)

> Heads-up: run `cat /etc/debian_version` to find Debian version.

#### Debian 10 (buster)

```shell
cat << "EOF" >> /etc/apt/sources.list
deb http://deb.debian.org/debian buster-backports main
EOF
apt update
```

#### Debian 11 (bullseye)

```shell
cat << "EOF" >> /etc/apt/sources.list
deb http://deb.debian.org/debian bullseye-backports main
EOF
apt update
```

### Step 3: install apt-transport-https, cURL and GnuPG

```shell
apt update
apt install -y apt-transport-https curl gnupg2
```

### Step 4: import [Speedtest](https://www.speedtest.net/)’s PGP public key

```shell
curl -fsSL https://packagecloud.io/ookla/speedtest-cli/gpgkey | gpg --dearmor > /usr/share/keyrings/speedtest-cli.gpg
```

### Step 5: enable Speedtest’s repository

> Heads-up: run `cat /etc/debian_version` to find Debian version.

#### Debian 10 (buster)

```shell
echo -e "deb [signed-by=/usr/share/keyrings/speedtest-cli.gpg] https://packagecloud.io/ookla/speedtest-cli/debian/ buster main\ndeb-src [signed-by=/usr/share/keyrings/speedtest-cli.gpg] https://packagecloud.io/ookla/speedtest-cli/debian/ buster main" > /etc/apt/sources.list.d/speedtest-cli.list
apt update
```

#### Debian 11 (bullseye)

```shell
echo -e "deb [signed-by=/usr/share/keyrings/speedtest-cli.gpg] https://packagecloud.io/ookla/speedtest-cli/debian/ bullseye main\ndeb-src [signed-by=/usr/share/keyrings/speedtest-cli.gpg] https://packagecloud.io/ookla/speedtest-cli/debian/ bullseye main" > /etc/apt/sources.list.d/speedtest-cli.list
apt update
```

### Step 6: install Speedtest and SysBench

```shell
apt install -y speedtest sysbench
```

👍

---

## Usage guide

### Benchmark network

> Heads-up: depending on iptables or nftables firewall configuration, running following commands may be required.

#### iptables

```shell
iptables -A OUTPUT -p tcp -m tcp --dport 8080 -m state --state NEW -j ACCEPT
ip6tables -A OUTPUT -p tcp -m tcp --dport 8080 -m state --state NEW -j ACCEPT
```

#### nftables

> Heads-up: replace `firewall` if needed (see `nft list ruleset`).

```shell
nft add rule ip firewall output tcp dport http-alt accept
nft add rule ip6 firewall output tcp dport http-alt accept
```

```console
$ speedtest

   Speedtest by Ookla

     Server: Siminn - Reykjavik (id = 4818)
        ISP: 1984 ehf
    Latency:     0.49 ms   (0.05 ms jitter)
   Download:   955.03 Mbps (data used: 431.6 MB )
     Upload:   994.20 Mbps (data used: 1.6 GB )
Packet Loss:     0.0%
 Result URL: https://www.speedtest.net/result/c/f2a1be73-563e-450f-a447-0e591c19bff4
```

Network download speed: 3158.53 Mbps

Network upload speed: 3336.34 Mbps

👍

### Benchmark CPU

> Heads-up: use `--threads` to use multiple cores concurrently.

```console
$ sysbench cpu run
sysbench 1.0.20 (using system LuaJIT 2.1.0-beta3)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time


Prime numbers limit: 10000

Initializing worker threads...

Threads started!

CPU speed:
    events per second:  4368.44

General statistics:
    total time:                          10.0001s
    total number of events:              43687

Latency (ms):
         min:                                    0.23
         avg:                                    0.23
         max:                                    2.04
         95th percentile:                        0.23
         sum:                                 9993.84

Threads fairness:
    events (avg/stddev):           43687.0000/0.00
    execution time (avg/stddev):   9.9938/0.00
```

CPU events per second: 4368.44

👍

### Benchmark memory

```console
$ sysbench memory run
sysbench 1.0.20 (using system LuaJIT 2.1.0-beta3)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time


Running memory speed test with the following options:
  block size: 1KiB
  total size: 102400MiB
  operation: write
  scope: global

Initializing worker threads...

Threads started!

Total operations: 63969454 (6396521.91 per second)

62470.17 MiB transferred (6246.60 MiB/sec)


General statistics:
    total time:                          10.0001s
    total number of events:              63969454

Latency (ms):
         min:                                    0.00
         avg:                                    0.00
         max:                                    0.63
         95th percentile:                        0.00
         sum:                                 4409.21

Threads fairness:
    events (avg/stddev):           63969454.0000/0.00
    execution time (avg/stddev):   4.4092/0.00
```

Memory speed: 6246.60 MiB/sec

👍

### Benchmark disk

```console
$ sysbench fileio --file-total-size=8G prepare
sysbench 1.0.18 (using system LuaJIT 2.1.0-beta3)

128 files, 65536Kb each, 8192Mb total
Creating files for the test...
Extra file open flags: (none)
Creating file test_file.0
…
Creating file test_file.127
8589934592 bytes written in 81.85 seconds (100.09 MiB/sec).

$ sysbench fileio --file-test-mode=rndrw run
sysbench 1.0.20 (using system LuaJIT 2.1.0-beta3)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time


Extra file open flags: (none)
128 files, 16MiB each
2GiB total file size
Block size 16KiB
Number of IO requests: 0
Read/Write ratio for combined random IO test: 1.50
Periodic FSYNC enabled, calling fsync() each 100 requests.
Calling fsync() at the end of test, Enabled.
Using synchronous I/O mode
Doing random r/w test
Initializing worker threads...

Threads started!


File operations:
    reads/s:                      4261.49
    writes/s:                     2840.93
    fsyncs/s:                     9091.61

Throughput:
    read, MiB/s:                  66.59
    written, MiB/s:               44.39

General statistics:
    total time:                          10.0097s
    total number of events:              161976

Latency (ms):
         min:                                    0.00
         avg:                                    0.06
         max:                                   10.82
         95th percentile:                        0.14
         sum:                                 9969.51

Threads fairness:
    events (avg/stddev):           161976.0000/0.00
    execution time (avg/stddev):   9.9695/0.00

$ sysbench fileio cleanup
sysbench 1.0.20 (using system LuaJIT 2.1.0-beta3)

Removing test files...
```

Disk read throughput: 66.59 MiB/s

Disk write throughput: 44.39 MiB/s

👍
