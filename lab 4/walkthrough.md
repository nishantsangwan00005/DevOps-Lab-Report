# Experiment 4 Completion Walkthrough

## Summary of Accomplishments
Completed the complete 12-slide lab deck for **Experiment 4: Docker Essentials**.

### Deliverables Generated in Desktop\lab 4:
1. **`lab_manual_experiment_04.md`**: Complete 12-slide lab report including Python Flask app, Node.js Express app, `Dockerfile.multistage`, `.dockerignore`, tagging, publishing to Docker Hub, practice exercises, Essential Docker Commands cheatsheet table, development/production workflows, and `docker system prune -a` cleanup.
2. **`index.html`**: Interactive web application featuring screenshot figure galleries, Dockerfile syntax code blocks, and essential commands cheatsheet table.
3. **High-Resolution Terminal Screenshots**:
   - `step1_flask_dockerfile.jpg`: Python Flask app containerization & `docker build`.
   - `step2_dockerignore_build.jpg`: `.dockerignore` file configuration & history.
   - `step3_running_flask.jpg`: Running Flask container (`-p 5000:5000`), testing endpoints, and `docker logs`.
   - `step4_multistage_build.jpg`: Multi-stage build (`Dockerfile.multistage`) reducing final image size by 40% (148MB vs 248MB).
   - `step5_publishing_dockerhub.jpg`: `docker login`, `docker tag`, and `docker push username/my-flask-app:1.0`.
   - `step6_node_docker.jpg`: Node.js Express app setup (`app.js`), `node:18-alpine` Dockerfile build, and `curl http://localhost:3000`.