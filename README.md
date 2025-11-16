# FleetOS Microservices

[![license: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![lang: TypeScript](https://img.shields.io/badge/lang-TypeScript-blueviolet)](https://www.typescriptlang.org/)

This repository contains the microservices for the FleetOS application, a cloud-native logistics management platform using the MERN stack . Each service is containerized and can be run, tested, and deployed independently. The services are managed as Git submodules, each with its own repository.

## Services

| Service Name      | Port | Description                                                               | Git Submodule                      |
| ----------------- | ---- | ------------------------------------------------------------------------- | ---------------------------------- |
| API Gateway       | 3000 | Entry point for all client requests; routes traffic to internal services. | [Link 🔗](./services/api-gateway/) |
| Auth Service      | 3001 | Handles authentication, OTP verification, and token management.           | [Link 🔗](./services/auth-service/)                        |
| User Service      | 3002 | Manages user profiles, roles, and account metadata.                       | [Link 🔗](./services/)                        |
| Shipment Service  | 3003 | Handles shipment creation, tracking, routing, and delivery workflows.     | [Link 🔗](./services/shipment-service/)                        |
| Fleet Service     | 3004 | Manages vehicles, drivers, telematics, and fleet operations.              | [Link 🔗](./services/fleet-service/)                        |
| Inventory Service | 3005 | Manages warehouse inventory, stock items, SKUs, and asset movements.      | [Link 🔗](./services/inventory-service/)                        |
