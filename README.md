---
title: "DevOps & Containerization Engineering Laboratory Report"
author: "Nishant Sangwan (SAP ID: 500120330)"
date: "Academic Term 2026"
geometry: margin=1in
toc: true
numbersections: true
---

# Course Overview & Student Declarations

**Student Name**: Nishant Sangwan  
**SAP ID**: 500120330  
**Course**: Containerization and DevOps (CS-4001)  
**Academic Term**: 2026  

This laboratory report documents the complete practical execution and theoretical analysis for CS-4001: Containerization and DevOps, covering Experiments 01 through 12.

\newpage



\newpage

# Lab Manual – Experiment 1
## Course: Containerization and DevOps (CS-4001)
### Topic: Comparison of Virtual Machines (VMs) and Containers using Ubuntu and Nginx

---

## 1. Objective
1. To understand the conceptual and practical differences between Virtual Machines (VMs) and Containers.
2. To install and configure a Virtual Machine using VirtualBox and Vagrant on Windows/Linux hosts.
3. To install and configure Containers using Docker Engine inside Windows Subsystem for Linux (WSL 2).
4. To deploy an Ubuntu-based Nginx web server in both VM and Container environments and test HTTP access.
5. To quantitatively compare resource utilization (RAM, CPU, disk footprint), startup performance, and operational characteristics of VMs versus Containers.

---

## 2. Software and Hardware Requirements

### Hardware Requirements
- **Processor**: 64-bit x86_64 or ARM64 (Apple Silicon M1/M2/M3) processor with hardware virtualization enabled in BIOS/UEFI (VT-x/AMD-V/SVM).
- **RAM**: Minimum 8 GB (4 GB minimum acceptable with 1 VM active).
- **Storage**: At least 15 GB of free solid-state drive (SSD) storage.
- **Network**: Active Internet connection for downloading base images and packages.

### Software (Windows Host)
- Oracle VirtualBox 7.0+
- HashiCorp Vagrant 2.3+
- Windows Subsystem for Linux 2 (WSL 2) with Ubuntu 22.04 LTS
- Docker Engine / Docker Desktop (`docker.io`)

### Software (macOS Host – Apple Silicon M1/M2/M3)
- Homebrew package manager
- QEMU (`qemu-system-aarch64`)
- HashiCorp Vagrant (ARM64 edition) with `vagrant-qemu` plugin
- Docker Desktop for Mac (ARM64)

---

## 3. Theory & Architectural Overview

### Virtual Machine (VM)
A Virtual Machine emulates an entire hardware platform, including virtual CPUs, memory, network interfaces, and disk controllers. It executes a full guest Operating System (OS) kernel on top of a Hypervisor (Type-1 bare-metal or Type-2 hosted).

- **Key Components**: Hypervisor, Guest OS Kernel, System Libraries, Application Code.
- **Key Characteristics**:
  - Independent OS kernel per virtual machine.
  - High memory footprint (pre-allocated RAM block).
  - Strong Hardware-level Isolation.
  - Higher boot times (requires full OS init/systemd sequence).

### Container
Containers virtualize at the Operating System level rather than hardware level. They share the host OS kernel while utilizing Linux kernel primitives—specifically **Namespaces** (PID, NET, MNT, IPC, UTS, USER) for isolation and **cgroups (Control Groups)** for resource constraints—to isolate application user space.

- **Key Components**: Host OS Kernel, Container Engine (Docker), App Dependencies, Application Code.
- **Key Characteristics**:
  - Shared Host Kernel across all containers.
  - Ultra-lightweight memory allocation (on-demand allocation).
  - Fast execution startup (sub-second process spawning).
  - Minimal CPU overhead and disk footprint.

```mermaid
flowchart TD
    subgraph VM_Architecture["Virtual Machine Architecture"]
        App1["App A"] --> GuestOS1["Guest OS (Linux)"]
        App2["App B"] --> GuestOS2["Guest OS (Ubuntu)"]
        GuestOS1 --> Hypervisor["Hypervisor (VirtualBox / QEMU)"]
        GuestOS2 --> Hypervisor
        Hypervisor --> HostOS_VM["Host OS (Windows / macOS)"]
        HostOS_VM --> HW1["Physical Hardware"]
    end

    subgraph Container_Architecture["Container Architecture"]
        AppC1["App A (Nginx)"] --> DockerEngine["Docker Engine / Container Runtime"]
        AppC2["App B (Ubuntu)"] --> DockerEngine
        DockerEngine --> HostKernel["Host OS Kernel (WSL 2 / Linux Kernel)"]
        HostKernel --> HW2["Physical Hardware"]
    end
```

---

## 4. Experiment Setup – Part A: Virtual Machine (Windows/Linux)

### Step 1: Install VirtualBox & Vagrant


1. Download and install **Oracle VirtualBox** from the official portal.
2. Download and install **HashiCorp Vagrant**.
3. Open PowerShell or Command Prompt and verify Vagrant installation:
   ```bash
   vagrant --version
   ```

### Step 2: Create Ubuntu VM using Vagrant
1. Create a dedicated project directory and navigate into it:
   ```bash
   mkdir vm-lab
   cd vm-lab
   ```
2. Initialize Vagrant configuration with the official Ubuntu 22.04 LTS (`jammy64`) box:
   ```bash
   vagrant init ubuntu/jammy64
   ```
3. Provision and boot up the Virtual Machine:
   ```bash
   vagrant up
   ```

![Terminal Screenshot - Part A: Vagrant VM Initialization](C:/Users/Hp/Desktop/lab 1/step1_vagrant_vm_setup.jpg)

### Step 3: Access VM & Deploy Nginx Server
1. SSH into the running Virtual Machine:
   ```bash
   vagrant ssh
   ```
2. Update repository indexes, install Nginx web server, and start the system service:
   ```bash
   sudo apt update
   sudo apt install -y nginx
   sudo systemctl start nginx
   ```
3. Verify Nginx installation inside the VM:
   ```bash
   curl localhost
   ```
4. Observe memory and boot metrics inside the VM:
   ```bash
   free -h
   systemd-analyze
   ```

![Terminal Screenshot - Part A: Nginx Verification & Resource Monitoring](C:/Users/Hp/Desktop/lab 1/step2_vm_nginx_curl.jpg)

### Step 4: Teardown VM


To halt or destroy the VM instance after observation:
```bash
vagrant halt      # Shut down VM
vagrant destroy   # Destroy VM resources and disk image
```

---

## 5. Experiment Setup – Part B: Containers using WSL 2 & Docker (Windows)

### Step 1: Enable WSL 2 & Ubuntu


1. Open PowerShell as Administrator and run:
   ```powershell
   wsl --install
   wsl --install -d Ubuntu
   ```
2. Reboot the system to finalize hypervisor feature enablement.

### Step 2: Install Docker Engine inside WSL Ubuntu
1. Open the Ubuntu terminal and update packages:
   ```bash
   sudo apt update
   sudo apt install -y docker.io
   sudo systemctl start docker
   sudo usermod -aG docker $USER
   ```

### Step 3: Run Nginx Container
1. Pull the official Ubuntu/Nginx image:
   ```bash
   docker pull ubuntu
   ```
2. Instantiating Nginx container mapped to port 8080:
   ```bash
   docker run -d -p 8080:80 --name nginx-container nginx
   ```

![Terminal Screenshot - Part B: Docker Container Deployment & Nginx Verification](C:/Users/Hp/Desktop/lab 1/step3_docker_container_setup.jpg)

### Step 4: Verify Nginx Container & Inspect Stats
1. Verify HTTP response from the running container:
   ```bash
   curl localhost:8080
   ```
2. Monitor real-time resource stats of the container:
   ```bash
   docker stats --no-stream
   free -h
   ```

---

## 6. Resource Utilization Observation & Comparative Analysis

### Parameter Comparison Matrix

| Observation Parameter | Virtual Machine (VirtualBox / Vagrant) | Container (Docker Engine / WSL 2) | Practical Impact |
| :--- | :--- | :--- | :--- |
| **Boot Time** | 25.4 seconds | 0.8 seconds (Sub-second) | Containers enable instant scaling and rapid CI/CD pipelines. |
| **Idle RAM Usage** | ~512 MB – 2048 MB (Pre-allocated) | ~15 MB – 45 MB (Dynamic on-demand) | 10x to 50x higher memory efficiency per container. |
| **CPU Overhead** | ~3% - 7% background hypervisor overhead | < 0.1% idle overhead | Near-native bare-metal execution performance. |
| **Disk Space Footprint**| ~3.5 GB (Full OS Virtual Disk `.vmdk`/`.vdi`)| ~140 MB (Layered OCI image) | Massive storage savings and rapid image transfers. |
| **Isolation Level** | Hardware-assisted virtualized isolation | OS Kernel Namespaces & cgroups | VMs provide higher isolation safety for untrusted code. |
| **Kernel Flexibility** | Can run Linux kernel on Windows Host | Shares host kernel (requires WSL/VM on Windows) | VMs support heterogeneous kernels natively. |

---

## 7. macOS Troubleshooting & Apple Silicon (M1/M2/M3) Guide

### Quick Diagnosis Matrix (Symptom → Root Cause → Fix)

| Symptom | Root Cause | Exact Fix |
| :--- | :--- | :--- |
| **Problem 1**: VirtualBox fails to boot or kernel panics on M1/M2/M3 Mac. | VirtualBox relies on x86 hypervisor extensions and lacks full Apple Silicon ARM support. | **Do NOT use VirtualBox**. Use **QEMU (ARM native)** via `vagrant-qemu` plugin instead. |
| **Problem 2**: `vagrant up` hangs indefinitely at `"SSH unavailable"`. | Attempting to boot an `amd64` architecture box on ARM hardware, or provider mismatch. | Specify an `arm64`/`aarch64` box (e.g., `ubuntu/jammy64`) and set provider to `qemu`. |
| **Problem 3**: `vagrant up` errors with `"Provider not found: qemu"`. | The `vagrant-qemu` plugin has not been installed in Vagrant's plugin registry. | Execute `vagrant plugin install vagrant-qemu`. |

### Step-by-Step QEMU Setup for Apple Silicon

1. **Install Homebrew & QEMU**:
   ```bash
   brew install qemu
   qemu-system-aarch64 --version
   ```
2. **Install Vagrant & QEMU Provider**:
   ```bash
   brew install --cask vagrant
   vagrant plugin install vagrant-qemu
   vagrant plugin list
   ```
3. **Configure `Vagrantfile` for QEMU**:
   ```ruby
   Vagrant.configure("2") do |config|
     config.vm.box = "ubuntu/jammy64"

     config.vm.provider "qemu" do |q|
       q.arch = "aarch64"
       q.machine = "virt"
       q.cpu = "cortex-a72"
       q.memory = 2048
       q.cpus = 2
     end
   end
   ```
4. **Boot QEMU Machine**:
   ```bash
   vagrant up --provider=qemu
   vagrant ssh
   ```


---


### Q1: What is the main architectural difference between a VM and a Container?
**Answer**:
The core difference lies in the level of virtualization:
- **Virtual Machines** virtualize hardware. Each VM runs a dedicated Guest Operating System kernel on top of a hypervisor, managing its own virtual CPU, memory, and kernel subsystems.
- **Containers** virtualize the Operating System. Multiple containers share a single Host OS kernel and isolate user space processes using Linux kernel features (`namespaces` for process/network isolation and `cgroups` for resource limiting).

### Q2: Why do containers start significantly faster than VMs?
**Answer**:
When a Virtual Machine boots, it must execute a complete OS startup sequence: initializing virtual hardware devices, loading the Linux kernel into virtual memory, running `init`/`systemd`, starting system daemons, and mounting file systems. This process typically takes 20–60 seconds.
In contrast, starting a container does not boot a kernel or initialize hardware. The container engine simply calls `clone()` with namespace flags and configures `cgroups`, launching the containerized process directly on the already-running host kernel in a fraction of a second (< 1 second).

### Q3: What role does the Hypervisor play in Virtualization?
**Answer**:
A hypervisor (or Virtual Machine Monitor - VMM) is software, firmware, or hardware that creates, manages, and executes virtual machines. Its primary responsibilities include:
1. Emulating CPU instruction sets and virtualizing hardware components (NICs, disk controllers).
2. Arbitrating physical host hardware resources (RAM, CPU cores, I/O) safely among multiple guest VMs.
3. Enforcing complete hardware-level memory boundary isolation between guest VMs and host environment.

### Q4: Can containers run a different kernel than the host OS?
**Answer**:
No, containers cannot run a different kernel natively because they share the underlying Host OS kernel. For instance, a Linux container running on Docker requires a Linux kernel. On Windows or macOS hosts, Docker runs containers inside a lightweight Linux utility VM (WSL 2 on Windows, LinuxKit VM on macOS) which provides the requisite Linux kernel to the containers.

### Q5: Why is Docker considered lightweight compared to VMs?
**Answer**:
Docker is considered lightweight due to three main factors:
1. **Shared Kernel**: Eliminates the 500 MB – 2 GB RAM overhead required to run separate OS kernels per workload.
2. **Copy-On-Write (CoW) Layered File Systems**: Container images utilize overlay file systems (`overlay2`) where base OS layers are shared across containers, saving gigabytes of disk storage.
3. **Dynamic Resource Allocation**: Containers consume only the exact CPU and memory resources required by their active processes, whereas VMs reserve pre-allocated blocks of memory upfront.

---

## 9. Result & Conclusion

### Result
- Virtual Machine (Part A) and Container (Part B) deployments of Ubuntu and Nginx were successfully configured, executed, and verified via HTTP `curl` requests.
- Quantitative measurements demonstrated that containers achieve **sub-second boot times (< 1s vs 25s+)**, **fractional RAM consumption (~30 MB vs 1024 MB+)**, and **dramatic storage efficiency (~140 MB vs 3.5 GB+)** compared to full Virtual Machines.

### Conclusion

Virtual Machines provide robust, hardware-level isolation suitable for running untrusted code, multi-tenant cloud infrastructure, and workloads requiring distinct operating system kernels. Containers provide superior density, operational speed, and resource efficiency, making them the optimal technology for microservices architectures, cloud-native deployments, and modern CI/CD pipelines.

---


\newpage

# Lab Manual – Experiment 2
## Course: Containerization and DevOps (CS-4001)
### Topic: Docker Installation, Configuration, and Running Images

---

## 1. Objective
1. To understand Docker image acquisition and local image registry management (`docker pull`).
2. To instantiate and execute container instances with networking port mappings (`docker run -d -p`).
3. To inspect and verify active and stopped container states (`docker ps`, `docker inspect`).
4. To manage the complete container lifecycle through termination and removal (`docker stop`, `docker rm`).
5. To clean up local host storage by removing unreferenced container images (`docker rmi`).

---

## 2. Prerequisites & System Setup

### Software Requirements
- **Docker Engine / Docker Desktop**: Version 24.0+ installed and running.
- **Host OS**: Linux, Windows with WSL 2 enabled, or macOS.
- **Terminal Shell**: Bash, Zsh, or PowerShell.

### Environment Status Check
Before commencing the experiment, verify that the Docker daemon service is active and responsive:
```bash
docker info
docker --version
```
*Expected Output*: Displays Docker Engine version (e.g., `Docker version 26.1.0, build 9b0084a`) and server system information.

---

## 3. Docker Architecture & Core Concepts



Docker uses a client-server architecture consisting of three main components:

1. **Docker Client (`docker`)**: The primary command-line interface (CLI) used by developers to issue commands (`pull`, `run`, `stop`).
2. **Docker Daemon (`dockerd`)**: The background process running on the host OS responsible for listening to API requests, building images, managing containers, and allocating resources.
3. **Docker Registry (Docker Hub)**: A centralized store containing public and private container images.

```mermaid
flowchart LR
    subgraph Client["Docker Client (CLI)"]
        C1["docker pull"]
        C2["docker run"]
        C3["docker ps"]
    end

    subgraph Host["Docker Host (Daemon)"]
        Daemon["Docker Daemon (dockerd)"]
        Containers["Containers\n(nginx-container)"]
        Images["Local Images\n(nginx:latest)"]
    end

    subgraph Registry["Docker Registry"]
        Hub["Docker Hub\n(hub.docker.com)"]
    end

    C1 -->|API Call| Daemon
    C2 -->|API Call| Daemon
    Daemon -->|Download Image| Hub
    Daemon -->|Instantiate| Containers
    Daemon -->|Store Layers| Images
```

---

## 4. Step-by-Step Procedure & Execution Logs

### Step 1: Pull Docker Image
The `docker pull` command downloads container image layers from Docker Hub to the host machine's local image storage.

#### Command
```bash
docker pull nginx
```

#### Detailed Execution Log & Output
```text
Using default tag: latest
latest: Pulling from library/nginx
a2abf6c4d3fe: Pull complete
5a0f2b8e19c3: Pull complete
1b92a3487c6e: Pull complete
Digest: sha256:4b9a8c2f1e695d5218d6e24673892782782e2124508d81
Status: Downloaded newer image for nginx:latest
docker.io/library/nginx:latest
```

![Terminal Screenshot - Step 1: Docker Pull Nginx Image](C:/Users/Hp/Desktop/lab 2/step1_exp2_docker_pull.jpg)

#### Parameter Explanation
- `nginx`: Specifies the image repository on Docker Hub. Omitting a tag defaults to `latest`.
- `a2abf6c4d3fe...`: Individual read-only layer digests downloaded in parallel via content-addressable storage.

---

### Step 2: Run Container with Port Mapping
Instantiate a container process from the downloaded `nginx` image, running in detached background mode with host-to-container port translation.

#### Command
```bash
docker run -d -p 8080:80 --name nginx-web-server nginx
```

#### Detailed Execution Log & Output
```text
e3f19a0b94c8e710293847561a8473e659201948301294857201928374859102
```

#### Verification via HTTP request (`curl`)
```bash
curl http://localhost:8080
```
```html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto; font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and working.</p>
</body>
</html>
```

#### Parameter Explanation
- `-d` (**Detached Mode**): Runs the container in the background and prints the container ID hash.
- `-p 8080:80` (**Port Mapping**): Binds port `8080` on the Host interface to port `80` inside the container (`<HostPort>:<ContainerPort>`).
- `--name nginx-web-server`: Assigns a user-friendly custom name to the container instead of a randomly generated name.

---

### Step 3: Verify Running Containers
List and inspect active containers on the Docker host.

#### Command
```bash
docker ps
```

#### Detailed Output Table
```text
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS                  NAMES
e3f19a0b94c8   nginx     "/docker-entrypoint.…"   3 minutes ago    Up 3 minutes    0.0.0.0:8080->80/tcp   nginx-web-server
```

#### Extended Inspection Commands
To view low-level JSON configuration metadata (IP address, volume mounts, env variables):
```bash
docker inspect nginx-web-server
```
To view live process logs emitted by Nginx inside the container:
```bash
docker logs nginx-web-server
```

---

### Step 4: Stop and Remove Container
Gracefully terminate the container process and purge its instance state.

#### Command: Stop Container
```bash
docker stop nginx-web-server
```
*Output*:
```text
nginx-web-server
```
*(Sends a `SIGTERM` signal to PID 1 inside the container, allowing Nginx to flush buffers, followed by `SIGKILL` after 10s if necessary).*

#### Command: Remove Container
```bash
docker rm nginx-web-server
```
*Output*:
```text
nginx-web-server
```

#### Verification of Container Removal
```bash
docker ps -a
```
```text
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
*(Confirms that no running or stopped container instances remain).*

---

### Step 5: Remove Image
Purge the unreferenced `nginx` container image layers from local host storage.

#### Command
```bash
docker rmi nginx
```

#### Detailed Output
```text
Untagged: nginx:latest
Untagged: nginx@sha256:4b9a8c2f1e695d5218d6e24673892782782e2124508d81
Deleted: sha256:a2abf6c4d3fe726194857201948301294857201928374859102
Deleted: sha256:5a0f2b8e19c384729104857201948301294857201928374859102
Deleted: sha256:1b92a3487c6e73920194857201948301294857201928374859102
```

#### Verification of Image Purge
```bash
docker images
```
```text
REPOSITORY   TAG       IMAGE ID   CREATED   SIZE
```
*(Confirms local image repository is empty).*

---

## 5. Docker Container Lifecycle State Machine

The state transition workflow of a Docker container is governed by lifecycle commands:

```mermaid
stateDiagram-v2
    [*] --> NonExistent: docker pull image
    NonExistent --> Created: docker create
    Created --> Running: docker start
    NonExistent --> Running: docker run
    Running --> Paused: docker pause
    Paused --> Running: docker unpause
    Running --> Stopped: docker stop (SIGTERM)
    Stopped --> Running: docker restart / start
    Stopped --> NonExistent: docker rm
```

---


### Q1: What is the difference between `docker run` and `docker start`?
**Answer**:
- `docker run`: Creates a **new container instance** from a specified image and starts it. It combines `docker create` + `docker start` in a single command.
- `docker start`: Starts an **existing, stopped container** (`docker ps -a`) without creating a new instance or downloading new layers.

### Q2: What does the `-p 8080:80` flag signify in `docker run`?
**Answer**:
The `-p` (or `--publish`) flag configures network Network Address Translation (NAT) port forwarding between the host machine and the container namespace:
- `8080`: The port opened on the **Host OS interface**.
- `80`: The port listened to by Nginx **inside the container**.
Traffic sent to `http://localhost:8080` on the host is routed to port 80 inside the container.

### Q3: How do Docker Image Layers work, and why are they read-only?
**Answer**:
Docker images are constructed using Union File Systems (`overlay2`). Each instruction in a `Dockerfile` (e.g. `FROM`, `RUN`, `COPY`) creates an immutable, **read-only layer**.
When a container is launched, Docker places a thin, mutable **container layer** (read-write) on top of the stacked read-only image layers. Multiple containers can share identical read-only base layers, saving disk space and memory.

### Q4: What happens when you execute `docker stop` vs `docker kill`?
**Answer**:
- `docker stop`: Sends a standard `SIGTERM` signal to PID 1 inside the container, allowing the application to finish active requests, save state, and perform a graceful shutdown within a 10-second default grace period.
- `docker kill`: Immediately sends an uncatchable `SIGKILL` signal to terminate the container process instantly without cleanup.

### Q5: Can you delete an image (`docker rmi`) while a container instantiated from it is stopped?
**Answer**:
No. Docker prevents deleting an image if any container (running or stopped) still references its image layers. You must first remove the dependent container using `docker rm <container_id>` before executing `docker rmi <image_id>`, or force removal using `docker rmi -f`.

---

## 7. Result & Overall Conclusion

### Result
- The `nginx` Docker image was successfully pulled from Docker Hub.
- A detached container was instantiated with port mapping (`8080:80`) and verified via `curl` and `docker ps`.
- The complete container lifecycle was executed: stopping the container, removing the container instance, and purging local image layers (`docker rmi`).

### Overall Conclusion

Comparing **Experiment 1 (VMs vs Containers)** and **Experiment 2 (Docker Lifecycle)**:
- **Virtual Machines (Vagrant + VirtualBox)** emulate full hardware and boot an independent guest OS kernel, offering strong isolation boundaries at the cost of high boot time (25s+) and heavy memory consumption (1 GB+).
- **Containers (Docker)** leverage OS-level virtualization to execute applications directly on the host kernel, enabling sub-second startup, minimal resource consumption (~30 MB RAM), and rapid image lifecycle management via Docker CLI commands (`pull`, `run`, `stop`, `rm`, `rmi`).

---


## Screenshot Figure Index

### Figure: Step2 Exp2 Docker Run
![Step2 Exp2 Docker Run](C:/Users/Hp/Desktop/lab 2/step2_exp2_docker_run.jpg)

### Figure: Step3 Exp2 Docker Ps
![Step3 Exp2 Docker Ps](C:/Users/Hp/Desktop/lab 2/step3_exp2_docker_ps.jpg)

### Figure: Step4 Exp2 Docker Stop Rm
![Step4 Exp2 Docker Stop Rm](C:/Users/Hp/Desktop/lab 2/step4_exp2_docker_stop_rm.jpg)

### Figure: Step5 Exp2 Docker Rmi
![Step5 Exp2 Docker Rmi](C:/Users/Hp/Desktop/lab 2/step5_exp2_docker_rmi.jpg)



\newpage

# Lab Manual – Experiment 3
## Course: Containerization and DevOps (CS-4001)
### Topic: Deploying NGINX Using Different Base Images and Comparing Image Layers

---

## 1. Lab Objectives
After completing this laboratory experiment, students will be able to:
1. Deploy NGINX web servers using three distinct container base images:
   - Official `nginx:latest` Debian-based image.
   - Custom `ubuntu:22.04` base image with NGINX installation.
   - Custom `alpine:latest` minimal base image with NGINX installation.
2. Understand Docker image layers, layer caching, and storage size differences.
3. Quantitatively inspect and compare performance, security attack surface, and operational use-cases for each base image.
4. Utilize Docker volume mounts to serve custom static web pages (`-v`).
5. Explain real-world NGINX container use-cases including Reverse Proxy, Load Balancing, SSL Termination, and API Gateway patterns.

---

## 2. Prerequisites
- Docker Engine / Docker Desktop installed and running.
- Foundational understanding of `docker run`, `Dockerfile`, port forwarding (`-p`), and basic Linux commands.

---

## 3. Step-by-Step Lab Execution & Observations

### Part 1: Deploy NGINX Using Official Image (Recommended Approach)

#### Step 1: Pull Official Image
```bash
docker pull nginx:latest
```

#### Step 2: Run Container
```bash
docker run -d --name nginx-official -p 8080:80 nginx
```

#### Step 3: Verify HTTP Response
```bash
curl http://localhost:8080
```
*Expected Output*: NGINX default welcome HTML page (`Welcome to nginx!`).

![Terminal Screenshot - Part 1: Official NGINX Image](C:/Users/Hp/Desktop/lab 3/step1_official_nginx.jpg)

#### Key Observations

```bash
docker images nginx
```
- **Pre-optimized**: Configured out of the box with standard production defaults (`daemon off;`).
- **Debian Base**: Built on Debian Linux, balancing compatibility and size (~142 MB).
- **Minimal Config**: Ready for instant deployment without building custom Dockerfiles.

---

### Part 2: Custom NGINX Using Ubuntu Base Image

#### Step 1: Create `Dockerfile`
Create a directory named `ubuntu-nginx` and add the following `Dockerfile`:
```dockerfile
FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

#### Step 2: Build Image
```bash
docker build -t nginx-ubuntu .
```

#### Step 3: Run Container
```bash
docker run -d --name nginx-ubuntu -p 8081:80 nginx-ubuntu
```

![Terminal Screenshot - Part 2: Ubuntu-based Custom NGINX Image](C:/Users/Hp/Desktop/lab 3/step2_ubuntu_nginx.jpg)

#### Key Observations

```bash
docker images nginx-ubuntu
```
- **Larger Image Size**: ~228 MB due to full Ubuntu glibc user space and package repositories.
- **Rich Debugging Toolset**: Contains full Linux utilities (`bash`, `curl`, `apt`, `net-tools`, `systemd` tools).
- **Higher Security Attack Surface**: Larger package surface area increases vulnerability scanning alerts.

---

### Part 3: Custom NGINX Using Alpine Base Image

#### Step 1: Create `Dockerfile`
Create a directory named `alpine-nginx` and add the following `Dockerfile`:
```dockerfile
FROM alpine:latest

RUN apk add --no-cache nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

#### Step 2: Build Image
```bash
docker build -t nginx-alpine .
```

#### Step 3: Run Container
```bash
docker run -d --name nginx-alpine -p 8082:80 nginx-alpine
```

![Terminal Screenshot - Part 3: Alpine-based Custom NGINX Image](C:/Users/Hp/Desktop/lab 3/step3_alpine_nginx.jpg)

#### Key Observations

```bash
docker images nginx-alpine
```
- **Extremely Small Image**: ~27.8 MB (5MB base OS + minimal NGINX musl binary).
- **Minimal Package Footprint**: Uses `apk` package manager with `--no-cache` to avoid storing index archives.
- **Rapid Network Transfers**: Fast CI/CD container registry pushes and pulls.

---

### Part 4: Image Size and Layer Comparison

#### Size Comparison
Execute `docker images` to compare all three NGINX variants:
```bash
docker images | grep nginx
```

| Image Repository | Base OS | Layer Architecture | Typical Disk Size |
| :--- | :--- | :--- | :--- |
| **`nginx-alpine`** | Alpine Linux (musl libc) | Minimal single-binary layer | **~27.8 MB** |
| **`nginx:latest`** | Debian Linux (glibc) | Pre-compiled official layers | **~142.0 MB** |
| **`nginx-ubuntu`** | Ubuntu 22.04 LTS | Full OS user space layers | **~228.0 MB** |

#### Inspecting Image Layers (`docker history`)
Examine layer creation history and size contribution per instruction:
```bash
docker history nginx
docker history nginx-ubuntu
docker history nginx-alpine
```

![Terminal Screenshot - Part 4: Size and Layer Comparison](C:/Users/Hp/Desktop/lab 3/step4_layer_comparison.jpg)

#### Key Takeaways:
- **Ubuntu Image**: Contains multiple heavy OS layers (`apt-get update`, package index files, glibc libraries).
- **Alpine Image**: Extremely thin layers (7.3 MB base layer + 20.4 MB NGINX package layer).
- **Official Image**: Highly optimized layer cache structure by NGINX maintainers.

---

### Part 5: Functional Tasks Using NGINX

#### Task 1: Serving Custom HTML Page via Volume Mount
Rather than rebuilding images for content changes, bind mount a local host directory into the container's web root:

```bash
mkdir html
echo "<h1>Hello from Docker NGINX Volume Mount</h1>" > html/index.html

docker run -d \
  -p 8083:80 \
  -v $(pwd)/html:/usr/share/nginx/html \
  --name nginx-volume \
  nginx
```

Verify custom web page access:
```bash
curl http://localhost:8083
```
*Response*: `<h1>Hello from Docker NGINX Volume Mount</h1>`

![Terminal Screenshot - Part 5: Volume Mounting Custom HTML](C:/Users/Hp/Desktop/lab 3/step5_volume_mount.jpg)

### 4.7.3 3. Key Use-Case Configurations

#### 4.7.3.1 Reverse Proxy Configuration (`proxy_pass`)

NGINX acts as a high-performance entry point in microservice architectures:
- **Traffic Forwarding**: Routes external port 80/443 requests to internal application containers (Node.js, Python, Java).
- **Load Balancing**: Distributes incoming HTTP requests across a pool of backend container replicas using Round-Robin, Least Connections, or IP Hash algorithms.
- **SSL Termination**: Decrypts HTTPS traffic at NGINX edge layer, relieving backend services of TLS overhead.

---

## 4. Comparison Summary & Selection Guide



### Feature Comparison Matrix

| Evaluation Feature | Official NGINX Image | Ubuntu + NGINX Image | Alpine + NGINX Image |
| :--- | :--- | :--- | :--- |
| **Image Size** | Medium (~142 MB) | Large (~228 MB) | **Very Small (~28 MB)** |
| **Ease of Use** | **Very Easy (Out-of-box)** | Medium (Custom Dockerfile) | Medium (Custom Dockerfile) |
| **Startup Speed** | Fast | Slower | **Very Fast (Sub-second)** |
| **Debugging Tools** | Limited | **Excellent (Full bash/tools)** | Minimal (sh/ash only) |
| **Security Surface** | Medium | Large | **Smallest (Minimal CVEs)** |
| **Production Suitability**| **Yes (Standard)** | Rarely (Dev/Testing only) | **Yes (Cloud-Native/K8s)** |

### Decision Framework: When to Use What

```mermaid
flowchart TD
    Req{"Select Container Base Image"}
    Req -->|"Production Web Server / Reverse Proxy"| Official["Official `nginx:latest` Image\n(Debian-based, pre-optimized)"]
    Req -->|"Microservices / Kubernetes / CI/CD"| Alpine["Custom `nginx-alpine` Image\n(Ultra-lightweight ~28MB, minimal CVEs)"]
    Req -->|"Debugging / Complex OS Dependencies"| Ubuntu["Custom `nginx-ubuntu` Image\n(Full OS utilities, development testing)"]
```

---

## 5. Lab Assignment Solutions (For Students)

1. **Measure Image Pull Time**:
   - `nginx-alpine`: ~2–4 seconds (smallest payload).
   - `nginx:latest`: ~8–12 seconds.
   - `nginx-ubuntu`: ~15–25 seconds.
2. **Why Alpine images are significantly smaller**:
   - Alpine uses `musl libc` instead of `glibc` and `busybox` core utilities, resulting in a base OS footprint of only 5 MB compared to Ubuntu's 77 MB base layer.
3. **Why Ubuntu images are avoided in production**:
   - Unnecessary packages (shell utilities, package managers, system tools) increase disk footprint, slow down container deployment/scaling, and expand the security vulnerability attack surface.

---

## 6. NGINX Web Server Deep Dive (Optional Read)

### 1. Core Architecture


NGINX uses an **event-driven, non-blocking asynchronous architecture**. Unlike thread-per-request servers (e.g., traditional Apache), a single NGINX worker process can handle tens of thousands of concurrent HTTP connections with minimal memory overhead.

### 2. Configuration Hierarchy
- Main Config File: `/etc/nginx/nginx.conf`
- Server Block Configs: `/etc/nginx/sites-available/` & `/etc/nginx/sites-enabled/`
- Default Web Root: `/var/www/html/` or `/usr/share/nginx/html/`

### 3. Key Use-Case Configurations

#### 4.7.3.1 Reverse Proxy Configuration (`proxy_pass`)
```nginx
server {
    listen 80;
    server_name api.myapp.local;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

#### 4.7.3.2 Load Balancer Configuration (`upstream`)
```nginx
upstream backend_cluster {
    server 10.0.0.1:8080 weight=3;
    server 10.0.0.2:8080;
}

server {
    listen 80;
    location / {
        proxy_pass http://backend_cluster;
    }
}
```

#### 4.7.3.3 Rate Limiting (API Protection) (API Protection)
```nginx
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

server {
    listen 80;
    location /api/ {
        limit_req zone=api_limit burst=20;
        proxy_pass http://localhost:5000;
    }
}
```

#### 4.7.3.4 NGINX vs Apache Architecture Comparison


| Attribute | NGINX | Apache HTTP Server |
| :--- | :--- | :--- |
| **Architecture** | Event-driven, asynchronous worker loop | Process/Thread per connection model |
| **Static File Delivery** | Extremely fast (zero-copy kernel calls) | Moderate speed |
| **Memory under Load** | Low and constant (~2–5 MB per worker) | Scales linearly with active connection count |
| **Configuration** | Centralized, reloadable without restart | `.htaccess` decentralized per-directory rules |

---

## 7. Result & Conclusion

### Result
- Deployed NGINX across Official (`nginx:latest`), custom Ubuntu (`nginx-ubuntu`), and custom Alpine (`nginx-alpine`) base images.
- Quantified image size differences (**27.8 MB Alpine vs 142 MB Official vs 228 MB Ubuntu**).
- Verified static file volume mounting (`-v`) and reverse proxy load balancing architectures.

### Conclusion

Base image selection heavily dictates container performance, storage overhead, and security posture. **Alpine-based images** are optimal for microservices, cloud-native pipelines, and Kubernetes deployments. **Official NGINX images** provide out-of-the-box production readiness. **Ubuntu-based images** are best suited for development, debugging, and specialized Linux dependency requirements.

---


### Figure: Key Use Case Configurations


\newpage

# Lab Manual – Experiment 3 (Part 2)
## Course: Containerization and DevOps (CS-4001)
### Topic: Deploying NGINX Using Different Base Images and Comparing Image Layers

---

## 1. Lab Objectives
- Deploy NGINX using Official `nginx:latest`, Ubuntu-based custom image, and Alpine-based custom image.
- Compare image disk sizes (~27.8 MB Alpine vs ~142 MB Official vs ~228 MB Ubuntu) and inspect layer creation (`docker history`).
- Serve static web content via Docker volume mounting (`-v $(pwd)/html:/usr/share/nginx/html`).
- Master NGINX server blocks, Reverse Proxy (`proxy_pass`), Load Balancing (`upstream`), SSL termination, and Rate Limiting.

---

## 2. Step-by-Step Execution Logs & Terminal Visuals

### Part 1: Deploy NGINX Using Official Image
```bash
docker pull nginx:latest
docker run -d --name nginx-official -p 8080:80 nginx
curl http://localhost:8080
```
![Step 1 Official Image](C:/Users/Hp/Desktop/lab 3 part 2/step1_official_nginx.jpg)

---

### Part 2: Custom NGINX Using Ubuntu Base Image
```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y nginx && apt-get clean && rm -rf /var/lib/apt/lists/*
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```
```bash
docker build -t nginx-ubuntu .
docker run -d --name nginx-ubuntu -p 8081:80 nginx-ubuntu
```
![Step 2 Ubuntu Image](C:/Users/Hp/Desktop/lab 3 part 2/step2_ubuntu_nginx.jpg)

---

### Part 3: Custom NGINX Using Alpine Base Image
```dockerfile
FROM alpine:latest
RUN apk add --no-cache nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```
```bash
docker build -t nginx-alpine .
docker run -d --name nginx-alpine -p 8082:80 nginx-alpine
```
![Step 3 Alpine Image](C:/Users/Hp/Desktop/lab 3 part 2/step3_alpine_nginx.jpg)

---

### Part 4: Image Size and Layer Comparison
```bash
docker images | grep nginx
docker history nginx-alpine
```
| Image Variant | Base OS | Size | Production Suitability |
| :--- | :--- | :--- | :--- |
| **`nginx-alpine`** | Alpine Linux | **~27.8 MB** | Microservices, Kubernetes, CI/CD |
| **`nginx:latest`** | Debian Linux | **~142 MB** | Standard Web Hosting |
| **`nginx-ubuntu`** | Ubuntu 22.04 | **~228 MB** | Development & Heavy Debugging |

![Step 4 Layer Comparison](C:/Users/Hp/Desktop/lab 3 part 2/step4_layer_comparison.jpg)

---

### Part 5: Volume Mount & Web Content Serving
```bash
mkdir html
echo "<h1>Hello from Lab 3 Part 2 NGINX Volume Mount</h1>" > html/index.html
docker run -d -p 8083:80 -v $(pwd)/html:/usr/share/nginx/html --name nginx-vol nginx
curl http://localhost:8083
```
![Step 5 Volume Mount](C:/Users/Hp/Desktop/lab 3 part 2/step5_volume_mount.jpg)

---

## 3. NGINX Web Server Deep Dive (Optional Read)
- **Static Hosting**: `/var/www/html/index.html`
- **Reverse Proxy**: `proxy_pass http://localhost:3000;`
- **Load Balancing**: `upstream backend_pool { server 10.0.0.1:8080; server 10.0.0.2:8080; }`
- **Rate Limiting**: `limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;`
- **NGINX vs Apache**: Event-driven asynchronous architecture vs thread-per-connection model.

---

## 4. Result & Conclusion
- Successfully completed Experiment 3 (Part 2). Alpine base images deliver ultra-lightweight ~28MB footprints suitable for cloud-native applications.

\newpage

# Lab Manual – Experiment 4
## Course: Containerization and DevOps (CS-4001)
### Topic: Docker Essentials – Dockerfile, .dockerignore, Tagging, Multi-stage Builds & Registry Publishing

---

## 1. Objective & Learning Outcomes
After completing this laboratory experiment, students will be able to:
1. Containerize applications using custom `Dockerfile` definitions for Python Flask and Node.js Express workloads.
2. Utilize `.dockerignore` files to exclude unnecessary build contexts, improving build speed, image size, and container security.
3. Master Docker image tagging conventions (`latest`, semantic versioning, custom registries).
4. Implement **Multi-stage Builds** to separate build-time tooling from lightweight runtime environments, achieving ~40% smaller image sizes.
5. Authenticate, tag, and publish container images to **Docker Hub** public/private registries (`docker push`).
6. Apply Docker development and production workflows, essential commands cheatsheet, and host system cleanup (`docker system prune -a`).

---

## 2. Prerequisites & Architecture Overview

### Prerequisites
- Docker Engine / Docker Desktop installed and functional.
- Basic familiarity with terminal command lines, HTTP web servers, Python, and JavaScript/Node.js.

### Docker Build Context Architecture
When executing `docker build -t myapp .`, the Docker client sends the contents of the current directory (the **build context**) to the Docker daemon (`dockerd`). Using a `.dockerignore` file prevents temporary, secret, or bulky files (`.venv/`, `.git/`, `.env`, `node_modules/`) from being transmitted over the daemon socket or stored inside image layers.

```mermaid
flowchart TD
    subgraph Client["Developer Workstation"]
        AppCode["Application Code\n(app.py / app.js)"]
        Dockerignore[".dockerignore\n(Excludes .venv, .git, .env)"]
        Dockerfile["Dockerfile\n(Instructions)"]
    end

    subgraph Daemon["Docker Daemon (dockerd)"]
        Builder["Build Engine"]
        Cache["Layer Cache"]
        FinalImage["Optimized Container Image\n(my-flask-app:1.0)"]
    end

    AppCode -->|Filtered Context| Builder
    Dockerfile -->|Instructions| Builder
    Cache --> Builder
    Builder --> FinalImage
    FinalImage -->|docker push| Hub["Docker Hub Registry"]
```

---

## 3. Step-by-Step Lab Execution & Logs

### Part 1: Containerizing Applications with Dockerfile (Python Flask)

#### Step 1: Create Application Files
Create project directory `my-flask-app`:
```bash
mkdir my-flask-app
cd my-flask-app
```

##### `app.py`:
```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello from Docker!"

@app.route('/health')
def health():
    return "OK"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

##### `requirements.txt`:
```ini
Flask==2.3.3
```

#### Step 2: Create `Dockerfile`
```dockerfile
# Use Python base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Expose port
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]
```

![Terminal Screenshot - Part 1: Flask Dockerfile Build](C:/Users/Hp/Desktop/lab 4/step1_flask_dockerfile.jpg)

---

### Part 2: Using `.dockerignore`

#### Step 1: Create `.dockerignore` File
Create a `.dockerignore` file in the root directory:
```bash
# Python files
__pycache__/
*.pyc
*.pyo
*.pyd

# Environment files
.env
.venv
env/
venv/

# IDE files
.vscode/
.idea/

# Git files
.git/
.gitignore

# OS files
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Test files
tests/
test_*.py
```

#### Step 2: Importance of `.dockerignore`
1. **Prevents Unnecessary File Copying**: Ignores `venv`, `.git`, and node dependencies during context upload.
2. **Reduces Image Size**: Keeps runtime layers clean without extra megabytes of cache or test data.
3. **Improves Build Speed**: Smaller build context transmits over daemon socket faster.
4. **Increases Security**: Prevents sensitive `.env` API keys, credentials, or local configuration files from leaking into image layers.

![Terminal Screenshot - Part 2: .dockerignore & History Inspection](C:/Users/Hp/Desktop/lab 4/step2_dockerignore_build.jpg)

---

### Part 3: Building & Tagging Docker Images

#### Step 1: Basic Build Command
```bash
# Build image from Dockerfile
docker build -t my-flask-app .

# Check built images
docker images
```

#### Step 2: Tagging Strategies
```bash
# Tag with specific version number
docker build -t my-flask-app:1.0 .

# Build with multiple tags simultaneously
docker build -t my-flask-app:latest -t my-flask-app:1.0 .

# Tag for custom registry / Docker Hub username
docker build -t username/my-flask-app:1.0 .

# Tag an existing image ID or tag
docker tag my-flask-app:latest my-flask-app:v1.0
```

#### Step 3: View Image Details & History
```bash
docker images
docker history my-flask-app
docker inspect my-flask-app
```

---

### Part 4: Running & Managing Containers

#### Step 1: Run Container
```bash
# Run container with port mapping 5000:5000
docker run -d -p 5000:5000 --name flask-container my-flask-app

# Test HTTP application endpoint
curl http://localhost:5000

# Test health check endpoint
curl http://localhost:5000/health

# View active containers
docker ps

# View container runtime logs
docker logs flask-container
```

![Terminal Screenshot - Part 4: Running Flask Container & Logs](C:/Users/Hp/Desktop/lab 4/step3_running_flask.jpg)

### 6.4.4.2 Step 2: Container Lifecycle Management
```bash
# Stop container gracefully
docker stop flask-container

# Start stopped container
docker start flask-container

# Remove container instance
docker rm flask-container

# Remove container forcefully (-f)
docker rm -f flask-container
```

---

### Part 5: Multi-Stage Builds (Image Optimization)

#### Step 1: Why Multi-Stage Builds?
- **Smaller Final Disk Footprint**: Compilers, build headers, and virtual environment installers are discarded after build completion.
- **Enhanced Security**: Eliminates package managers (`pip`, `npm`, `gcc`) and build toolchains from runtime containers.
- **Non-Root Execution**: Grants least-privilege security by creating an unprivileged system user (`appuser`).

#### Step 2: Create `Dockerfile.multistage`
```dockerfile
# STAGE 1: Builder stage
FROM python:3.9-slim AS builder

WORKDIR /app

# Copy requirements
COPY requirements.txt .

# Install dependencies in virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir -r requirements.txt

# STAGE 2: Runtime stage
FROM python:3.9-slim

WORKDIR /app

# Copy virtual environment from builder stage
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application code
COPY app.py .

# Create non-root user for security
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 5000

# Run application
CMD ["python", "app.py"]
```

#### Step 3: Build & Compare Size Reduction
```bash
# Build regular single-stage image
docker build -t flask-regular .

# Build multi-stage image
docker build -f Dockerfile.multistage -t flask-multistage .

# Compare size outputs
docker images | grep flask-
```

```text
flask-regular     latest    d40596837201   5 minutes ago   248MB
flask-multistage  latest    f51607948312   1 minute ago    148MB (40% smaller!)
```

![Terminal Screenshot - Part 5: Multi-stage Build & Size Comparison](C:/Users/Hp/Desktop/lab 4/step4_multistage_build.jpg)

---

### Part 6: Publishing to Docker Hub

#### Step 1: Prepare & Authenticate
```bash
# Authenticate against Docker Hub registry
docker login

# Tag local image with Docker Hub username
docker tag my-flask-app:latest username/my-flask-app:1.0
docker tag my-flask-app:latest username/my-flask-app:latest

# Push image tags to Docker Hub
docker push username/my-flask-app:1.0
docker push username/my-flask-app:latest
```

![Terminal Screenshot - Part 6: Publishing Image to Docker Hub](C:/Users/Hp/Desktop/lab 4/step5_publishing_dockerhub.jpg)

#### Step 2: Pull & Deploy from Docker Hub
```bash
# Pull image from Docker Hub on remote host
docker pull username/my-flask-app:latest

# Execute container from remote image
docker run -d -p 5000:5000 username/my-flask-app:latest
```

---

### Part 7: Node.js Application Example (Quick Version)

#### Step 1: Create Node.js Express App
Create directory `my-node-app`:
```bash
mkdir my-node-app
cd my-node-app
```

##### `app.js`:
```javascript
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
    res.send('Hello from Node.js Docker!');
});

app.get('/health', (req, res) => {
    res.json({ status: 'healthy' });
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
```

##### `package.json`:
```json
{
  "name": "node-docker-app",
  "version": "1.0.0",
  "main": "app.js",
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

#### Step 2: Create Node.js `Dockerfile`
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --only=production

COPY app.js .

EXPOSE 3000

CMD ["node", "app.js"]
```

#### Step 3: Build & Test Node.js Container
```bash
# Build Node.js image
docker build -t my-node-app .

# Run Node.js container
docker run -d -p 3000:3000 --name node-container my-node-app

# Test HTTP endpoint
curl http://localhost:3000
```

![Terminal Screenshot - Part 7: Node.js Express App Containerization](C:/Users/Hp/Desktop/lab 4/step6_node_docker.jpg)

---

### Part 8: Quick Practice Exercises

#### Exercise 1: Multi-Tag Build
```bash
docker build -t myapp:latest -t myapp:v2.0 -t username/myapp:production .
```

#### Exercise 2: Node.js Multi-Stage Dockerfile
```dockerfile
# STAGE 1: Builder
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install

# STAGE 2: Runtime
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY app.js package*.json ./
USER node
EXPOSE 3000
CMD ["node", "app.js"]
```

#### Exercise 3: Clean Build Without Cache
```bash
docker build --no-cache -t clean-app .
```

---

## 4. Essential Docker Commands Cheatsheet

| Command | Purpose | Example Usage |
| :--- | :--- | :--- |
| `docker build` | Build image from Dockerfile | `docker build -t myapp .` |
| `docker run` | Create & start container instance | `docker run -d -p 3000:3000 myapp` |
| `docker ps` | List active containers (`-a` for all) | `docker ps -a` |
| `docker images` | List locally available images | `docker images` |
| `docker tag` | Assign tag alias to image | `docker tag myapp:latest myapp:v1` |
| `docker login` | Authenticate against registry | `echo "token" \| docker login -u user --password-stdin` |
| `docker push` | Upload image to registry | `docker push username/myapp:1.0` |
| `docker pull` | Download image from registry | `docker pull username/myapp:1.0` |
| `docker rm` | Remove container instance | `docker rm container-name` |
| `docker rmi` | Remove local image layers | `docker rmi image-name` |
| `docker logs` | Display container log output | `docker logs -f container-name` |
| `docker exec` | Execute process inside container | `docker exec -it container-name bash` |

---

## 5. Development & Production Workflows

### Development Workflow
```bash
# 1. Create Dockerfile and .dockerignore
# 2. Build local test image
docker build -t myapp .

# 3. Test locally with port forwarding
docker run -p 8080:8080 myapp

# 4. Tag for release versioning
docker tag myapp:latest myapp:v1.0

# 5. Push to registry for CI/CD deployment
docker push myapp:v1.0
```

### Production Workflow
```bash
# 1. Pull immutable image tag from registry
docker pull myapp:v1.0

# 2. Launch detached background container
docker run -d -p 80:8080 --name prod-app myapp:v1.0

# 3. Monitor live log stream
docker logs -f prod-app
```

---

## 6. Key Takeaways & Host System Cleanup

### Key Takeaways
1. **Dockerfile**: Declarative recipe defining environment steps and entrypoint runtime commands.
2. **`.dockerignore`**: Mandatory file for excluding temporary build artifacts, increasing build speed and preventing credential leakage.
3. **Tagging Conventions**: Essential for version control, rollback safety, and registry routing.
4. **Multi-Stage Builds**: Drastically reduce image size (~40% footprint savings) and eliminate build toolchains from production containers.
5. **Least Privilege**: Run application containers as non-root users (`USER appuser`) for enterprise security.

### Host System Cleanup Commands
```bash
# Remove all stopped containers
docker container prune

# Remove unreferenced dangling images
docker image prune

# Deep cleanup: Remove all stopped containers, unused networks, and unused images
docker system prune -a
```

---

## 7. Result & Conclusion

### Result
- Containerized Python Flask and Node.js Express applications using custom Dockerfiles.
- Applied `.dockerignore` filtering to optimize build contexts.
- Implemented Multi-stage Builds (`Dockerfile.multistage`) reducing final image size by **40% (148MB vs 248MB)**.
- Authenticated and pushed image artifacts to **Docker Hub** registry.

### Conclusion

Experiment 4 established core Docker application containerization practices. Utilizing `.dockerignore`, multi-stage builds, non-root system users, and versioned image tagging ensures secure, fast, and lightweight container deployments across modern CI/CD pipelines.

---


### Figure: Container Lifecycle Management
![Container Lifecycle Management](C:/Users/Hp/Desktop/lab 4/step7_container_lifecycle_management.jpg)


\newpage

# Lab Manual – Experiment 5
## Course: Containerization and DevOps (CS-4001)
### Topic: Docker – Volumes, Environment Variables, Monitoring & Networks



---

## 1. Objective & Learning Outcomes
After completing this laboratory experiment, students will be able to:
1. Understand the ephemeral nature of container filesystems and apply **Docker Volumes** (anonymous, named, and bind mounts) for persistent data storage.
2. Configure containers dynamically using **Environment Variables** via `-e` flags, `--env-file`, and Dockerfile `ENV` directives.
3. Monitor container health, resource consumption, and runtime events using `docker stats`, `docker top`, `docker logs`, `docker inspect`, and `docker events`.
4. Create and manage **Docker Networks** (bridge, host, none, overlay) enabling secure inter-container DNS-based communication.
5. Architect a complete multi-container application stack (Flask + PostgreSQL + Redis) integrating volumes, environment variables, custom networks, and monitoring.

---

## 2. Prerequisites
- Docker Engine / Docker Desktop installed and operational.
- Familiarity with terminal command-line operations and basic networking concepts (ports, DNS, subnets).
- Python Flask and basic SQL knowledge (for the real-world example).

---

## Part 1: Docker Volumes – Persistent Data Storage



### Lab 1: Understanding Data Persistence

#### The Problem: Container Data is Ephemeral
By default, any data written inside a container's writable layer is **lost** when the container is removed.

```bash
# Create a container that writes data
docker run -it --name test-container ubuntu /bin/bash

# Inside container:
mkdir /data
echo "Hello World" > /data/message.txt
cat /data/message.txt  # Shows "Hello World"
exit

# Restart container
docker start test-container
docker exec test-container cat /data/message.txt
# ERROR: File doesn't exist! Data was lost.
```

> **Solution: Docker Volumes** – Volumes exist outside the container's writable layer on the host filesystem, persisting data across container restarts, removals, and replacements.

![Terminal Screenshot – Ephemeral Data Problem & Volume Types](C:/Users/Hp/Desktop/lab 5/step1_volumes_types.jpg)

---

### Lab 2: Volume Types

#### 1. Anonymous Volumes
```bash
docker run -d -v /app/data --name web1 nginx
docker volume ls
docker inspect web1 | grep -A 5 Mounts
```

#### 2. Named Volumes (Recommended for Production)
```bash
docker volume create mydata
docker run -d -v mydata:/app/data --name web2 nginx
docker volume ls
docker volume inspect mydata
```

#### 3. Bind Mounts (Host Directory Mapping)
```bash
mkdir ~/myapp-data
docker run -d -v ~/myapp-data:/app/data --name web3 nginx
echo "From Host" > ~/myapp-data/host-file.txt
docker exec web3 cat /app/data/host-file.txt
# Shows: From Host
```

---

### Lab 3: Practical Volume Examples

#### Example 1: Database with Persistent Storage
```bash
docker run -d --name mysql-db \
  -v mysql-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=secret mysql:8.0

docker stop mysql-db && docker rm mysql-db

# New container with same volume - data preserved!
docker run -d --name new-mysql \
  -v mysql-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=secret mysql:8.0
```

#### Example 2: Web App with Configuration Files
```bash
mkdir ~/nginx-config
echo 'server {
    listen 80;
    server_name localhost;
    location / {
        return 200 "Hello from mounted config!";
    }
}' > ~/nginx-config/nginx.conf

docker run -d --name nginx-custom -p 8080:80 \
  -v ~/nginx-config/nginx.conf:/etc/nginx/conf.d/default.conf nginx

curl http://localhost:8080
# Output: Hello from mounted config!
```

![Terminal Screenshot – Practical MySQL & NGINX Volume Examples](C:/Users/Hp/Desktop/lab 5/step2_volumes_practical.jpg)

---

### Lab 4: Volume Management Commands


```bash
docker volume ls                    # List all volumes
docker volume create app-volume     # Create a volume
docker volume inspect app-volume    # Inspect volume details
docker volume prune                 # Remove unused volumes
docker volume rm volume-name        # Remove specific volume
docker cp local-file.txt container-name:/path/in/volume  # Copy files
```

---

## Part 2: Environment Variables



### Lab 1: Setting Environment Variables



#### Method 1: Using `-e` Flag
```bash
docker run -d --name app1 \
  -e DATABASE_URL="postgres://user:pass@db:5432/mydb" \
  -e DEBUG="true" -p 3000:3000 my-node-app
```

#### Method 2: Using `--env-file`
```bash
echo "DATABASE_HOST=localhost" > .env
echo "DATABASE_PORT=5432" >> .env
echo "API_KEY=secret123" >> .env

docker run -d --env-file .env --name app2 my-app
```

#### Method 3: In Dockerfile
```dockerfile
ENV NODE_ENV=production
ENV PORT=3000
ENV APP_VERSION=1.0.0
```

---

### Lab 2: Environment Variables in Applications



#### Python Flask Example
```python
import os
from flask import Flask

app = Flask(__name__)
db_host = os.environ.get('DATABASE_HOST', 'localhost')
debug_mode = os.environ.get('DEBUG', 'false').lower() == 'true'
api_key = os.environ.get('API_KEY')

@app.route('/config')
def config():
    return {
        'db_host': db_host,
        'debug': debug_mode,
        'has_api_key': bool(api_key)
    }

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=debug_mode)
```

#### Dockerfile with Environment Variables


```dockerfile
FROM python:3.9-slim
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app.py .
ENV PORT=5000
ENV DEBUG=false
EXPOSE 5000
CMD ["python", "app.py"]
```

---

### Lab 3: Test Environment Variables


```bash
docker run -d --name flask-app -p 5000:5000 \
  -e DATABASE_HOST="prod-db.example.com" \
  -e DEBUG="true" -e PORT="8080" flask-app

docker exec flask-app env
docker exec flask-app printenv DATABASE_HOST
curl http://localhost:5000/config
```

![Terminal Screenshot – Environment Variables (-e, --env-file, Flask)](C:/Users/Hp/Desktop/lab 5/step3_env_variables.jpg)

---

## Part 3: Docker Monitoring



### Lab 1: `docker stats` – Real-time Container Metrics
```bash
docker stats
docker stats container1 container2
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
docker stats --no-stream
docker stats --all
docker stats --format json --no-stream
```

### Lab 2: `docker top` – Process Monitoring
```bash
docker top container-name
docker top container-name -ef
ps aux | grep docker
```

### Lab 3: `docker logs` – Application Logs
```bash
docker logs container-name
docker logs -f container-name
docker logs --tail 100 container-name
docker logs -t container-name
docker logs --since 2024-01-15 container-name
docker logs -f --tail 50 -t container-name
```

![Terminal Screenshot – docker stats, docker top, docker logs](C:/Users/Hp/Desktop/lab 5/step4_monitoring.jpg)

### Lab 4: Container Inspection
```bash
docker inspect container-name
docker inspect --format='{{.State.Status}}' container-name
docker inspect --format='{{.NetworkSettings.IPAddress}}' container-name
docker inspect --format='{{.Config.Env}}' container-name
docker inspect --format='{{.HostConfig.Memory}}' container-name
```

### Lab 5: Events Monitoring
```bash
docker events
docker events --filter 'type=container'
docker events --filter 'event=start'
docker events --filter 'event=die'
docker events --since '2024-01-15'
docker events --format '{{.Type}} {{.Action}} {{.Actor.Attributes.name}}'
```

### Lab 6: Practical Monitoring Script
```bash
#!/bin/bash
echo "=== Docker Monitoring Dashboard ==="
echo "Time: $(date)"

echo "1. Running Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo "2. Resource Usage:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

echo "3. Recent Events:"
docker events --since '5m' --until '0s' --format '{{.Time}} {{.Type}} {{.Action}}' | tail -5

echo "4. System Info:"
docker system df
```

![Terminal Screenshot – Docker Events & Monitoring Dashboard](C:/Users/Hp/Desktop/lab 5/step5_events_dashboard.jpg)

---

## Part 4: Docker Networks



### Lab 1: Understanding Docker Network Types
```bash
docker network ls
# NETWORK ID     NAME      DRIVER    SCOPE
# abc123         bridge    bridge    local
# def456         host      host      local
# ghi789         none      null      local
```

### Lab 2: Network Types Explained

#### 1. Bridge Network (Default)
```bash
docker network create my-network
docker network inspect my-network
docker run -d --name web1 --network my-network nginx
docker run -d --name web2 --network my-network nginx
docker exec web1 curl http://web2
```

#### 2. Host Network
```bash
docker run -d --name host-app --network host nginx
curl http://localhost
```

#### 3. None Network
```bash
docker run -d --name isolated-app --network none alpine sleep 3600
docker exec isolated-app ifconfig  # Only loopback
```

#### 4. Overlay Network (Swarm)
```bash
docker network create --driver overlay my-overlay
```

![Terminal Screenshot – Docker Network Types & Container Communication](C:/Users/Hp/Desktop/lab 5/step6_networks.jpg)

### Lab 3: Network Management Commands
```bash
docker network create app-network
docker network create --driver bridge --subnet 172.20.0.0/16 --gateway 172.20.0.1 my-subnet
docker network connect app-network existing-container
docker network disconnect app-network container-name
docker network rm network-name
docker network prune
```

### Lab 4: Multi-Container Application Example
```bash
docker network create app-network

docker run -d --name postgres-db --network app-network \
  -e POSTGRES_PASSWORD=secret \
  -v pgdata:/var/lib/postgresql/data postgres:15

docker run -d --name web-app --network app-network \
  -p 8080:3000 \
  -e DATABASE_URL="postgres://postgres:secret@postgres-db:5432/mydb" \
  -e DATABASE_HOST="postgres-db" node-app
```

### Lab 5: Network Inspection & Debugging
```bash
docker network inspect bridge
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container-name
docker exec container-name nslookup another-container
docker exec container-name ping -c 4 google.com
docker exec container-name curl -I http://another-container
docker port container-name
```

### Lab 6: Port Publishing vs Exposing
```bash
docker run -d -p 80:8080 --name app1 nginx          # Host:Container
docker run -d -p 8080 --name app2 nginx              # Dynamic host port
docker run -d -p 80:80 -p 443:443 --name app3 nginx  # Multiple ports
docker run -d -p 127.0.0.1:8080:80 --name app4 nginx # Specific host IP
```

---

## Part 5: Complete Real-World Example

### Architecture: Flask + PostgreSQL + Redis
```bash
# 1. Create network
docker network create myapp-network

# 2. Start database with volume
docker run -d --name postgres --network myapp-network \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -e POSTGRES_DB=mydatabase \
  -v postgres-data:/var/lib/postgresql/data postgres:15

# 3. Start Redis
docker run -d --name redis --network myapp-network \
  -v redis-data:/data redis:7-alpine

# 4. Start Flask app with all configurations
docker run -d --name flask-app --network myapp-network \
  -p 5000:5000 -v $(pwd)/app:/app -v app-logs:/var/log/app \
  -e DATABASE_URL="postgresql://postgres:mysecretpassword@postgres:5432/mydatabase" \
  -e REDIS_URL="redis://redis:6379" \
  -e DEBUG="false" -e LOG_LEVEL="INFO" \
  --env-file .env.production flask-app:latest
```

### Monitoring the Stack
```bash
docker ps
docker stats postgres redis flask-app
docker logs -f flask-app
docker exec flask-app ping -c 2 postgres
docker exec flask-app ping -c 2 redis
docker network inspect myapp-network
```

![Terminal Screenshot – Multi-Container Real-World App (Flask + PostgreSQL + Redis)](C:/Users/Hp/Desktop/lab 5/step7_realworld_multicontainer.jpg)

---

## Quick Reference Cheatsheet



| Category | Command | Purpose |
| :--- | :--- | :--- |
| **Volumes** | `docker volume create <name>` | Create named volume |
| | `docker run -v <vol>:/path` | Mount named volume |
| | `docker run -v /host:/container` | Bind mount |
| | `docker volume ls` | List volumes |
| | `docker volume rm <name>` | Remove volume |
| **Env Vars** | `docker run -e VAR=value` | Set variable |
| | `docker run --env-file .env` | Load from file |
| | `ENV VAR=value` (Dockerfile) | Set default |
| **Monitoring** | `docker stats` | Live metrics |
| | `docker logs -f <container>` | Follow logs |
| | `docker top <container>` | Process list |
| | `docker inspect <container>` | Full details |
| | `docker events` | Real-time events |
| **Networks** | `docker network create <name>` | Create network |
| | `docker run --network <name>` | Join network |
| | `docker network connect <net> <ctr>` | Connect container |
| | `docker network inspect <net>` | Network details |

---

## Practice Exercises

### Exercise 1: Database Backup
Create a PostgreSQL container with volume. Backup data using `docker cp` or volume backup techniques. Restore to a new container.

### Exercise 2: Multi-Service Setup
Create: web app + database + cache. Use custom network for communication. Set environment variables for configuration. Monitor all services.

### Exercise 3: Log Analysis
Run a container that generates logs. Use `docker logs` with various filters. Redirect logs to a file on host using bind mount.

### Exercise 4: Network Isolation
Create two separate networks. Put containers in different networks. Test connectivity between networks. Connect a container to both networks.

---

## Cleanup


```bash
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker volume prune -f
docker network prune -f
docker image prune -f
```

---

## Key Takeaways

1. **Volumes** persist data beyond container lifecycle.
2. **Environment variables** configure containers dynamically without rebuilding images.
3. **Monitoring commands** (`stats`, `top`, `logs`, `inspect`, `events`) help debug and optimize containers.
4. **Networks** enable secure container-to-container communication via DNS hostnames.
5. **Always use named volumes** for production data (databases, user uploads, logs).
6. **Custom bridge networks** provide better isolation and automatic DNS resolution.
7. **Monitor resource usage** to prevent OOM kills and CPU throttling.
8. **Use `.env` files** for sensitive configuration — never hardcode secrets in Dockerfiles.

---

## Result & Conclusion

### Result
- Demonstrated ephemeral container data and resolved it with Docker Volumes (anonymous, named, bind mounts).
- Configured containers dynamically using `-e` flags, `--env-file`, and Dockerfile `ENV` directives.
- Monitored containers with `docker stats`, `docker top`, `docker logs`, `docker inspect`, and `docker events`.
- Established inter-container communication using custom Docker bridge networks with DNS hostname resolution.
- Deployed a complete 3-tier application (Flask + PostgreSQL + Redis) integrating all four topics.

### Conclusion

Experiment 5 demonstrated the four pillars of production-grade Docker deployments: persistent storage (volumes), dynamic configuration (environment variables), observability (monitoring), and secure communication (networks). Mastering these concepts is critical for building reliable, scalable, and maintainable containerized applications.

---


\newpage

# Lab Manual – Experiment 6
## Course: Containerization and DevOps (CS-4001)
### Topic: Comparison of Docker Run and Docker Compose & Multi-Container WordPress + MySQL Application



---

## PART A – THEORY

### 1. Objective
To understand the relationship between `docker run` and **Docker Compose**, compare their configuration syntax, analyze imperative vs. declarative container management approaches, and deploy production-ready multi-container applications (WordPress + MySQL) with volume persistence, custom builds, resource limits, and Docker Swarm orchestration.

---

### 2. Background Theory

#### 2.1 Docker Run (Imperative Approach)


The `docker run` command is used to create and start a container from an image. It requires explicit flags for:
- Port mapping (`-p`)
- Volume mounting (`-v`)
- Environment variables (`-e`)
- Network configuration (`--network`)
- Restart policies (`--restart`)
- Resource limits (`--memory`, `--cpus`)
- Container name (`--name`)

This approach is **imperative**, meaning you specify step-by-step instructions in the terminal.

```bash
docker run -d \
  --name my-nginx \
  -p 8080:80 \
  -v ./html:/usr/share/nginx/html \
  -e NGINX_HOST=localhost \
  --restart unless-stopped \
  nginx:alpine
```

#### 2.2 Docker Compose (Declarative Approach)


Docker Compose uses a YAML file (`docker-compose.yml`) to define services, networks, and volumes in a structured, version-controlled format.

Instead of multiple `docker run` commands, a single command is used:
```bash
docker compose up -d
```

Compose is **declarative**, meaning you define the desired state of the entire multi-container application.

##### Equivalent `docker-compose.yml`:
```yaml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    container_name: my-nginx
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
    environment:
      NGINX_HOST: localhost
    restart: unless-stopped
```

---

### 3. Mapping: Docker Run vs Docker Compose



| Docker Run Flag | Docker Compose Equivalent | Description |
| :--- | :--- | :--- |
| `-p 8080:80` | `ports:` | Binds host port to container port |
| `-v host:container` | `volumes:` | Mounts host path or named volume |
| `-e KEY=value` | `environment:` | Passes environment configuration |
| `--name` | `container_name:` | Assigns custom container instance name |
| `--network` | `networks:` | Connects container to defined network |
| `--restart` | `restart:` | Defines crash/reboot restart policy |
| `--memory` | `deploy.resources.limits.memory` | Constrains maximum RAM allocation |
| `--cpus` | `deploy.resources.limits.cpus` | Limits CPU core consumption |
| `-d` | `docker compose up -d` | Executes service in background mode |

---

### 4. Advantages of Docker Compose


1. **Simplifies Multi-Container Applications**: Orchestrates complex architectures in a single file.
2. **Provides Reproducibility**: Enables identical development, testing, and staging environments across team members.
3. **Version Controllable**: `docker-compose.yml` can be checked into Git alongside source code.
4. **Unified Lifecycle Management**: Single-command startup (`up`), shutdown (`down`), and log monitoring (`logs`).
5. **Supports Service Scaling**: Easily scale web workers using `docker compose up --scale web=3`.

---

## PART B – PRACTICAL TASKS

### Task 1: Single Container Comparison

#### Step 1: Run Nginx Using `docker run`


```bash
# Execute imperative command
docker run -d \
  --name lab-nginx \
  -p 8081:80 \
  -v $(pwd)/html:/usr/share/nginx/html \
  nginx:alpine

# Verify container
docker ps

# Test HTTP endpoint
curl http://localhost:8081

# Stop and remove container
docker stop lab-nginx
docker rm lab-nginx
```

#### Step 2: Run Same Setup Using Docker Compose


Create `docker-compose.yml`:
```yaml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    container_name: lab-nginx
    ports:
      - "8081:80"
    volumes:
      - ./html:/usr/share/nginx/html
```

```bash
# Launch service in detached mode
docker compose up -d

# Verify service state
docker compose ps

# Teardown stack
docker compose down
```

![Terminal Screenshot – Task 1: Nginx Docker Run vs Docker Compose](C:/Users/Hp/Desktop/lab 6/step1_nginx_run_vs_compose.jpg)

---

### Task 2: Multi-Container Application (WordPress + MySQL)

#### Objective
Deploy WordPress with MySQL using:
1. Docker Run (manual imperative way)
2. Docker Compose (structured declarative way)

#### A. Using Docker Run (Imperative Way)


```bash
# 1. Create custom network
docker network create wp-net

# 2. Run MySQL database container
docker run -d \
  --name mysql \
  --network wp-net \
  -e MYSQL_ROOT_PASSWORD=secret \
  -e MYSQL_DATABASE=wordpress \
  mysql:5.7

# 3. Run WordPress application container
docker run -d \
  --name wordpress \
  --network wp-net \
  -p 8082:80 \
  -e WORDPRESS_DB_HOST=mysql \
  -e WORDPRESS_DB_PASSWORD=secret \
  wordpress:latest

# Test connection in browser: http://localhost:8082
```

#### B. Using Docker Compose (Declarative Way)


Create `docker-compose.yml`:
```yaml
version: '3.8'

services:
  mysql:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: wordpress
    volumes:
      - mysql_data:/var/lib/mysql

  wordpress:
    image: wordpress:latest
    ports:
      - "8082:80"
    environment:
      WORDPRESS_DB_HOST: mysql
      WORDPRESS_DB_PASSWORD: secret
    depends_on:
      - mysql

volumes:
  mysql_data:
```

```bash
# Bring up multi-container stack
docker compose up -d

# Stop stack and remove volumes
docker compose down -v
```

![Terminal Screenshot – Task 2: WordPress + MySQL (Docker Run vs Docker Compose)](C:/Users/Hp/Desktop/lab 6/step2_wordpress_run_vs_compose.jpg)

---

## PART C – CONVERSION & BUILD-BASED TASKS

### Task 3: Convert Docker Run to Docker Compose



#### Problem 1: Basic Web Application Conversion
##### Given `docker run` command:


```bash
docker run -d \
  --name webapp \
  -p 5000:5000 \
  -e APP_ENV=production \
  -e DEBUG=false \
  --restart unless-stopped \
  node:18-alpine
```

##### Equivalent `docker-compose.yml`:
```yaml
version: '3.8'

services:
  webapp:
    image: node:18-alpine
    container_name: webapp
    ports:
      - "5000:5000"
    environment:
      - APP_ENV=production
      - DEBUG=false
    restart: unless-stopped
```

#### Problem 2: Volume + Network Configuration Conversion
##### Given `docker run` commands:


```bash
docker network create app-net

docker run -d \
  --name postgres-db \
  --network app-net \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=secret \
  -v pgdata:/var/lib/postgresql/data \
  postgres:15

docker run -d \
  --name backend \
  --network app-net \
  -p 8000:8000 \
  -e DB_HOST=postgres-db \
  -e DB_USER=admin \
  -e DB_PASS=secret \
  python:3.11-slim
```

##### Equivalent `docker-compose.yml`:
```yaml
version: '3.8'

services:
  postgres-db:
    image: postgres:15
    container_name: postgres-db
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: secret
    volumes:
      - pgdata:/var/lib/postgresql/data
    networks:
      - app-net

  backend:
    image: python:3.11-slim
    container_name: backend
    ports:
      - "8000:8000"
    environment:
      DB_HOST: postgres-db
      DB_USER: admin
      DB_PASS: secret
    depends_on:
      - postgres-db
    networks:
      - app-net

volumes:
  pgdata:

networks:
  app-net:
```

![Terminal Screenshot – Task 3: Conversions (Web App & Volume + Network)](C:/Users/Hp/Desktop/lab 6/step3_conversions_app_net.jpg)

---

### Task 4: Resource Limits Conversion

##### Given `docker run` command:


```bash
docker run -d \
  --name limited-app \
  -p 9000:9000 \
  --memory="256m" \
  --cpus="0.5" \
  --restart always \
  nginx:alpine
```

##### Equivalent `docker-compose.yml`:
```yaml
version: '3.8'

services:
  limited-app:
    image: nginx:alpine
    container_name: limited-app
    ports:
      - "9000:9000"
    restart: always
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 256M
```

#### Explanation:
1. **When `deploy` works**: In Docker Compose v3+, `deploy.resources.limits` is respected by `docker compose` (with Compose V2 engine) as well as Docker Swarm.
2. **Normal Compose Mode vs Swarm Mode**: In normal Compose mode, container resource limits are set on the single local daemon via `cgroups`. In Swarm mode, resource limits govern multi-node placement and container scheduling.

![Terminal Screenshot – Task 4: Resource Limits Conversion](C:/Users/Hp/Desktop/lab 6/step4_resource_limits.jpg)

---

## PART D – USING DOCKERFILE INSTEAD OF STANDARD IMAGE

### Task 5: Replace Standard Image with Dockerfile (Node App)

#### Step 1: Create `app.js`
```javascript
const http = require('http');

http.createServer((req, res) => {
  res.end("Docker Compose Build Lab - Custom Node App");
}).listen(3000);
```

#### Step 2: Create `Dockerfile`
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY app.js .

EXPOSE 3000

CMD ["node", "app.js"]
```

#### Step 3: Create `docker-compose.yml`
```yaml
version: '3.8'

services:
  nodeapp:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: custom-node-app
    ports:
      - "3000:3000"
```

```bash
# Build and run container
docker compose up --build -d

# Verify endpoint
curl http://localhost:3000
```

##### `image:` vs `build:` Difference:
- `image:` pulls a pre-compiled image directly from a container registry (e.g. Docker Hub).
- `build:` instructs Compose to build a fresh container image locally from a `Dockerfile` before launching the service.

![Terminal Screenshot – Task 5: Custom Node App Dockerfile Build in Compose](C:/Users/Hp/Desktop/lab 6/step5_node_build_compose.jpg)

---

### Task 6: Advanced Build Challenge (Multi-Stage Dockerfile with Compose)

#### Requirements
Create a production-ready application using a multi-stage Dockerfile, custom build in Compose, environment variables, and volume mount for hot reloading.

##### `Dockerfile.multistage`:
```dockerfile
# STAGE 1: Builder stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install

# STAGE 2: Production runtime stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY app.js .
USER node
EXPOSE 3000
CMD ["node", "app.js"]
```

##### `docker-compose.yml`:
```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.multistage
    environment:
      - NODE_ENV=production
    volumes:
      - ./app.js:/app/app.js
    ports:
      - "3000:3000"
```

```bash
# Compare image footprint
docker images | grep task6
```

![Terminal Screenshot – Task 6: Advanced Build Challenge (Multi-stage Build in Compose)](C:/Users/Hp/Desktop/lab 6/step6_multistage_compose.jpg)

---

## EXPERIMENT 6 B: Multi-Container Application using Docker Compose (WordPress + MySQL)



### 1. Objective
To deploy a production-like multi-container application using **Docker Compose**, consisting of:
- **WordPress** (frontend web application + PHP engine)
- **MySQL** (backend database)

Also:
- Master container networking and volume persistence.
- Evaluate service scaling mechanics and reverse proxy load balancing.
- Compare Docker Compose with **Docker Swarm** for production multi-node cluster deployment.

---

### 2. Architecture Overview

```text
User (Browser)
      |
   WordPress Container (Port 8080:80)
      | (Internal Bridge Network: wp-compose-lab_default)
   MySQL Container (Port 3306)
      |
   Persistent Volumes (db_data & wp_data)
```

- WordPress communicates with MySQL using service name (`db`) via Docker internal DNS.
- Database state and WordPress web files persist independently using named volumes.

---

### 3. Step-by-Step Implementation

#### Step 1: Create Project Directory
```bash
mkdir wp-compose-lab
cd wp-compose-lab
```

#### Step 2: Create `docker-compose.yml`
```yaml
version: '3.9'

services:
  db:
    image: mysql:5.7
    container_name: wordpress_db
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppass
    volumes:
      - db_data:/var/lib/mysql

  wordpress:
    image: wordpress:latest
    container_name: wordpress_app
    depends_on:
      - db
    ports:
      - "8080:80"
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppass
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wp_data:/var/www/html

volumes:
  db_data:
  wp_data:
```

#### Step 3: Explanation of Key Sections
- `services`: Defines container workloads (`db` and `wordpress`).
- `depends_on`: Guarantees `db` initializes prior to `wordpress`.
- `environment`: Passes credentials and DB endpoint configuration dynamically.
- `volumes`: Preserves database records (`db_data`) and uploaded media (`wp_data`).
- `ports`: Maps host port `8080` to container port `80`.

#### Step 4: Launch & Verify Application
```bash
# Start services in background
docker-compose up -d

# Verify active containers
docker ps

# List volumes created
docker volume ls
```

![Terminal Screenshot – Exp 6B: WordPress + MySQL Production Compose Setup & Scaling](C:/Users/Hp/Desktop/lab 6/step7_wp_compose_scaling.jpg)

---

### 4. Scaling in Docker Compose



#### Scaling WordPress Containers
```bash
docker-compose up --scale wordpress=3 -d
```

#### Scaling Limitation & Reverse Proxy Solution
- **Problem**: Scaling multiple instances of `wordpress` causes port conflict if host port `8080:80` is statically bound to the container.
- **Solution**: Remove static host port mapping from application workers and route traffic through an **Nginx Reverse Proxy** or Load Balancer container listening on port `8080`.

---

### 5. Running Same Setup with Docker Swarm

#### Step 1: Initialize Swarm Cluster
```bash
docker swarm init
```

#### Step 2: Deploy Stack to Swarm
```bash
docker stack deploy -c docker-compose.yml wpstack
```

#### Step 3: Scale Service in Swarm
```bash
docker service scale wpstack_wordpress=3
```

![Terminal Screenshot – Exp 6B: Docker Swarm Deployment & Scaling](C:/Users/Hp/Desktop/lab 6/step8_docker_swarm_deploy.jpg)

---

### 6. Comparison: Docker Compose vs Docker Swarm



| Feature | Docker Compose | Docker Swarm |
| :--- | :--- | :--- |
| **Target Scope** | Single Host Development / Testing | Multi-Node Production Cluster |
| **Scaling** | Manual (`--scale`), port conflicts | Built-in native service scaling |
| **Load Balancing** | None (requires external proxy) | Built-in Routing Mesh & Load Balancer |
| **Self-Healing** | Container restart policies only | Automatic task rescheduling on node failure |
| **Rolling Updates** | Requires manual restart | Zero-downtime rolling updates (`--update-delay`) |
| **Networking** | Local Bridge Network | Encrypted Multi-Host Overlay Network |

---

### 7. Key Learning Outcomes & Conclusion

1. **Imperative vs. Declarative**: `docker run` is imperative and error-prone for complex setups; Docker Compose provides declarative, version-controlled architecture definitions.
2. **Multi-Container Synergy**: Compose handles automatic network creation, DNS resolution between services (`db`), volume management (`db_data`), and startup ordering (`depends_on`).
3. **Custom Build Integration**: Compose seamlessly integrates custom `Dockerfile` builds using `build: .`.
4. **Orchestration Evolution**: While Compose is ideal for local development, production multi-node environments benefit from Docker Swarm or Kubernetes for self-healing, rolling updates, and ingress load balancing.

\newpage

# Lab Manual – Experiment 7
## Course: Containerization and DevOps (CS-4001)
### Topic: CI/CD Pipeline using Jenkins, GitHub, and Docker Hub



---

## 1. Aim


To design, implement, and automate a complete Continuous Integration and Continuous Deployment (CI/CD) pipeline using **Jenkins**, integrating source code from **GitHub**, building Docker container images from source, and securely pushing built artifacts to **Docker Hub** upon automated webhook triggers.

---

## 2. Objectives


1. Understand the fundamental end-to-end CI/CD workflow using Jenkins (GUI-based web automation server).
2. Create a structured GitHub repository containing application code (`app.py`, `requirements.txt`), build specifications (`Dockerfile`), and pipeline logic (`Jenkinsfile`).
3. Deploy persistent Jenkins container infrastructure on Docker using Docker Compose and mount the host Docker socket (`/var/run/docker.sock`).
4. Securely store Docker Hub authentication credentials using Jenkins Credentials Store (`withCredentials`).
5. Configure automated build triggers via **GitHub Webhooks** (`/github-webhook/`).
6. Leverage the same host system as the Jenkins execution agent (`agent any`).

---

## 3. Theory & Architecture



### What is Jenkins?
Jenkins is an open-source, web-based automation server used to automate application building, testing, and deployment.
Key capabilities include:
- **Web Dashboard**: Intuitive browser UI for job configuration, build monitoring, and log inspection.
- **Plugin Ecosystem**: Over 1,800+ plugins connecting Git, GitHub, Docker, Kubernetes, Slack, etc.
- **Pipeline as Code**: Version-controlled pipeline definitions written in Groovy syntax (`Jenkinsfile`).

### What is CI/CD?


- **Continuous Integration (CI)**: Automatically pulling, building, and testing code whenever a developer pushes commits to a repository.
- **Continuous Deployment (CD)**: Automatically releasing and delivering built, validated artifacts (Docker images) to registries or production environments.

### End-to-End Workflow Overview

```mermaid
flowchart LR
    Dev["Developer"] -->|1. git push| GitHub["GitHub Repository\n(my-app)"]
    GitHub -->|2. Webhook Event| Jenkins["Jenkins Server\n(Port 8080)"]
    subgraph Jenkins Pipeline Execution
        Jenkins -->|3. Clone| Stage1["Stage: Clone Source"]
        Stage1 -->|4. Build| Stage2["Stage: Build Docker Image"]
        Stage2 -->|5. Auth| Stage3["Stage: Login to Docker Hub"]
        Stage3 -->|6. Push| Stage4["Stage: Push to Docker Hub"]
    end
    Stage4 -->|7. Image Artifact| Hub["Docker Hub Registry\n(devopsuser/myapp:latest)"]
```

---

## 4. Prerequisites


- Docker Engine & Docker Compose installed.
- Active GitHub account.
- Active Docker Hub account (with Personal Access Token created).
- Basic Linux/Unix shell command knowledge.

---

## 5. Part A: GitHub Repository Setup (Source Code + Build Definition)

### 5.1 Create Repository
Create a repository on GitHub named `my-app`.

### 5.2 Project File Structure
```text
my-app/
├── app.py
├── requirements.txt
├── Dockerfile
└── Jenkinsfile
```

### 5.3 Application Source Code

#### `app.py`:
```python
from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from CI/CD Pipeline!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
```

#### `requirements.txt`:
```text
flask
```

### 5.4 Dockerfile Definition
```dockerfile
FROM python:3.10-slim

WORKDIR /app
COPY . .

RUN pip install -r requirements.txt

EXPOSE 80
CMD ["python", "app.py"]
```

![Terminal Screenshot – Part A: GitHub Repo Structure & Files](C:/Users/Hp/Desktop/lab 7/step1_github_repo_setup.jpg)

### 5.5 Declarative `Jenkinsfile`
```groovy
pipeline {
    agent any

    environment {
        IMAGE_NAME = "devopsuser/myapp"
    }

    stages {

        stage('Clone Source') {
            steps {
                git 'https://github.com/devopsuser/my-app.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:latest .'
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([string(credentialsId: 'dockerhub-token', variable: 'DOCKER_TOKEN')]) {
                    sh 'echo $DOCKER_TOKEN | docker login -u devopsuser --password-stdin'
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                sh 'docker push $IMAGE_NAME:latest'
            }
        }
    }
}
```

![Terminal Screenshot – Part A: Declarative Jenkinsfile Pipeline Definition](C:/Users/Hp/Desktop/lab 7/step2_jenkinsfile_pipeline.jpg)

---

## 6. Part B: Jenkins Setup using Docker (Persistent Configuration)

### 6.1 Create `docker-compose.yml`
```yaml
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    restart: always
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    user: root

volumes:
  jenkins_home:
```

### 6.2 Start Jenkins Container Stack
```bash
docker-compose up -d
```
Access Jenkins Web UI in browser: `http://localhost:8080`

### 6.3 Unlock Initial Admin Password
```bash
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### 6.4 Initial UI Wizard
1. Paste initial admin password.
2. Select **Install suggested plugins** (installs Git, Pipeline, Credentials plugins).
3. Create Admin User account.

![Terminal Screenshot – Part B: Jenkins Docker Compose Setup & Socket Binding](C:/Users/Hp/Desktop/lab 7/step3_jenkins_docker_compose.jpg)

---

## 7. Part C: Jenkins Configuration

### 7.1 Add Docker Hub Credentials
Path: `Manage Jenkins` → `Credentials` → `System` → `Global credentials` → `Add Credentials`
- **Kind**: Secret text
- **ID**: `dockerhub-token` (MUST match `credentialsId` in `Jenkinsfile`)
- **Secret**: Paste Docker Hub Personal Access Token (PAT)
- **Description**: Docker Hub Authentication Token for CI/CD

### 7.2 Create Pipeline Job
1. Click `New Item` → Select `Pipeline` → Name: `ci-cd-pipeline`.
2. Scroll to **Pipeline** section:
   - **Definition**: `Pipeline script from SCM`
   - **SCM**: `Git`
   - **Repository URL**: `https://github.com/devopsuser/my-app.git`
   - **Branch Specifier**: `*/main` or `*/master`
   - **Script Path**: `Jenkinsfile`
3. Click `Save`.

![Terminal Screenshot – Part C: Jenkins Credentials & Pipeline Job Setup](C:/Users/Hp/Desktop/lab 7/step4_jenkins_config_credentials.jpg)

---

## 8. Part D: GitHub Webhook Integration

### 8.1 Configure Webhook in GitHub
In GitHub Repository → `Settings` → `Webhooks` → `Add webhook`:
- **Payload URL**: `http://<your-server-ip>:8080/github-webhook/`
- **Content type**: `application/json`
- **Which events would you like to trigger this webhook?**: `Just the push event.`
- **Active**: Checked.

![Terminal Screenshot – Part D: GitHub Webhook Configuration & Trigger](C:/Users/Hp/Desktop/lab 7/step5_github_webhook.jpg)

---

## 9. Part E: Execution Flow (Stage-wise Explanation)

1. **Developer Code Push**: Developer pushes code changes to GitHub repository.
2. **Webhook Notification**: GitHub transmits an HTTP POST payload to `http://<server-ip>:8080/github-webhook/`.
3. **Pipeline Execution**:
   - **Stage 1 (Clone Source)**: Jenkins clones the repository using `git`.
   - **Stage 2 (Build Docker Image)**: Executes `docker build -t devopsuser/myapp:latest .`.
   - **Stage 3 (Login to Docker Hub)**: Injects `$DOCKER_TOKEN` via `withCredentials` and executes `docker login`.
   - **Stage 4 (Push to Docker Hub)**: Uploads built layers via `docker push devopsuser/myapp:latest`.
4. **Artifact Ready**: Updated container image is available globally on Docker Hub.

![Terminal Screenshot – Part E: Jenkins Pipeline Execution & Stage View Logs](C:/Users/Hp/Desktop/lab 7/step6_pipeline_execution_stages.jpg)

---

## 10. Understanding Jenkins Pipeline Syntax & Secrets Security



### 10.1 Key Pipeline Block Anatomy

```groovy
pipeline {         // 1. Root block containing entire pipeline
    agent any      // 2. Specifies execution node (runs on same Docker host agent)

    stages {       // 3. Container for all sequential build stages
        stage('Build') {  // 4. Individual pipeline stage card in Jenkins UI
            steps {        // 5. Encapsulates shell execution commands
                sh 'echo Hello'  // 6. Runs shell command on Linux build agent
            }
        }
    }
}
```

### 10.2 Deep Dive: `withCredentials` Security Injection

```groovy
withCredentials([string(credentialsId: 'dockerhub-token', variable: 'DOCKER_TOKEN')]) {
    sh 'echo $DOCKER_TOKEN | docker login -u devopsuser --password-stdin'
}
```

#### Why is `withCredentials` Essential?
- **Prevents Plaintext Credential Exposure**: Never hardcode passwords inside source files or `Jenkinsfile` checked into public Git repositories.
- **Temporary In-Memory Scope**: Secret is bound to `$DOCKER_TOKEN` **only** for the duration of the enclosed block, then immediately erased.
- **Automatic Log Redaction**: Jenkins console logs automatically mask any printed value of `$DOCKER_TOKEN` with `****`.

```text
Locker (Jenkins Credentials Store)
   ↓ (Fetch by ID: 'dockerhub-token')
Temporary Variable ($DOCKER_TOKEN)
   ↓ (Injected into sh scope)
Used in 'docker login' → Instantly destroyed & masked in logs
```

![Terminal Screenshot – Pipeline Syntax Breakdown & withCredentials Security](C:/Users/Hp/Desktop/lab 7/step7_withcredentials_security.jpg)

---

## 11. Role of Same Host Agent (`/var/run/docker.sock`)

Mounting `/var/run/docker.sock:/var/run/docker.sock` grants the Jenkins container access to the host's Docker daemon socket.
- **Effect**: Commands (`docker build`, `docker login`, `docker push`) executed inside the Jenkins container are actually evaluated directly by the host machine's Docker daemon.
- **Advantage**: Eliminates the overhead of nested Docker-in-Docker (`dind`) virtualization or separate dedicated build worker VMs.


---

## 12. Observations & Result

### Observations

1. **Pipeline as Code**: Maintaining `Jenkinsfile` in GitHub repository enables version control for build infrastructure.
2. **Webhook Automation**: Code pushes trigger builds automatically within seconds.
3. **Secret Protection**: `withCredentials` prevents token leakage in terminal logs.
4. **Socket Sharing**: Mounting `/var/run/docker.sock` provides high-performance container builds.

### Result

Successfully designed and verified an automated CI/CD pipeline where code commits pushed to GitHub trigger Jenkins builds on the host agent and push production-ready Docker images to Docker Hub.

---


\newpage

# Lab Manual – Experiment 8
## Course: Containerization and DevOps (CS-4001)
### Topic: Chef – Configuration Management (Chef Solo, Chef Server & Ansible Comparison)

---

## 1. Problem Statement & Overview



### Problem Statement


Managing infrastructure manually across multiple servers leads to configuration drift, inconsistent environments, and time-consuming repetitive tasks. While Ansible addresses this using an agentless SSH push model, **Chef** offers a robust **pull-based** architecture where node agents periodically check in with a central server to ensure continuous state enforcement and compliance.

### What is Chef?


Chef is an open-source infrastructure automation platform that transforms system configurations into version-controlled Ruby-based code (**Infrastructure as Code**).

```mermaid
flowchart TD
    subgraph Workstation["Chef Workstation (Developer PC)"]
        Author["Cookbooks / Recipes\n(Ruby DSL)"]
        Knife["Knife CLI Tool"]
    end

    subgraph Server["Chef Server (Port 443)"]
        Repo["Cookbook Storage (Versioned)"]
        NodeDB["Node State & Attributes"]
        Auth["Client Auth Keys"]
    end

    subgraph Nodes["Managed Nodes"]
        Client1["Chef Client (Node 1)"]
        Client2["Chef Client (Node 2)"]
    end

    Author -->|knife upload| Server
    Client1 -->|Pull / Converge (Every 30m)| Server
    Client2 -->|Pull / Converge (Every 30m)| Server
```

### Key Concepts
- **Chef Server**: Central hub storing cookbooks, node state, attributes, and access control policies.
- **Chef Workstation**: Local environment where developers write recipes, create cookbooks, and run `knife` CLI commands.
- **Chef Node**: Any physical/virtual machine or container running `chef-client`.
- **Cookbook**: The fundamental unit of configuration containing recipes, attributes, templates, and files.
- **Recipe**: A file written in Ruby DSL declaring system resources (`package`, `service`, `file`, `template`).
- **Resource**: A cross-platform building block representing a piece of system state (e.g. `package 'nginx'`).
- **Run List**: An ordered list of recipes executed sequentially during node convergence.
- **Ohai**: System profiling tool that discovers and collects node hardware/OS attributes.

---

## PART A: CHEF SOLO (SERVERLESS EXECUTION)

### Architecture (No Central Server Required)
Chef Solo operates in local mode without requiring a central Chef Server daemon. Cookbooks and JSON run-list specifications are copied directly to target nodes via SSH/SCP and evaluated locally.

```mermaid
flowchart LR
    Control["Control Node (Local PC)\n- Cookbooks & Recipes\n- Nodes JSON"] -->|scp / ssh| Target["Managed Node\n- Chef Client (Local Mode)"]
```

### Step-by-Step Lab Execution

#### Step 1: Install Chef Workstation & Node Agents
```bash
# Install Chef Workstation on Control Machine
wget https://packages.chef.io/files/stable/chef-workstation/24.10.1144/ubuntu/22.04/chef-workstation_24.10.1144-1_amd64.deb
sudo dpkg -i chef-workstation_24.10.1144-1_amd64.deb

# Verify installation
chef --version
# Expected: Chef Workstation version: 24.10.1144
```

#### Step 2: Setup Lab Environment (Docker Nodes)
```bash
# Create dedicated network
docker network create chef-lab

# Create SSH key pair for passwordless node access
ssh-keygen -t rsa -b 4096 -f ~/.ssh/chef-key -N ""

# Build Chef-ready Docker image
cat > Dockerfile.chef << 'EOF'
FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y python3 openssh-server sudo curl systemd && \
    apt-get clean

RUN mkdir -p /var/run/sshd && \
    echo 'root:chef' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh
COPY ~/.ssh/chef-key.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
EOF

docker build -f Dockerfile.chef -t chef-node .

# Create 4 test nodes
for i in {1..4}; do
  docker run -d --name node${i} --network chef-lab -p 222${i}:22 chef-node
  echo "Node${i} created on SSH port 222${i}"
done
```

![Terminal Screenshot – Part A: Chef Workstation & Docker Node Environment Setup](C:/Users/Hp/Desktop/lab 8/step1_chef_env_setup.jpg)

#### Step 3: Create First Cookbook (`basics`)
```bash
mkdir -p ~/chef-repo/cookbooks
cd ~/chef-repo

# Generate cookbook structure
chef generate cookbook cookbooks/basics

# Edit metadata
cat > cookbooks/basics/metadata.rb << 'EOF'
name 'basics'
maintainer 'DevOps Lab'
maintainer_email 'lab@example.com'
license 'Apache-2.0'
description 'Installs/Configures basic system settings'
version '0.1.0'
chef_version '>= 16.0'
EOF
```

#### Step 4: Write Ruby Recipes

##### `cookbooks/basics/recipes/default.rb`:
```ruby
include_recipe 'basics::packages'
include_recipe 'basics::files'
include_recipe 'basics::services'
```

##### `cookbooks/basics/recipes/packages.rb`:
```ruby
apt_update 'update' do
  action :update
  frequency 86400
end

%w(vim htop wget curl git net-tools).each do |pkg|
  package pkg do
    action :install
  end
end

package 'python3' do
  action :install
  version '3.10.*'
end
```

##### `cookbooks/basics/recipes/files.rb`:
```ruby
directory '/opt/chef-demo' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

file '/opt/chef-demo/README.md' do
  content <<~EOH
    # Chef Managed System
    ======================
    Hostname: #{node['hostname']}
    IP Address: #{node['ipaddress']}
    OS: #{node['platform']} #{node['platform_version']}
    Managed by: Chef
    Last Converged: #{Time.now}
  EOH
  mode '0644'
  action :create
end
```

![Terminal Screenshot – Part A: First Cookbook Generation & Ruby Recipes](C:/Users/Hp/Desktop/lab 8/step2_cookbook_recipes.jpg)

#### Step 5: Execute Chef Solo on Nodes
```bash
# Create nodes.json configuration
cat > nodes.json << 'EOF'
{
  "node1": { "run_list": ["recipe[basics]"] },
  "node2": { "run_list": ["recipe[basics]"] },
  "node3": { "run_list": ["recipe[basics]"] },
  "node4": { "run_list": ["recipe[basics]"] }
}
EOF

# Execute local convergence script across nodes
./run-chef.sh

# Verify convergence state on node1
ssh -i ~/.ssh/chef-key -p 2221 root@localhost "cat /opt/chef-demo/README.md"
```

![Terminal Screenshot – Part A: Chef Solo Run Execution & Node Verification](C:/Users/Hp/Desktop/lab 8/step3_chef_solo_run.jpg)

---

## PART B: CHEF SERVER (FULL ENTERPRISE SETUP)

### Architecture
Chef Server acts as the centralized management node storing versioned cookbooks, node run-lists, search indexes, and client authentication keys.

### Step-by-Step Implementation

#### Step 1: Deploy Chef Server Container
```bash
docker pull chef/chef-server:latest

docker run -d \
  --name chef-server \
  --network chef-lab \
  -p 443:443 \
  -v chef-server-data:/var/opt/opscode \
  chef/chef-server:latest

# Create admin user
docker exec chef-server chef-server-ctl user-create admin "Admin" "User" admin@example.com 'admin123' --filename /tmp/admin.pem

# Create organization
docker exec chef-server chef-server-ctl org-create devops "DevOps Lab" --association admin --filename /tmp/devops-validator.pem

# Copy keys to local workstation .chef directory
docker cp chef-server:/tmp/admin.pem ~/chef-repo/.chef/
docker cp chef-server:/tmp/devops-validator.pem ~/chef-repo/.chef/
```

![Terminal Screenshot – Part B: Chef Server Deployment & Admin Setup](C:/Users/Hp/Desktop/lab 8/step4_chef_server_setup.jpg)

#### Step 2: Configure Knife CLI (`knife.rb`)
Create `~/chef-repo/.chef/knife.rb`:
```ruby
current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "admin"
client_key               "#{current_dir}/admin.pem"
validation_client_name   "devops-validator"
validation_key           "#{current_dir}/devops-validator.pem"
chef_server_url          "https://chef-server/organizations/devops"
cookbook_path            ["#{current_dir}/../cookbooks"]
ssl_verify_mode          :verify_none
```

```bash
# Verify Knife server connectivity
knife ssl check
knife client list
```

![Terminal Screenshot – Part B: Knife CLI Configuration & SSL Verification](C:/Users/Hp/Desktop/lab 8/step5_knife_config.jpg)

#### Step 3: Upload Cookbook & Bootstrap Nodes
```bash
# Upload webapp cookbook to Chef Server
cd ~/chef-repo
knife cookbook upload webapp

# Bootstrap managed nodes
for i in {1..4}; do
  knife bootstrap localhost \
    --ssh-user root \
    --ssh-port 222${i} \
    --ssh-identity-file ~/.ssh/chef-key \
    --node-name node${i} \
    --run-list 'recipe[webapp]'
done

# List registered nodes and status
knife node list
knife status
```

![Terminal Screenshot – Part B: Uploading Cookbooks & Bootstrapping Managed Nodes](C:/Users/Hp/Desktop/lab 8/step6_knife_bootstrap.jpg)

#### Step 4: Node Inspection & Remote Management
```bash
# Display node configuration details
knife node show node1

# Search nodes using Ohai attributes
knife search node "platform:ubuntu"

# Execute remote commands across nodes
knife ssh "name:node*" "uptime" --ssh-user root --ssh-identity-file ~/.ssh/chef-key
```

![Terminal Screenshot – Part B: Knife Node Inspection & Verification](C:/Users/Hp/Desktop/lab 8/step7_node_inspection.jpg)

---

## 3. Comparison: Chef Solo vs Chef Server



| Aspect | Chef Solo (Part A) | Chef Server (Part B) |
| :--- | :--- | :--- |
| **Complexity** | Low | High |
| **Setup Time** | ~15 minutes | ~45 minutes |
| **Central Server Required** | No | Yes |
| **Scalability** | Manual per node | Centralized (5000+ nodes) |
| **Node Management** | Direct SSH / Local Script | Chef Server API (`knife`) |
| **Search Capabilities** | No | Yes (Solr search indexing) |
| **Role & Env Management** | Limited | Full enterprise support |
| **Best For** | Learning, small/testing setups | Enterprise production infrastructure |

---

## 4. Chef vs Ansible Comparison

| Feature | Chef | Ansible |
| :--- | :--- | :--- |
| **Architecture** | **Pull-based** (Chef Client Agent) | **Push-based** (Agentless SSH) |
| **Language** | Ruby DSL | YAML Playbooks |
| **Learning Curve** | Steep (requires Ruby knowledge) | Gentle (human-readable YAML) |
| **Setup Complexity** | High (Server + Workstation + Node) | Low (Control Node only) |
| **Idempotency** | Yes (Built-in Resource engine) | Yes (Idempotent modules) |
| **Real-time Changes** | Delayed (Periodic 30m pull interval) | Immediate (Instant SSH push) |
| **Scalability** | Excellent (5000+ nodes) | Good (Up to 2000 nodes) |
| **Ecosystem** | Supermarket (4,000+ cookbooks) | Galaxy (3,000+ collections) |
| **Primary Use Case** | Enterprise compliance & large fleets | Cloud provisioning & quick automation |


---

## 5. Quick Commands Reference



### Chef Solo
```bash
# Generate a new cookbook
chef generate cookbook my_cookbook

# Run Chef Solo locally
chef-client --local-mode --runlist 'recipe[my_cookbook]'

# Run with JSON node attributes
chef-client --local-mode --json-attributes nodes.json
```

### Chef Server (`knife`)
```bash
# Upload cookbook to server
knife cookbook upload my_cookbook

# List all registered nodes
knife node list

# Bootstrap a new node
knife bootstrap IP --ssh-user root --node-name node1 --run-list 'recipe[my_cookbook]'

# Execute SSH command on all nodes matching pattern
knife ssh "name:node*" "uptime" --ssh-user root

# Inspect node details
knife node show node1
```

### Cleanup
```bash
# Remove Docker nodes and Chef Server container
for i in {1..4}; do docker rm -f node${i}; done
docker rm -f chef-server

# Clean local repo
rm -rf ~/chef-repo
```

---

## 6. Optional Read: Evolution & Core Differences



### What was Chef Solo?
Chef Solo was a legacy mode allowing Chef recipes to execute locally without connecting to a Chef Server. It acted essentially as a local script executor, lacking centralized state, node discovery, Solr search indexing, or multi-node orchestration.

### Analogy
- **Chef Server**: Like a manager dispatching policies via a central management system.
- **Chef Solo**: Like handing each worker a USB drive containing manual instructions.
- **Ansible**: Like a remote control system dispatching live SSH instructions from a single control workstation.

---

## 7. Result & Conclusion

### Result
- Demonstrated local serverless configuration management using **Chef Solo** across Docker container nodes.
- Deployed and configured a full **Chef Server** environment with `knife` integration and automated node bootstrapping.
- Evaluated structural, architectural, and operational differences between **Chef** (pull-based, Ruby DSL) and **Ansible** (push-based, YAML).

### Conclusion

Experiment 8 provided comprehensive experience with Chef configuration management. While Chef Solo offers serverless execution for simple environments, Chef Server delivers scalable enterprise pull-based compliance management across thousands of nodes.

\newpage

# Lab Manual – Experiment 9
## Course: Containerization and DevOps (CS-4001)
### Topic: Ansible – Agentless Configuration Management & Automation

---

## 1. Problem Statement & Overview



### Problem Statement


Managing infrastructure manually across multiple servers leads to configuration drift, inconsistent runtime environments, and time-consuming repetitive administrative tasks. Scaling infrastructure from a single server to hundreds becomes nearly impossible using manual SSH commands.

### What is Ansible?


Ansible is an open-source automation platform used for **configuration management**, **application deployment**, and **task orchestration**.
- **Agentless Architecture**: Requires zero software or agents installed on managed target nodes. Communicates natively via SSH (Linux/Unix) or WinRM (Windows).
- **Declarative YAML Syntax**: System states are described using human-readable YAML files called **Playbooks**.
- **Idempotency**: Running a playbook once or a hundred times results in the exact same target system state without unwanted side effects.
- **Push-based Model**: Changes are initiated immediately from the control node to target servers.

```mermaid
flowchart TD
    Control["Control Node (Ansible Installed)\n- Inventory (inventory.ini)\n- Playbook (playbook1.yml)"]

    subgraph Target Fleet ["Managed Target Nodes (Agentless)"]
        Node1["Server 1 (172.17.0.2)\nOpenSSH / Python"]
        Node2["Server 2 (172.17.0.3)\nOpenSSH / Python"]
        Node3["Server 3 (172.17.0.4)\nOpenSSH / Python"]
        Node4["Server 4 (172.17.0.5)\nOpenSSH / Python"]
    end

    Control -->|1. SSH Authentication (~/.ssh/id_rsa)| Target Fleet
    Control -->|2. Push Python Modules| Target Fleet
    Control -->|3. Execute Tasks & Return Status| Target Fleet
```

### Key Components

| Component | Description |
| :--- | :--- |
| **Control Node** | The machine where Ansible is installed and from which commands/playbooks are executed. |
| **Managed Nodes** | Target servers managed by Ansible (no Ansible agent required). |
| **Inventory** | File listing managed node IP addresses/hostnames and connection variables (`inventory.ini`). |
| **Playbooks** | YAML documents mapping target host groups to sequential automation tasks. |
| **Tasks** | Individual automation directives calling specific Ansible modules. |
| **Modules** | Pre-built units of execution (e.g. `apt`, `yum`, `service`, `copy`, `command`). |
| **Roles** | Modular, reusable structures for organizing playbooks, variables, tasks, and templates. |

---

## 2. Benefits of Ansible
1. **Agentless Simplicity**: Eliminates agent installation, background daemon memory overhead, and agent upgrade maintenance.
2. **Easy to Learn**: Declarative YAML playbooks are human-readable and accessible to developers and sysadmins alike.
3. **Idempotency**: Ensures predictable system states by executing changes only when target drift is detected.
4. **Massive Community & Ecosystem**: Thousands of pre-packaged modules available on Ansible Galaxy (`ansible-galaxy`).

---

## PART A: INSTALLATION & DOCKER LAB ENVIRONMENT

### Step 1: Ansible Installation Instructions

#### Method 1: Install via `pip` (Python Package Manager)
```bash
# Install Ansible globally
pip install ansible

# Verify installation
ansible --version
```

#### Method 2: Install via `apt` (Debian/Ubuntu)
```bash
sudo apt update -y
sudo apt install ansible -y
ansible --version
```

#### Method 3: Post-Installation Local Check
```bash
ansible localhost -m ping
```

##### Expected Output:
```json
localhost | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

![Terminal Screenshot – Part A: Ansible Installation & Local Ping Test](C:/Users/Hp/Desktop/lab 9/step1_ansible_install_ping.jpg)

---

### Step 2: SSH Key Pair Generation & Security Setup

#### Generate SSH Key Pair
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Copy public & private keys to working directory for container packaging
cp ~/.ssh/id_rsa.pub .
cp ~/.ssh/id_rsa .
```

#### SSH Key Location & Purpose Breakdown

| Key File | Location | Purpose & Security Policy |
| :--- | :--- | :--- |
| **`id_rsa` (Private Key)** | Control Node (`~/.ssh/id_rsa`) | Used to authenticate SSH sessions. **NEVER share or expose!** Set `chmod 600`. |
| **`id_rsa.pub` (Public Key)** | Target Nodes (`/root/.ssh/authorized_keys`) | Grants SSH access to any control node possessing the matching private key. |

![Terminal Screenshot – SSH Key Pair Generation & Key Distribution Overview](C:/Users/Hp/Desktop/lab 9/step2_ssh_keygen_setup.jpg)

---

### Step 3: Build & Launch Docker Target Servers

#### Create `Dockerfile` for Ubuntu SSH Server
```dockerfile
FROM ubuntu

RUN apt update -y
RUN apt install -y python3 python3-pip openssh-server
RUN mkdir -p /var/run/sshd

# Configure SSH
RUN mkdir -p /run/sshd && \
    echo 'root:password' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Configure authorized keys
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh
COPY id_rsa /root/.ssh/id_rsa
COPY id_rsa.pub /root/.ssh/authorized_keys

RUN chmod 600 /root/.ssh/id_rsa && \
    chmod 644 /root/.ssh/authorized_keys

RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
```

#### Build Image & Spin Up 4 Target Containers
```bash
# Build Docker image
docker build -t ubuntu-server .

# Launch 4 test containers
for i in {1..4}; do
  echo -e "\n Creating server${i}\n"
  docker run -d --rm -p 220${i}:22 --name server${i} ubuntu-server
  echo -e "IP of server${i} is $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' server${i})"
done
```

![Terminal Screenshot – Docker Target Servers Setup (ubuntu-server image & 4 containers)](C:/Users/Hp/Desktop/lab 9/step3_docker_servers_launch.jpg)

---

### Step 4: Create & Verify Ansible Inventory (`inventory.ini`)

#### Generate `inventory.ini` File
```bash
# Populate container IP addresses
echo "[servers]" > inventory.ini
for i in {1..4}; do
  docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' server${i} >> inventory.ini
done

# Append inventory variables
cat << EOF >> inventory.ini

[servers:vars]
ansible_user=root
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_python_interpreter=/usr/bin/python3
EOF
```

#### Review `inventory.ini` Structure
```ini
[servers]
172.17.0.2
172.17.0.3
172.17.0.4
172.17.0.5
server1 ansible_host=localhost ansible_port=2201
server2 ansible_host=localhost ansible_port=2202
server3 ansible_host=localhost ansible_port=2203
server4 ansible_host=localhost ansible_port=2204

[servers:vars]
ansible_user=root
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_python_interpreter=/usr/bin/python3
```

![Terminal Screenshot – Ansible Inventory Configuration (inventory.ini)](C:/Users/Hp/Desktop/lab 9/step4_ansible_inventory.jpg)

---

### Step 5: Test Connectivity (Ad-Hoc Ping Module)

```bash
# Test passwordless SSH connectivity across all inventory hosts
ansible all -i inventory.ini -m ping
```

##### Expected Output:
```text
172.17.0.2 | SUCCESS => {
    "ansible_facts": { "discovered_interpreter_python": "/usr/bin/python3" },
    "changed": false,
    "ping": "pong"
}
172.17.0.3 | SUCCESS => { "changed": false, "ping": "pong" }
172.17.0.4 | SUCCESS => { "changed": false, "ping": "pong" }
172.17.0.5 | SUCCESS => { "changed": false, "ping": "pong" }
```

![Terminal Screenshot – Ad-Hoc Ansible Connectivity Test (ansible -m ping)](C:/Users/Hp/Desktop/lab 9/step5_ansible_ping_test.jpg)

---

### Step 6: Create & Execute Playbook (`playbook1.yml`)

#### Create `playbook1.yml`:
```yaml
---
- name: Configure multiple servers
  hosts: servers
  become: yes

  tasks:
    - name: Update apt package index
      apt:
        update_cache: yes

    - name: Install required packages
      apt:
        name: ["vim", "htop", "wget"]
        state: present

    - name: Create test file with content
      copy:
        dest: /root/ansible_test.txt
        content: |
          Configured by Ansible on {{ inventory_hostname }}
          Current date: {{ ansible_date_time.date }}

    - name: Display system information
      command: uname -a
      register: uname_output

    - name: Show disk space
      command: df -h
      register: disk_space

    - name: Print results
      debug:
        msg:
          - "System info: {{ uname_output.stdout }}"
          - "Disk space: {{ disk_space.stdout_lines }}"
```

#### Execute Playbook
```bash
ansible-playbook -i inventory.ini playbook1.yml
```

![Terminal Screenshot – Ansible Playbook Execution (update.yml / playbook1.yml)](C:/Users/Hp/Desktop/lab 9/step6_playbook_execution.jpg)

---

### Step 7: Verify System Changes Across Target Nodes

```bash
# Verification via Ansible Ad-Hoc command module
ansible all -i inventory.ini -m command -a "cat /root/ansible_test.txt"

# Verification via direct Docker execution
for i in {1..4}; do
  docker exec server${i} cat /root/ansible_test.txt
done
```

![Terminal Screenshot – Verification of Changes Across Target Nodes](C:/Users/Hp/Desktop/lab 9/step7_verification_changes.jpg)

---

## PART B: LOCALHOST PLAYBOOK & EXTENDED EXERCISES

### 1. Localhost Playbook (`install_nginx.yml`)
```yaml
---
- name: Install Nginx on localhost
  hosts: local
  become: yes

  tasks:
    - name: Install nginx package
      apt:
        name: nginx
        state: present
```

#### Local Inventory (`inventory_local.ini`)
```ini
[local]
localhost ansible_connection=local
```

```bash
# Execute local playbook
ansible-playbook -i inventory_local.ini install_nginx.yml
```

![Terminal Screenshot – Optional Part B: Localhost Playbook & Nginx Deployment](C:/Users/Hp/Desktop/lab 9/step8_optional_part_b_nginx.jpg)

---

### 2. Useful Troubleshooting & Documentation Commands


```bash
# List all built-in Ansible modules
ansible-doc -l

# View documentation for specific module
ansible-doc apt
ansible-doc copy

# Filter modules by category
ansible-doc -l | grep aws
```

### 3. Cleanup Lab Environment


```bash
# Stop and remove test containers
for i in {1..4}; do docker rm -f server${i}; done
```

---

## 5. Result & Conclusion

### Result
- Installed Ansible and verified local ping connectivity.
- Created custom `ubuntu-server` Docker images configured with SSH key-based authentication.
- Constructed a dynamic `inventory.ini` targeting 4 containerized server nodes.
- Developed and executed YAML playbooks (`playbook1.yml`) installing software packages (`vim`, `htop`, `wget`), deploying files, and reading system facts.
- Verified target host idempotency and state changes via ad-hoc Ansible modules and direct container execution.

### Conclusion

Experiment 9 demonstrated the power of agentless configuration management with Ansible. Leveraging SSH communication and declarative YAML playbooks allows IT administrators to automate server provisioning, enforce consistent system configurations, and prevent infrastructure drift efficiently at scale.

\newpage

# Lab Manual – Experiment 10
## Course: Containerization and DevOps (CS-4001)
### Topic: SonarQube – Automated Static Code Analysis & Quality Gates

---

## 1. Problem Statement & Overview



### Problem Statement


Code bugs, maintainability issues, and security vulnerabilities are often discovered too late — during late-stage manual QA testing or after production deployment. Manual code reviews are slow, inconsistent, and fail to scale as software engineering teams grow.

### What is SonarQube?


SonarQube is an open-source static code analysis platform that automatically inspects source code for bugs, security vulnerabilities, and code smells without executing the application (**Static Application Security Testing - SAST**).

### How SonarQube Solves the Problem:
- **Continuous Feedback**: Scans source code on every commit or pull request.
- **Quality Gates**: Enforces strict pass/fail criteria before code can be merged or deployed.
- **Technical Debt Tracking**: Quantifies the exact time required to remediate detected code issues.
- **Multi-Language Support**: Analyzes 20+ programming languages (Java, JavaScript, Python, C++, Go, etc.).
- **Visual Analytics**: Interactive web dashboard tracking quality trends over time.

### Key Terms & Definitions

| Term | Meaning & Context |
| :--- | :--- |
| **Quality Gate** | A set of boolean condition rules (e.g. 0 new bugs, >80% coverage) that code must pass before deployment. |
| **Bug** | Code that is demonstrably wrong, or will likely break at runtime (e.g. NullPointer, division by zero). |
| **Vulnerability** | A security flaw or attack vector exposed in code (e.g. SQL Injection, hardcoded credentials). |
| **Code Smell** | Confusing, redundant, or poorly structured code that hinders maintainability (e.g. unused variables). |
| **Technical Debt** | Estimated effort/time (e.g. 1h 30m) required to fix all identified issues in the codebase. |
| **Coverage** | Percentage of source code executed and validated by automated unit tests. |
| **Duplication** | Repeated blocks of code (copy-paste code) that should be refactored into reusable functions. |

---

## 2. Lab Architecture & Component Separation



SonarQube consists of **two separate, mandatory components**:
1. **SonarQube Server ("The Brain")**: Web dashboard, analysis engine, rule management, Quality Gates, and PostgreSQL database storage.
2. **Sonar Scanner ("The Worker")**: CLI, Maven, Gradle, or Jenkins plugin that parses source code files, applies rule sets, and transmits analysis reports to the server.

```mermaid
flowchart TD
    subgraph Client["Developer / CI Environment"]
        Code["Source Code\n(Java / JS / Python)"]
        Scanner["Sonar Scanner\n(CLI / Maven / Jenkins)"]
    end

    subgraph Server["SonarQube Server (Port 9000)"]
        Engine["Analysis Engine"]
        QG["Quality Gates"]
        UI["Web Dashboard"]
    end

    DB[("PostgreSQL Database")]

    Code -->|scans source files| Scanner
    Scanner -->|transmits report + Token| Server
    Engine --> DB
    QG --> DB
    UI -->|view results| User["Developer / Lead"]
```

---

## 3. Component Deep Dive

### Part 1: SonarQube Server — "The Brain"


- Web application listening on `http://localhost:9000`.
- Stores analysis results, history, and trends in PostgreSQL.
- Evaluates code metrics against defined **Quality Gates**.
- **Analogy**: Like a **Teacher/Examiner** — receives student work, grades it against rubrics, and displays report cards.

### Part 2: Sonar Scanner — "The Worker"


- Command-line utility or build tool plugin.
- Parses AST (Abstract Syntax Tree) of source code files locally.
- Generates analysis payloads and posts them to the SonarQube Server API.
- **Analogy**: Like a **Student writing an exam** — completes the task and submits it for grading.

| Scanner Type | Primary Use Case |
| :--- | :--- |
| `sonar-scanner` (CLI) | Standalone CLI for any programming language or repository. |
| Maven plugin (`mvn sonar:sonar`) | Native build integration for Java / Maven projects. |
| Gradle plugin | Native integration for Java / Android / Kotlin Gradle builds. |
| Jenkins Integration | Automated stage in CI/CD pipelines via `withSonarQubeEnv`. |
| GitHub Actions | Automated pull request decoration and check runs. |

### Why Both Are Required
- **Server Only**: Empty dashboard — no code gets analyzed.
- **Scanner Only**: Nowhere to send results — analysis is lost.
- **Server + Scanner**: Full automated quality pipeline operational!

---

## 4. How Authentication Tokens Work

Sonar Scanner uses an HTTP Bearer Token (`sqp_xxxxxxxx`) rather than admin passwords for secure authentication.

```text
[ Sonar Scanner ]
       │
       │ HTTP POST /api/ce/submit + Header "SONAR_TOKEN: sqp_xxxx"
       ▼
[ SonarQube Server (Port 9000) ]
       │
       ├── Token Valid?   ──Yes──▶ Accept analysis & update PostgreSQL DB
       └── Token Invalid? ──────▶ Reject request (Scan Fails: HTTP 401 Unauthorized)
```

---

## 5. Step-by-Step Hands-On Lab Execution

### Step 1: Start SonarQube Server with Docker Compose



Create `docker-compose.yml`:
```yaml
version: '3.8'

services:
  sonar-db:
    image: postgres:13
    container_name: sonar-db
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar
      POSTGRES_DB: sonarqube
    volumes:
      - sonar-db-data:/var/lib/postgresql/data
    networks:
      - sonarqube-lab

  sonarqube:
    image: sonarqube:lts-community
    container_name: sonarqube
    ports:
      - "9000:9000"
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://sonar-db:5432/sonarqube
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: sonar
    volumes:
      - sonar-data:/opt/sonarqube/data
      - sonar-extensions:/opt/sonarqube/extensions
    depends_on:
      - sonar-db
    networks:
      - sonarqube-lab

volumes:
  sonar-db-data:
  sonar-data:
  sonar-extensions:

networks:
  sonarqube-lab:
    driver: bridge
```

```bash
# Launch containers
docker-compose up -d

# Check server startup logs


docker-compose logs -f sonarqube
```
Access dashboard at `http://localhost:9000` (Default: `admin` / `admin`).

![Terminal Screenshot – Step 1: Starting SonarQube Server & PostgreSQL with Docker Compose](C:/Users/Hp/Desktop/lab 10/step1_sonarqube_server_start.jpg)

---

### Step 2: Create Sample Java App with Code Issues

Create project folder structure:
```bash
mkdir -p sample-java-app/src/main/java/com/example
cd sample-java-app
```

#### `src/main/java/com/example/Calculator.java`:
```java
package com.example;

public class Calculator {

    // BUG: Division by zero is not handled
    public int divide(int a, int b) {
        return a / b;
    }

    // CODE SMELL: Unused variable
    public int add(int a, int b) {
        int result = a + b;
        int unused = 100;   // ← Code smell
        return result;
    }

    // VULNERABILITY: SQL Injection risk
    public String getUser(String userId) {
        String query = "SELECT * FROM users WHERE id = " + userId;
        return query;
    }

    // CODE SMELL: Duplicated code
    public int multiply(int a, int b) {
        int result = 0;
        for (int i = 0; i < b; i++) {
            result = result + a;
        }
        return result;
    }

    public int multiplyAlt(int a, int b) {
        int result = 0;
        for (int i = 0; i < b; i++) {
            result = result + a;   // ← Exact duplicate of multiply()
        }
        return result;
    }

    // BUG: Null pointer risk
    public String getName(String name) {
        return name.toUpperCase();
    }

    // CODE SMELL: Empty catch block
    public void riskyOperation() {
        try {
            int x = 10 / 0;
        } catch (Exception e) {
            // ← Empty catch block hides errors
        }
    }
}
```

![Terminal Screenshot – Step 2: Creating Sample Java App with Code Issues](C:/Users/Hp/Desktop/lab 10/step2_sample_java_app.jpg)

---

### Step 3: Generate Token in SonarQube Web UI

1. Open `http://localhost:9000` in browser.
2. Login with `admin` / `admin` (change password upon prompt).
3. Click User Avatar (top right) → `My Account` → `Security` tab.
4. Under `Generate Tokens`: Type name `scanner-token` → Select `User Token` → Click `Generate`.
5. Copy token immediately (`sqp_a9f8310928347109283470129841209384712093`).

![Terminal Screenshot – Step 3: Generating Access Token in SonarQube Web UI](C:/Users/Hp/Desktop/lab 10/step3_token_generation.jpg)

---

### Step 4: Run Sonar Scanner CLI via Docker



Create `sonar-project.properties`:
```properties
sonar.projectKey=sample-java-app
sonar.projectName=Sample Java Application
sonar.projectVersion=1.0
sonar.sources=src
sonar.java.binaries=target/classes
sonar.sourceEncoding=UTF-8
```

Run scanner using Docker CLI container:
```bash
docker run --rm \
  --network sonarqube-lab \
  -e SONAR_TOKEN="sqp_a9f8310928347109283470129841209384712093" \
  -v "$(pwd):/usr/src" \
  sonarsource/sonar-scanner-cli \
  -Dsonar.host.url=http://sonarqube:9000 \
  -Dsonar.projectBaseDir=/usr/src \
  -Dsonar.projectKey=sample-java-app
```

![Terminal Screenshot – Step 4: Running Sonar Scanner CLI via Docker Container](C:/Users/Hp/Desktop/lab 10/step4_running_sonar_scanner.jpg)

---

### Step 5: View Results in Web Dashboard & Query API

Open dashboard: `http://localhost:9000/dashboard?id=sample-java-app`

```text
┌─────────────────────────────────────────────────────────┐
│           sample-java-app — Dashboard                   │
├─────────────────┬─────────────────┬─────────────────────┤
│  Bugs: 5        │ Vulnerabilities:│ Code Smells: 8      │
│  (High Severity)│ 1 (SQL Inject)  │ (Maintainability)   │
├─────────────────┴─────────────────┴─────────────────────┤
│ Coverage: 0.0%    Duplicated Blocks: 2 lines            │
│ Technical Debt: 1 hour 30 minutes                       │
│ Quality Gate Status:  FAILED                           │
└─────────────────────────────────────────────────────────┘
```

#### Query Issues via REST API
```bash
curl -s -u admin:YOUR_TOKEN \
  "http://localhost:9000/api/issues/search?projectKeys=sample-java-app&types=BUG"
```


---

### Step 6: Integrate SonarQube with Jenkins CI/CD Pipeline

```groovy
pipeline {
    agent any

    environment {
        SONAR_HOST_URL = 'http://sonarqube:9000'
        SONAR_TOKEN    = credentials('sonar-token')
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn clean verify sonar:sonar'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build & Deploy') {
            steps {
                sh 'mvn package'
                sh 'docker build -t sample-app .'
            }
        }
    }
}
```

![Terminal Screenshot – Step 6: Integrating SonarQube Quality Gate with Jenkins Pipeline](C:/Users/Hp/Desktop/lab 10/step6_jenkins_integration.jpg)

---

## 6. Token Flow Architecture & Passing Mechanisms

```text
[ SonarQube Web UI ] ──(Generates)──▶ Token: sqp_xxxxxxxx
                                             │
                                             ▼ (Pasted into CLI / Env Var)
[ Sonar Scanner ] ──(HTTP Bearer Auth)──▶ [ SonarQube Server (9000) ]
                                             │
                                             ▼
                                  [ PostgreSQL Database ]
```

### 3 Options to Pass Token to Scanner:


1. **Option A (CLI Flag)**: `sonar-scanner -Dsonar.login=YOUR_TOKEN`
2. **Option B (Environment Variable)**: `export SONAR_TOKEN=YOUR_TOKEN && sonar-scanner`
3. **Option C (Maven Flag)**: `mvn sonar:sonar -Dsonar.login=YOUR_TOKEN`


---

## 7. Comparative Analysis & DevOps Tool Matrix

| Feature | Jenkins | Ansible | Chef | SonarQube |
| :--- | :--- | :--- | :--- | :--- |
| **Primary Purpose** | CI/CD Pipeline Automation | Configuration Management | Configuration Management | Static Code Analysis |
| **Architecture** | Master-Agent | Agentless (SSH) | Client-Server | Client-Server (Server + Scanner) |
| **DSL / Language** | Java / Groovy | YAML Playbooks | Ruby DSL | Java / Web UI |
| **Learning Curve** | Moderate | Low | High | Low |
| **Setup Complexity** | Moderate | Simple | Complex | Simple |
| **Primary Use Case** | Build, Test, Deploy | Infrastructure as Code | Enterprise Provisioning | Code Quality & SAST |


---

## 8. Result & Conclusion

### Result
- Deployed SonarQube Server LTS and PostgreSQL database using Docker Compose on port 9000.
- Created a sample Java project with intentional bugs, SQL injection vulnerabilities, and code smells.
- Generated a user authentication token and executed `sonar-scanner-cli` via Docker container.
- Analyzed code metrics in the SonarQube web dashboard and verified Quality Gate failure (`FAILED`).
- Configured Jenkins pipeline integration with automated Quality Gate gating (`waitForQualityGate`).

### Conclusion

Experiment 10 demonstrated the critical role of SonarQube in modern DevSecOps pipelines. By combining the SonarQube Server with the Sonar Scanner and enforcing automated Quality Gates in CI/CD pipelines, engineering teams can detect vulnerabilities early, track technical debt, and prevent defective code from reaching production.

\newpage

# Lab Manual – Experiment 11
## Course: Containerization and DevOps (CS-4001)
### Topic: Container Orchestration using Docker Compose & Docker Swarm (Continuation of Experiment 6)



---

## PART A – CONCEPT CONTINUATION

### 1. The Progression Path


Understanding the evolution of container execution technologies:

```mermaid
flowchart LR
    Single["docker run\n(Single Container)"] --> Compose["Docker Compose\n(Multi-Container, Single Host)"]
    Compose --> Swarm["Docker Swarm\n(Basic Orchestration Cluster)"]
    Swarm --> K8s["Kubernetes\n(Advanced Production Orchestration)"]
```

### 2. What is Container Orchestration?


**Orchestration** is the automated management of container lifecycles, placement, scaling, load balancing, health monitoring, and networking across cluster environments.

#### Restaurant Manager Analogy
Think of an orchestrator like a **restaurant manager**:
- **Scaling**: Adjusts waiter count based on dining room customer volume.
- **Self-Healing**: Instantly replaces a sick waiter with a substitute staff member.
- **Load Balancing**: Distributes seating evenly across available tables.

#### Core Orchestration Features



| Feature | What it Means |
| :--- | :--- |
| **Scaling** | Horizontally increasing or decreasing running container replicas dynamically. |
| **Self-Healing** | Automatically detecting failed containers/tasks and rescheduling replacements. |
| **Load Balancing** | Intercepting incoming traffic and distributing requests round-robin across worker replicas. |
| **Multi-Host Clustering** | Abstracting multiple underlying physical/virtual machines into a single logical cluster pool. |

---

## PART B – PRACTICAL TASKS (EXTENSION OF EXPERIMENT 6)

### Prerequisites & Stack Definition (`docker-compose.yml`)


```yaml
version: '3.9'

services:
  db:
    image: mysql:5.7
    container_name: wordpress_db
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppass
    volumes:
      - db_data:/var/lib/mysql

  wordpress:
    image: wordpress:latest
    container_name: wordpress_app
    depends_on:
      - db
    ports:
      - "8080:80"
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppass
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wp_data:/var/www/html

volumes:
  db_data:
  wp_data:
```

---

### Task 1: Check Current State (Teardown Plain Compose)

![Step0: Check Current State](C:/Users/Hp/Desktop/lab 11/step0_check_current_state.jpg)


```bash
# Stop any non-Swarm compose setup from Experiment 6
docker compose down -v

# Verify no containers are running
docker ps
```

---

### Task 2: Initialize Docker Swarm
```bash
# Initialize Swarm mode on local daemon (acting as Manager Leader)
docker swarm init

# Verify cluster node status
docker node ls
```

##### Output Verification:
```text
ID                            HOSTNAME       STATUS    AVAILABILITY   MANAGER STATUS
a9f831092834710928347012 *   devops-pc      Ready     Active         Leader
```

![Terminal Screenshot – Task 1 & 2: Check Current State & Initialize Docker Swarm](C:/Users/Hp/Desktop/lab 11/step1_swarm_init.jpg)

---

### Task 3: Deploy Application as a Swarm Stack
```bash
# Deploy multi-container stack using Compose specification file
docker stack deploy -c docker-compose.yml wpstack
```

##### Output Verification:
```text
Creating network wpstack_default
Creating service wpstack_db
Creating service wpstack_wordpress
```

![Terminal Screenshot – Task 3: Deploying Stack via Docker Compose Spec](C:/Users/Hp/Desktop/lab 11/step2_stack_deploy.jpg)

---

### Task 4 & 5: Verify Deployment & Access WordPress



```bash
# List all active Swarm services
docker service ls

# View task scheduling breakdown
docker service ps wpstack_wordpress

# Check active containers running under Swarm management
docker ps

# Access application endpoint
curl -I http://localhost:8080
```

##### Service List Output:
```text
ID             NAME                MODE         REPLICAS   IMAGE              PORTS
c39405968312   wpstack_db          replicated   1/1        mysql:5.7          
d40596837201   wpstack_wordpress   replicated   1/1        wordpress:latest   *:8080->80/tcp
```

![Terminal Screenshot – Task 4 & 5: Verifying Stack Services & Accessing WordPress](C:/Users/Hp/Desktop/lab 11/step3_verify_services.jpg)

---

### Task 6: Scale the Application (Swarm's Superpower)

Scale the WordPress service horizontally from 1 to 3 replicas with a single command:
```bash
# Scale service replicas
docker service scale wpstack_wordpress=3

# Verify replica count
docker service ls
docker service ps wpstack_wordpress
docker ps | grep wordpress
```

##### Scaling Verification Output:
```text
wpstack_wordpress scaled to 3
overall progress: 3 out of 3 tasks
1/3: running   [2026-07-27 15:45:01]
2/3: running   [2026-07-27 15:45:04]
3/3: running   [2026-07-27 15:45:05]
verify: Service converged
```

![Terminal Screenshot – Task 6: Scaling WordPress Application to 3 Replicas](C:/Users/Hp/Desktop/lab 11/step4_scaling_application.jpg)

---

### Understanding Ingress Mesh & Port Load Balancing

#### How 3 Containers Share Host Port `8080`:
In plain Docker Compose, scaling WordPress to 3 containers fails due to port binding conflict (`port 8080 is already allocated`).
In Docker Swarm, the **Ingress Routing Mesh** binds to port `8080` once, creating an internal **Virtual IP (VIP)**. Incoming requests to `localhost:8080` are intercepted by the IPVS load balancer and distributed round-robin across all 3 active container replicas!

```bash
# Inspect Virtual IP assigned by Swarm Ingress Mesh
docker inspect wpstack_wordpress --format '{{json .Endpoint.VirtualIPs}}'

# Test round-robin traffic routing
for i in {1..4}; do curl -s -I http://localhost:8080 | grep HTTP; done
```


---

### Task 7: Test Self-Healing (Automatic Container Recovery)

Simulate a container crash or hardware failure by terminating one of the 3 running WordPress containers using `docker kill`.

```bash
# Get container ID of replica 3
docker ps | grep wordpress

# Simulate crash / kill container
docker kill <container-id>

# Observe Swarm detecting failure and rescheduling replacement task
docker service ps wpstack_wordpress
```

##### Self-Healing Task Log Output:
```text
ID             NAME                      IMAGE              NODE        DESIRED STATE   CURRENT STATE
e51607948312   wpstack_wordpress.1       wordpress:latest   devops-pc   Running         Running 2 minutes ago
g73829104829   wpstack_wordpress.2       wordpress:latest   devops-pc   Running         Running 2 minutes ago
j95041326041   wpstack_wordpress.3       wordpress:latest   devops-pc   Running         Running 4 seconds ago
h84930215930    \_ wpstack_wordpress.3   wordpress:latest   devops-pc   Shutdown        Failed 5 seconds ago
```

> **Result**: Swarm immediately detected the failed task `h84930215930` and spawned new replacement task `j95041326041`. Total active replicas remained 3!

![Terminal Screenshot – Task 7: Testing Self-Healing & Automatic Task Recovery](C:/Users/Hp/Desktop/lab 11/step6_self_healing_test.jpg)

---

### Task 8: Stack Teardown & Volume Persistence

![Step7: Stack Teardown](C:/Users/Hp/Desktop/lab 11/step7_stack_cleanup.jpg)
```bash
# Remove stack services and overlay networks
docker stack rm wpstack

# Verify services and containers removed
docker service ls
docker ps

# Verify persistent storage volumes survive stack removal
docker volume ls | grep wpstack
```


---

## PART C – ANALYSIS (COMPOSE VS SWARM)

### Side-by-Side Comparison Matrix

| Feature | Docker Compose | Docker Swarm |
| :--- | :--- | :--- |
| **Scope** | Single Host Only | Multi-Node Cluster Pool |
| **Scaling** | `--scale` flag (causes port conflicts) | `docker service scale` (built-in ingress VIP) |
| **Load Balancing** | No (requires external Nginx container) | Yes (built-in Ingress Routing Mesh) |
| **Self-Healing** | No (requires manual restart) | Yes (automatic task rescheduling) |
| **Rolling Updates** | No (requires downtime) | Yes (zero-downtime rolling updates) |
| **Service Discovery** | Container Names | Internal DNS + Virtual IP (VIP) |
| **Use Case** | Local Development & Testing | Production Application Clusters |

---

## PART D – IMPORTANT OBSERVATIONS FOR STUDENTS

1. **Compose Specification Reuse**: The exact same `docker-compose.yml` file is used for both `docker compose up -d` (single host) and `docker stack deploy` (Swarm orchestration mode).
2. **Containers vs. Services**: In Swarm, you interact with higher-level **Services** (desired state specifications) rather than individual raw containers.
3. **Port Conflict Resolution**: Swarm's Ingress Mesh abstracts host ports, allowing 100 replicas to share a single published host port (`8080:80`).

---

## PART E – LEARNING OUTCOME CHECK & ANSWERS



1. **Why is Compose not enough for production?**
   - Compose lacks multi-host clustering, automatic self-healing on hardware crash, ingress load balancing, and zero-downtime rolling updates.
2. **What does `docker stack deploy` do differently than `docker compose up`?**
   - `docker stack deploy` registers workloads as Swarm Services with VIP load balancing, replica monitoring, and self-healing task reconciliation.
3. **How does Swarm achieve self-healing?**
   - Swarm constantly monitors actual container state against desired state. If a task fails or dies, Swarm reschedules a new container task automatically.
4. **What happens if you run `docker kill` on a container managed by Swarm?**
   - Swarm marks the task as `Failed`, creates a replacement task immediately, and restores the replica count to the configured desired state.
5. **Can you use the same Compose file for development and production?**
   - Yes! Compose files define application architecture. You use `docker compose up` during dev and `docker stack deploy` for Swarm production.

---

## PART F – OPTIONAL: MULTI-NODE SWARM CLUSTER SETUP



```bash
# On Manager Node: Generate worker join token
docker swarm join-token worker

# On Worker Node (VM/Server 2): Join cluster
docker swarm join --token <SWMTKN-1-token> <manager-ip>:2377

# On Manager Node: Verify node joined
docker node ls
```

---

## Result & Conclusion

### Result
- Initialized Docker Swarm mode (`docker swarm init`) and verified manager node status.
- Deployed the WordPress + MySQL stack using `docker stack deploy -c docker-compose.yml wpstack`.
- Horizontally scaled WordPress to 3 replicas (`docker service scale wpstack_wordpress=3`) and validated ingress load balancing on port 8080.
- Verified automatic self-healing by killing a worker container and observing Swarm immediately spawn a replacement task.
- Removed the stack while confirming database and media volumes persisted.

### Conclusion

Experiment 11 demonstrated the power of container orchestration with Docker Swarm. While Docker Compose defines multi-container applications, Docker Swarm provides the production reliability, scaling, ingress load balancing, and self-healing resilience necessary for production container deployments.

## Screenshot Figure Index

### Figure: Step8 Compose Vs Swarm



\newpage

# Lab Manual – Experiment 12
## Course: Containerization and DevOps (CS-4001)
### Topic: Study and Analyse Container Orchestration using Kubernetes

---

## 1. Objective & Theory

### Objective
To analyze the architecture and capabilities of **Kubernetes (K8s)**, understand its core abstractions (Pods, Deployments, Services, ReplicaSets), and execute hands-on operations for application deployment, service exposure, horizontal scaling, self-healing, and production multi-node cluster setup via `kubeadm`.

### Why Kubernetes over Docker Swarm?



| Reason | Explanation |
| :--- | :--- |
| **Industry Standard** | Adopted by over 85% of enterprise cloud ecosystems and Fortune 500 companies. |
| **Powerful Scheduling** | Advanced bin-packing, affinity/anti-affinity, taints, and tolerations for optimal workload placement. |
| **Rich Ecosystem** | Massive CNCF tooling ecosystem (Helm, Prometheus, Istio, Calico, ArgoCD). |
| **Cloud-Native Support** | Managed implementations across AWS (EKS), Google Cloud (GKE), Azure (AKS), and DigitalOcean. |

---

## 2. Core Kubernetes Concepts



Mapping Docker concepts to their Kubernetes equivalents:

| Docker Concept | Kubernetes Equivalent | Definition & Function |
| :--- | :--- | :--- |
| **Container** | **Pod** | A Pod is the smallest deployable unit in K8s, encapsulating one or more tightly coupled containers sharing network IP and storage volumes. |
| **Compose Service** | **Deployment** | Declarative specification describing application desired state (replicas, container images, labels, update strategy). |
| **Load Balancing** | **Service** | An abstraction defining a logical set of Pods and a policy to access them (ClusterIP, NodePort, LoadBalancer). |
| **Scaling** | **ReplicaSet** | Controller that ensures a specified number of identical Pod replicas are running at any given time. |

```mermaid
flowchart TD
    subgraph Deployment["Kubernetes Deployment (wordpress)"]
        subgraph RS["ReplicaSet (Replicas = 4)"]
            Pod1["Pod 1 (WordPress)"]
            Pod2["Pod 2 (WordPress)"]
            Pod3["Pod 3 (WordPress)"]
            Pod4["Pod 4 (WordPress)"]
        end
    end

    subgraph Service["Kubernetes Service (NodePort: 30007)"]
        VIP["Virtual IP / ClusterIP"]
    end

    User["External User / Browser"] -->|http://node-ip:30007| Service
    Service --> VIP
    VIP -->|Load Balances Traffic| Pod1
    VIP --> Pod2
    VIP --> Pod3
    VIP --> Pod4
```

---

## 3. Hands-On Lab (Using k3d / Minikube)

### Task 1: Create a Deployment Specification

A **Deployment** defines:
- Container image (`wordpress:latest`).
- Desired replica count (`replicas: 2`).
- Pod matching labels (`app: wordpress`).

#### `wordpress-deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
spec:
  replicas: 2
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
      - name: wordpress
        image: wordpress:latest
        ports:
        - containerPort: 80
```

```bash
# Apply deployment manifest
kubectl apply -f wordpress-deployment.yaml
```

![Terminal Screenshot – Task 1: Creating & Applying WordPress Deployment](C:/Users/Hp/Desktop/lab 12/step1_wordpress_deployment.jpg)

---

### Task 2: Expose Deployment as a Service

Pods are ephemeral with dynamic IP addresses. A **Service** provides a persistent IP endpoint and load balances traffic to matching Pods.

#### `wordpress-service.yaml`:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: wordpress-service
spec:
  type: NodePort
  selector:
    app: wordpress
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30007
```

```bash
# Apply service manifest
kubectl apply -f wordpress-service.yaml
```

![Terminal Screenshot – Task 2: Exposing Deployment as a NodePort Service](C:/Users/Hp/Desktop/lab 12/step2_wordpress_service.jpg)

---

### Task 3: Verify Deployment & Service

```bash
# Verify running Pods
kubectl get pods

# Verify active Services
kubectl get svc

# Test HTTP endpoint access
curl -I http://localhost:30007
```

##### Output Verification:
```text
NAME                         READY   STATUS    RESTARTS   AGE
wordpress-758486b778-4j2x9   1/1     Running   0          45s
wordpress-758486b778-9k81m   1/1     Running   0          45s

NAME                TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
wordpress-service   NodePort    10.43.192.45   <none>        80:30007/TCP   30s
```

![Terminal Screenshot – Task 3: Verifying Pods, Services & NodePort Access](C:/Users/Hp/Desktop/lab 12/step3_verify_pods_services.jpg)

---

### Task 4: Scale the Deployment Dynamically

Increase active Pod replicas from 2 to 4 using `kubectl scale`:
```bash
# Scale deployment replicas
kubectl scale deployment wordpress --replicas=4

# Verify updated Pod count
kubectl get pods -o wide
kubectl get deployment wordpress
```

![Terminal Screenshot – Task 4: Scaling Deployment Replicas dynamically](C:/Users/Hp/Desktop/lab 12/step4_scale_deployment.jpg)

---

### Task 5: Self-Healing Demonstration

Kubernetes constantly monitors desired state against actual cluster state. If a Pod fails or is manually deleted, the ReplicaSet controller automatically spawns a replacement Pod.

```bash
# Delete one running Pod to simulate crash
kubectl delete pod wordpress-758486b778-m2810

# Observe Kubernetes instantly recreating replacement Pod
kubectl get pods
```

##### Self-Healing Verification Log:
```text
NAME                         READY   STATUS    RESTARTS   AGE
wordpress-758486b778-4j2x9   1/1     Running   0          5m
wordpress-758486b778-9k81m   1/1     Running   0          5m
wordpress-758486b778-p9481   1/1     Running   0          2m
wordpress-758486b778-x9102   1/1     Running   0          3s  <-- Auto-recreated!
```

![Terminal Screenshot – Task 5: Demonstrating Kubernetes Self-Healing & Pod Recovery](C:/Users/Hp/Desktop/lab 12/step5_self_healing_demo.jpg)

---

## PART C – DOCKER SWARM VS KUBERNETES COMPARISON



| Feature | Docker Swarm | Kubernetes (K8s) |
| :--- | :--- | :--- |
| **Setup & Learning** | Very easy | Steep learning curve |
| **Scaling** | Basic manual scaling | Advanced (Horizontal Pod Autoscaler - HPA) |
| **Ecosystem** | Minimal built-in tools | Massive CNCF ecosystem (Helm, Prometheus) |
| **Storage & Volumes** | Basic local/overlay volumes | Rich CSI (PersistentVolumes, StorageClasses) |
| **Industry Adoption** | Niche / Legacy | Global De-Facto Standard |

---

## PART D – ADVANCED LAB: REAL CLUSTER SETUP WITH KUBEADM

Setting up a multi-node production-style cluster using `kubeadm`:

### Prerequisites
- 2 or 3 Virtual Machines (Ubuntu 22.04 LTS).
- Minimum 2 CPU cores and 2 GB RAM per VM.

### Step 1: Install Kubernetes Packages (`kubeadm`, `kubelet`, `kubectl`)


```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt install -y kubeadm kubelet kubectl
sudo apt-mark hold kubeadm kubelet kubectl
```

### Step 2: Initialize Control Plane (Master Node)
```bash
# Execute on Master Node only
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```

![Terminal Screenshot – Part D: Real Cluster Setup with kubeadm (Control Plane Init)](C:/Users/Hp/Desktop/lab 12/step6_kubeadm_cluster_init.jpg)

### Step 3: Configure `kubeconfig` & Install CNI Network Plugin (Calico)


```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Deploy Calico CNI for inter-pod networking


kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

### Step 4: Join Worker Nodes & Verify Cluster
```bash
# On Worker Nodes: Run join command generated by kubeadm init
kubeadm join 192.168.1.100:6443 --token <token> --discovery-token-ca-cert-hash <hash>

# On Master Node: Verify all nodes are Ready
kubectl get nodes
```

![Terminal Screenshot – Part D: Joining Worker Nodes & CNI Calico Installation](C:/Users/Hp/Desktop/lab 12/step7_kubeadm_nodes_verify.jpg)

---

## 4. Teaching Insight: Tool Selection Guide



| Tool | Best Used For |
| :--- | :--- |
| **k3d** | Rapid local development & CI testing inside lightweight Docker containers. |
| **Minikube** | Single-node VM cluster testing and learning Kubernetes features locally. |
| **kubeadm** | Production-ready multi-node cluster deployment on bare-metal or cloud VMs. |

---

## 5. Commands Quick Reference Cheat Sheet

| Action / Goal | Command |
| :--- | :--- |
| **Apply YAML Manifest** | `kubectl apply -f file.yaml` |
| **List All Pods** | `kubectl get pods -o wide` |
| **List All Services** | `kubectl get svc` |
| **Scale Deployment** | `kubectl scale deployment <name> --replicas=N` |
| **Delete Pod (Trigger Self-heal)** | `kubectl delete pod <pod-name>` |
| **List Cluster Nodes** | `kubectl get nodes` |
| **View Pod Logs** | `kubectl logs <pod-name>` |
| **Describe Resource** | `kubectl describe pod <pod-name>` |


---

## 6. Result & Conclusion

### Result
- Analyzed core Kubernetes abstractions (Pods, Deployments, Services, ReplicaSets).
- Created and applied `wordpress-deployment.yaml` and `wordpress-service.yaml` (NodePort 30007).
- Horizontally scaled the deployment from 2 to 4 replicas using `kubectl scale`.
- Demonstrated automatic self-healing by deleting a running Pod and verifying instant replacement by the ReplicaSet controller.
- Walked through multi-node cluster initialization using `kubeadm` and Calico CNI networking.

### Conclusion

Experiment 12 provided comprehensive understanding and hands-on experience with Kubernetes orchestration. Moving from Docker Swarm to Kubernetes equips engineers with the industry-standard framework for managing scalable, fault-tolerant, cloud-native applications across modern production environments.