# Technical Assignement

## DevOps Engineer - Team BeeBox

Please use any software that you are familiar with to execute and demonstrate the project. During
the technical interview with our engineers, we’ll discuss your project solution.

## Objective

Design, automate, and demonstrate a small production-like system using **Infrastructure as Code
(IaC)** , **Configuration Management** , and **CI/CD automation.**

The system must include:

- **1 Load Balancer**
- **2 Web Servers**
- **1 SQL Database**

## Project Requirements

### Infrastructure

Using any virtualization or containerization solution, provision the following components:

### Component Description

```
Load Balancer Routes HTTP requests to backend web servers sequentially or in round-robin
mode.
Web Servers
(x2)
```
```
Run a basic web or API application.
```
```
SQL Database Stores simple data that can be queried via a REST API.
```
**URL Requirement:**

The Load Balancer must respond to requests at [http://ucpe.swisscom.com:[any_port]](http://ucpe.swisscom.com:[any_port])
and distribute traffic across the web servers.

**Note:**
You can use **/etc/hosts** on your local system to resolve ucpe.swisscom.com.

### Automation and Configuration

- **Provisioning Automation:**
    Use a tool such as Terraform, Docker Compose or any other tools to create infrastructure.
- **Configuration Management:**
    Automate setup (installation, config, dependencies) for all servers using **Ansible** or
    a **GitOps** approach.


- **Security / Updates:**
    Check servers for software vulnerabilities or outdated packages and apply mitigations
    (system updates, lynis audit).

### Functionality and CI/CD

### REST API

Implement a simple RESTful **read-only endpoint** that fetches data from the SQL database.
**RESTful API**

GET /api/data → returns data **from** the database **in** JSON format

You can use any language or framework.

CI/CD Pipeline

Set up a **GitLab CI** or **GitHub Actions** pipeline that includes:

1. Lint/validation stage
2. Build/create infrastructure
3. Configure servers automatically
4. Test stage, call REST API or LB endpoint to confirm success

## Architecture Diagram

Below is the expected architecture. You may reproduce or adapt it to your implementation.


## Deliverables

Please provide a **public or shareable Git repository** containing:

1. IaC / Provisioning Code
2. Configuration Management Scripts
3. REST API Source Code
4. CI/CD Pipeline Definition
5. README file describing:
    - Setup steps
    - Architecture overview
    - Example REST API query
    - Security / patching evidence

## Estimated Effort

Expected completion time: **1 – 2 days.**

A prototype is sufficient for us to evaluate your technical skills.
The technology stack and programmatic language to implement this solution is open to you.


