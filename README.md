# PCIe Benchmarking for Real-Time Embedded Systems
Aaron Nyholm - z5316510

### Building Software
#### Requirements 
- [RTEMS](https://gitlab.rtems.org/rtems/rtos/rtems)
- [RTEMS LibBSD](https://gitlab.rtems.org/rtems/pkg/rtems-libbsd)

#### Configure
```
./waf configure --rtems-tools=<PATH TO RTEMS TOOLS> --rtems=<PATH TO RTEMS BSP>
```

#### Build
```
./waf
```

### Building Hardware
#### Requirements 
- Xilinx Vivado

#### Configure
Run `settings.sh` included in vivado install
```
source ./<Path to Xilinx install>/vivado/settings.sh
```

#### Build project
```
./Hog/Do CREATE endpoint
```

#### Open project
```
vivado ./Projects/endpoint/endpoint.xpr
```
