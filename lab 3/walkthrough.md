# Experiment 3 Completion Walkthrough

## Summary of Accomplishments
Completed the complete 34-slide lab deck for **Experiment 3: Deploying NGINX Using Different Base Images and Comparing Image Layers**.

### Deliverables Generated in Desktop\lab 3:
1. **`lab_manual_experiment_03.md`**: Complete 34-slide lab report including all 7 parts, Dockerfiles for Ubuntu and Alpine, image layer history comparison, volume mounts, student assignment answers, and the NGINX Web Server Deep Dive optional read.
2. **`index.html`**: Interactive web application featuring screenshot figure galleries, size comparison table, and Dockerfile syntax highlighting.
3. **High-Resolution Terminal Screenshots**:
   - `step1_official_nginx.jpg`: Official `nginx:latest` image deployment on port 8080.
   - `step2_ubuntu_nginx.jpg`: `Dockerfile` (`FROM ubuntu:22.04`) build & execution.
   - `step3_alpine_nginx.jpg`: `Dockerfile` (`FROM alpine:latest`) build & execution.
   - `step4_layer_comparison.jpg`: `docker images` size comparison (~28MB vs ~142MB vs ~228MB) & `docker history`.
   - `step5_volume_mount.jpg`: Volume mount static web serving (`-v $(pwd)/html:/usr/share/nginx/html`).