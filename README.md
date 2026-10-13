# PCIe Benchmarking for Real-Time Embedded Systems
Aaron Nyholm - z5316510

### Building Software
#### Requirements 
- [RTEMS](https://gitlab.rtems.org/rtems/rtos/rtems)
- [RTEMS LibBSD](https://gitlab.rtems.org/rtems/pkg/rtems-libbsd)

#### Configure
```
./waf configure --rtems-tools=<PATH TO RTEMS TOOLS> --rtems=<PATH TO RTEMS BSP> --build=software
```

#### Build
```
./waf
```

### Building Hardware
#### Requirements 
- Xilinx Vivado 2025.1

#### Configure
Run `settings.sh` included in vivado install
```
source ./<Path to Xilinx install>/vivado/settings.sh
```

Configure waf
```
./waf distclean configure --build=hardware
```
It's recommended to setup and use a python venv for waf.

#### Build project
Run the following to build the endpoint image.
```
./waf build_ep
```

Run the following to build to root port PL image.
(note: this image does not include a PCIe host controller. This project uses
 the hard IP in the ZynqMP for the host port)
```
./waf build_pl
```
