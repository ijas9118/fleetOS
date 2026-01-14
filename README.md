<div align="center">
  <h1>🚛 FleetOS</h1>
  <p>
    <strong>Cloud-Native Logistics & Fleet Management Platform</strong>
  </p>

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=flat&logo=nodedotjs&logoColor=white)
![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=flat&logo=typescript&logoColor=white)
![Express.js](https://img.shields.io/badge/express.js-%23404d59.svg?style=flat&logo=express&logoColor=white)
![React](https://img.shields.io/badge/React-19.2-61DAFB?style=flat&logo=react&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-%234ea94b.svg?style=flat&logo=mongodb&logoColor=white)
![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=flat&logo=kubernetes&logoColor=white)

  <p>
    <a href="#-overview">Overview</a> •
    <a href="#-submodules">Submodules</a> •
    <a href="#-getting-started">Getting Started</a> •
    <a href="#%EF%B8%8F-development-with-skaffold">Skaffold</a> •
    <a href="#%EF%B8%8F-kubernetes-development-guide">Kubernetes</a>
  </p>
</div>

---

FleetOS is a comprehensive, cloud-native logistics management platform built with modern microservices architecture. It provides end-to-end fleet operations management, from vehicle tracking and driver management to shipment orchestration and inventory control.

## 📖 Overview

This monorepo contains all microservices for the FleetOS application, built using the **MERN stack** (MongoDB, Express, React, Node.js) with **TypeScript**. Each service is containerized, independently deployable, and managed as a Git submodule. The platform leverages **Kubernetes** for orchestration and **Skaffold** for streamlined local development.

### 🏗️ Architecture

FleetOS follows **Clean Architecture** and **Domain-Driven Design** principles:
- **Microservices**: Independent, scalable services with clear boundaries
- **Event-Driven**: Asynchronous communication via Apache Kafka
- **Multi-Tenant**: Complete data isolation between organizations
- **API Gateway**: Centralized routing and authentication
- **Service Mesh**: Kong for API management

---

## 📦 Submodules

### Backend Services

| Service | Port | Description | Tech Stack | Repository |
|---------|------|-------------|------------|------------|
| **Auth Service** | 3001 | Central authentication and authorization service handling multi-tenant user management, JWT-based auth with refresh tokens, role-based access control (RBAC), OTP verification, and user invitation workflows. | Express, MongoDB, Redis, Argon2, InversifyJS | [🔗 GitHub](https://github.com/ijas9118/fleet-os-auth-service) |
| **Fleet Service** | 3004 | Vehicle and driver management service providing complete CRUD operations for fleet vehicles, driver profiles and onboarding, maintenance scheduling (preventive & reactive), and vehicle-driver assignment tracking. | Express, MongoDB, Redis, Clean Architecture | [🔗 GitHub](https://github.com/ijas9118/fleet-os-fleet-service) |
| **Inventory Service** | 3005 | Warehouse and stock management service managing multi-warehouse inventory, real-time stock levels, automated stock reservations for shipments, stock transactions (IN/OUT/ADJUSTMENT/TRANSFER), and inter-warehouse transfers. | Express, MongoDB, Redis, DDD | [🔗 GitHub](https://github.com/ijas9118/fleet-os-inventory-service) |
| **Shipment Service** | 3003 | Order fulfillment and delivery orchestration service handling end-to-end shipment lifecycle, automated inventory integration, driver assignments, real-time tracking with status updates, and multi-item shipment support. | Express, MongoDB, Axios | [🔗 GitHub](https://github.com/ijas9118/fleet-os-shipment-service) |
| **Notification Service** | 3006 | Event-driven notification service consuming Kafka events for transactional emails (OTP verification, user invitations, password reset), HTML email templates with Nodemailer, and asynchronous processing with retry mechanisms. | Express, Kafka, Nodemailer, Winston | [🔗 GitHub](https://github.com/ijas9118/fleet-os-notification-service) |

### Frontend & Shared

| Module | Description | Tech Stack | Repository |
|--------|-------------|------------|------------|
| **Client (Frontend)** | Modern, responsive web application providing role-based dashboards for Platform Admins, Tenant Admins, Operations Managers, and Drivers. Features include inventory management, fleet operations, shipment tracking, and real-time updates. | React 19, TypeScript, Vite, TailwindCSS, shadcn/ui, Redux Toolkit, TanStack Table | [🔗 GitHub](https://github.com/ijas9118/fleet-os-frontend) |
| **Shared** | Centralized package for shared utilities, constants, enums, validators, and TypeScript types used across all microservices to ensure consistency and reduce code duplication. | TypeScript, Zod | [🔗 GitHub](https://github.com/ijas9118/fleet-os-shared) |

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** >= 20.x
- **pnpm** >= 9.x
- **Docker Desktop** (with Kubernetes enabled)
- **kubectl** - Kubernetes command-line tool
- **Skaffold** >= 2.x - For local development

### Installation

1. **Clone the repository with submodules**

```bash
git clone --recurse-submodules https://github.com/ijas9118/fleetOS.git
cd fleetOS
```

If you already cloned without submodules:

```bash
git submodule update --init --recursive
```

2. **Install dependencies for each service**

```bash
# Install dependencies for all services
cd services/auth-service && pnpm install && cd ../..
cd services/fleet-service && pnpm install && cd ../..
cd services/inventory-service && pnpm install && cd ../..
cd services/shipment-service && pnpm install && cd ../..
cd services/notification-service && pnpm install && cd ../..
cd client && pnpm install && cd ..
```

---

## 🛠️ Development with Skaffold

**Skaffold** provides a streamlined development workflow with automatic rebuilding, redeploying, and log streaming.

### Why Skaffold?

- **Fast Inner Loop**: Automatic file sync for TypeScript changes without full rebuilds
- **Live Reload**: Changes reflect immediately in running containers
- **Integrated Logging**: Stream logs from all services in one terminal
- **Simplified Workflow**: Single command to start entire stack

### Running with Skaffold

1. **Ensure Docker Desktop Kubernetes is enabled**

Go to Docker Desktop → Settings → Kubernetes → Enable Kubernetes

2. **Start development environment**

```bash
skaffold dev
```

This command will:
- Build Docker images for all services
- Deploy to your local Kubernetes cluster
- Set up file syncing for `src/**/*.ts` files
- Stream logs from all pods
- Automatically rebuild on file changes

3. **File Sync Configuration**

Skaffold is configured to sync TypeScript files without rebuilding:

```yaml
sync:
  manual:
  - src: 'src/**/*.ts'
    dest: /app
```

Changes to `.ts` files are synced instantly. For dependency changes (package.json), restart `skaffold dev`.

### Skaffold Commands

```bash
# Development mode with file sync and log streaming
skaffold dev

# Build and deploy without watching
skaffold run

# Build images only
skaffold build

# Deploy existing images
skaffold deploy

# Clean up all deployed resources
skaffold delete
```

### Troubleshooting Skaffold

**Issue: "context deadline exceeded"**
- Increase Docker Desktop resources (Memory >= 8GB)
- Check that all images can be pulled

**Issue: File sync not working**
- Verify the file path matches the sync pattern in `skaffold.yaml`
- Restart `skaffold dev`

**Issue: Services not starting**
- Check pod logs: `kubectl logs -f <pod-name> -n fleet-os`
- Verify environment variables in config maps and secrets

---

## ☸️ Kubernetes Development Guide

### Cluster Architecture

FleetOS uses a **namespace-based** Kubernetes deployment:

```
fleet-os (namespace)
├── Infrastructure
│   ├── MongoDB (StatefulSet)
│   ├── Redis (Deployment)
│   └── Kafka (StatefulSet)
├── Core Services
│   ├── Auth Service
│   ├── Fleet Service
│   ├── Inventory Service
│   ├── Shipment Service
│   └── Notification Service
└── Gateway
    └── Kong API Gateway
```

### Directory Structure

```
k8s/
├── namespaces.yaml              # Namespace definition
├── infrastructure/              # Backing services
│   ├── mongo.yaml               # MongoDB StatefulSet
│   ├── redis.yaml               # Redis Deployment
│   ├── kafka.yaml               # Kafka broker
│   └── mongo-init-config.yaml   # MongoDB init scripts
├── core-services/               # Microservices
│   ├── auth.yaml                # Auth service deployment
│   ├── auth-config.yaml         # ConfigMap for auth
│   ├── auth-secret.yaml         # Secrets for auth
│   ├── fleet.yaml
│   ├── inventory.yaml
│   ├── shipment.yaml
│   └── notification.yaml
└── gateway/                     # API Gateway
    └── kong.yaml
```

### Manual Deployment

If not using Skaffold, deploy manually with kubectl:

```bash
# 1. Create namespace
kubectl apply -f k8s/namespaces.yaml

# 2. Deploy infrastructure
kubectl apply -f k8s/infrastructure/

# 3. Deploy core services
kubectl apply -f k8s/core-services/

# 4. Deploy gateway
kubectl apply -f k8s/gateway/
```

### Common kubectl Commands

**View all resources:**
```bash
kubectl get all -n fleet-os
```

**Check pod status:**
```bash
kubectl get pods -n fleet-os
```

**View service logs:**
```bash
kubectl logs -f <pod-name> -n fleet-os

# Example
kubectl logs -f auth-service-7d9f8b6c4-xhjk2 -n fleet-os
```

**Describe a pod (for debugging):**
```bash
kubectl describe pod <pod-name> -n fleet-os
```

**Execute commands in a pod:**
```bash
kubectl exec -it <pod-name> -n fleet-os -- /bin/sh
```

**Port forward to access services:**
```bash
# Forward local port to service
kubectl port-forward svc/auth-service 3001:3001 -n fleet-os
kubectl port-forward svc/mongo 27017:27017 -n fleet-os
```

**View ConfigMaps and Secrets:**
```bash
kubectl get configmaps -n fleet-os
kubectl get secrets -n fleet-os

# View contents
kubectl describe configmap auth-config -n fleet-os
```

**Restart a deployment:**
```bash
kubectl rollout restart deployment/auth-service -n fleet-os
```

**Delete all resources:**
```bash
kubectl delete namespace fleet-os
```

### Accessing Services Locally

Services are exposed via **ClusterIP** by default. Use port forwarding to access:

```bash
# Auth Service
kubectl port-forward svc/auth-service 3001:3001 -n fleet-os

# Fleet Service
kubectl port-forward svc/fleet-service 3004:3004 -n fleet-os

# Inventory Service
kubectl port-forward svc/inventory-service 3005:3005 -n fleet-os

# Shipment Service
kubectl port-forward svc/shipment-service 3003:3003 -n fleet-os

# MongoDB (for database access)
kubectl port-forward svc/mongo 27017:27017 -n fleet-os

# Redis
kubectl port-forward svc/redis 6379:6379 -n fleet-os
```

### Viewing Logs

**Stream logs from all pods:**
```bash
skaffold dev  # Automatically streams all logs
```

**View specific service logs:**
```bash
kubectl logs -f deployment/auth-service -n fleet-os
```

**View logs from all replicas:**
```bash
kubectl logs -l app=auth-service -n fleet-os --all-containers=true -f
```

---

## 🧪 Testing

Each service has its own test suite. Run tests individually:

```bash
cd services/auth-service
pnpm test
```

Or run all tests:

```bash
# Run tests for all services
for dir in services/*/; do
  (cd "$dir" && pnpm test)
done
```

---

## 🛡️ Security

- **JWT Authentication**: RS256 asymmetric encryption
- **Secrets Management**: Kubernetes Secrets for sensitive data
- **RBAC**: Role-based access control across all services
- **Multi-Tenancy**: Complete data isolation per organization
- **API Gateway**: Centralized security with Kong

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <p>Built with ❤️ for modern logistics management</p>
  <p>
    <a href="https://github.com/ijas9118/fleetOS">GitHub</a> •
    <a href="https://github.com/ijas9118/fleetOS/issues">Issues</a>
  </p>
</div>
