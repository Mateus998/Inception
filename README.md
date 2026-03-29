*This project has been created as part of the 42 curriculum by mateferr.*

## Description
**Inception** is a System Administration project aimed at broadening knowledge of infrastructure virtualization using **Docker**. The goal is to set up a small, secure infrastructure composed of different services, each running in its own dedicated container, orchestrated by **Docker Compose**.

In this project, I built several Docker images from scratch using custom **Dockerfiles** based on Debian or Alpine. The infrastructure includes:
*   **NGINX:** The only entry point for the infrastructure, configured with **TLSv1.2 or TLSv1.3** on port 443.
*   **WordPress + php-fpm:** A content management system where PHP scripts are executed efficiently using the FastCGI protocol.
*   **MariaDB:** A relational database management system that stores the WordPress data.

The project ensures data persistence through **Docker named volumes** and secures communication between containers using a custom **Docker network**.

### Design Choices & Comparisons
As required by the project, the following design choices were implemented:

*   **Virtual Machines vs Docker:** While Virtual Machines (VMs) run a full operating system and are heavier/slower, Docker containers share the host's kernel, making them lightweight, faster, and more efficient.
*   **Secrets vs Environment Variables:** Environment variables (stored in a `.env` file) are used for general configuration, but **Docker secrets** are used for confidential information like passwords to ensure they are not exposed in the images or the repository.
*   **Docker Network vs Host Network:** A custom Docker network provides isolation and controlled communication between services, whereas a host network removes this security layer by using the host's network stack directly.
*   **Docker Volumes vs Bind Mounts:** This project uses **named volumes** (stored in `/home/mateferr/data`) because they are managed by Docker for better portability and abstraction, unlike bind mounts which map directly to specific host directories.

## Instructions
### Requirements
*   A Linux environment (Debian recommended).
*   Docker and Docker Compose.
*   Make.

### Installation & Execution
1.  Configure your domain name (`mateferr.42.fr`) to point to your local IP.
2.  Set up your environment variables in a `.env` file and your confidential data in a `secrets/` directory.
3.  Use the provided **Makefile** at the root of the project to build and launch the infrastructure:
    *   `make`: Builds the Docker images and starts the containers.
    *   `make stop`: Stops the running containers.
    *   `make clean`: Removes containers, networks, and images.

### Access
*   **Website:** `https://mateferr.42.fr`
*   **Administration Panel:** `https://mateferr.42.fr/wp-admin`

## Resources
*   [Docker Documentation](https://docs.docker.com/)
*   [Docker Compose Guide](https://docs.docker.com/compose/)
*   [NGINX Documentation](https://nginx.org/en/docs/)
*   [MariaDB Documentation](https://mariadb.org/documentation/)
*   [WordPress Documentation](https://wordpress.org/documentation/)

### Technical Choice: Alpine Linux
This project uses **Alpine Linux** as the **base image** for **Docker containers**. Alpine is a **lightweight Linux distribution** designed with **simplicity**, **security**, and **efficiency** in mind.
By using Alpine, the **container images** remain **small**, which improves **build speed** and reduces **resource usage**. Its **minimal design** also decreases the **attack surface**, making the environment more **secure** by default.
This choice aligns well with the goals of the project, ensuring **fast**, **efficient**, and **reliable containerized services**.

### AI Usage
*   **AI tools** were used to **clarify** complex Docker concepts, assist in **debugging** configuration issues within the Dockerfiles, and help **structure the project's documentation**
*   All **AI-generated** suggestions were **verified** and **tested manually** to ensure full **understanding** and **compliance** with project requirements
