#!/bin/bash

# FleetOS MongoDB Data Import Script for EKS
# This script loads dummy data into MongoDB running in the EKS cluster

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}FleetOS MongoDB Data Import${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""

# Get MongoDB pod name
MONGO_POD=$(kubectl get pods -n infrastructure -l app=mongo-db -o jsonpath='{.items[0].metadata.name}')

echo -e "${YELLOW}MongoDB Pod:${NC} $MONGO_POD"
echo ""

# Copy the seed script to MongoDB pod
echo -e "${BLUE}Copying seed data script to MongoDB pod...${NC}"
kubectl cp k8s/infrastructure/mongo-init-config.yaml infrastructure/$MONGO_POD:/tmp/seed-config.yaml

# Extract the JavaScript from the ConfigMap and execute it
echo -e "${BLUE}Extracting and executing seed script...${NC}"

# Create a temporary JavaScript file
cat > /tmp/seed-data.js << 'EOF'
db = db.getSiblingDB("auth-db");

// Define IDs at top level scope
const defaultTenantId = "b9c231b4-3677-4aac-8cfc-cf245d927230";
const tenantAdminId = new ObjectId();
const driverId = new ObjectId();

if (db.users.countDocuments() === 0) {
  // Create platform admin
  db.users.insertOne({
    email: "admin@fleetos.com",
    password: "$argon2id$v=19$m=16,t=2,p=1$N1BvQjVKejJMNGxCSWtXTw$ud5KDL2sRoeRJRu3R2A5iw", // "password"
    name: "Admin",
    role: "PLATFORM_ADMIN",
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  print("✅ Platform admin user created!");

  // Create default tenant
  db.tenants.insertOne({
    tenantId: defaultTenantId,
    name: "ShopifyHub",
    industry: "E-commerce",
    contactEmail: "support@shopifyhub.com",
    contactPhone: "+1 555-123-9876",
    address: {
      line1: "221B Market Street",
      city: "San Francisco",
      state: "CA",
      postalCode: "94105",
      country: "USA"
    },
    status: "ACTIVE",
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  print("✅ Default tenant (ShopifyHub) created!");

  // Create tenant admin
  db.users.insertOne({
    _id: tenantAdminId,
    email: "john.doe@example.com",
    password: "$argon2id$v=19$m=65536,t=3,p=4$FMi7Zz2yXb1AY9uTitJjwQ$7ZAY2UlyH94tXpm8MrOh5sTKCjsv5LuIq3ScI6jEpw4",
    name: "John Doe",
    role: "TENANT_ADMIN",
    tenantId: defaultTenantId,
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  print("✅ Tenant admin user created!");

  // Create operations manager
  db.users.insertOne({
    email: 'opsmanager@fleetos.com',
    password: '$argon2id$v=19$m=65536,t=3,p=4$dFIL57PdfLVH5EbcmFBQQg$68BDN60VLsTP3PfClqbnHJvLMaFOXWkzEYJMIS9HVMg',
    name: 'Alice Ops',
    role: 'OPERATIONS_MANAGER',
    tenantId: 'b9c231b4-3677-4aac-8cfc-cf245d927230',
    invitedBy: tenantAdminId,
    invitedAt: new Date('2026-01-11T07:31:09.230Z'),
    invitationAcceptedAt: new Date('2026-01-11T07:32:53.533Z'),
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  print("✅ Operations manager user created!");

  // Create driver
  db.users.insertOne({
    _id: driverId,
    email: 'driver@fleetos.com',
    password: '$argon2id$v=19$m=65536,t=3,p=4$dFIL57PdfLVH5EbcmFBQQg$68BDN60VLsTP3PfClqbnHJvLMaFOXWkzEYJMIS9HVMg',
    name: 'Bob Driver',
    role: 'DRIVER',
    tenantId: 'b9c231b4-3677-4aac-8cfc-cf245d927230',
    invitedBy: tenantAdminId,
    invitedAt: new Date('2026-01-11T07:31:09.230Z'),
    invitationAcceptedAt: new Date('2026-01-11T07:32:53.533Z'),
    isActive: true,
    isOnboardingComplete: true,
    onboardingCompletedAt: new Date(),
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  print("✅ Driver user created!");
} else {
  print("Users already exist — skipping initialization");
}

// Initialize inventory-db
db = db.getSiblingDB("inventory-db");

if (db.warehouses.countDocuments() === 0) {
  const mumbaiWarehouseId = new ObjectId();
  const kochiWarehouseId = new ObjectId();

  // Mumbai Warehouse
  db.warehouses.insertOne({
    _id: mumbaiWarehouseId,
    tenantId: "b9c231b4-3677-4aac-8cfc-cf245d927230",
    name: "Main Warehouse",
    code: "WH001",
    address: {
      line1: "123 Logistics Ave",
      city: "Mumbai",
      state: "Maharashtra",
      postalCode: "400001",
      country: "India",
      coordinates: { type: "Point", coordinates: [ 72.8777, 19.076 ] }
    },
    status: "ACTIVE",
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  // Kochi Warehouse
  db.warehouses.insertOne({
    _id: kochiWarehouseId,
    tenantId: "b9c231b4-3677-4aac-8cfc-cf245d927230",
    name: "Kochi Distribution Center",
    code: "WH002",
    address: {
      line1: "45 Port Road",
      city: "Kochi",
      state: "Kerala",
      postalCode: "682001",
      country: "India",
      coordinates: { type: "Point", coordinates: [ 76.2711, 9.9312 ] }
    },
    status: "ACTIVE",
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  print("✅ Warehouses created (Mumbai & Kochi)!");

  // Create Inventory Items
  const earbudsId = new ObjectId();
  const phoneCaseId = new ObjectId();

  db.inventoryitems.insertOne({
    _id: earbudsId,
    tenantId: "b9c231b4-3677-4aac-8cfc-cf245d927230",
    sku: "WRL-EAR-001",
    name: "Premium Wireless Earbuds",
    description: "High-quality wireless earbuds with active noise cancellation",
    category: "Electronics",
    unit: "PCS",
    minStockLevel: 50,
    maxStockLevel: 500,
    reorderPoint: 100,
    status: "ACTIVE",
    deletedAt: null,
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  db.inventoryitems.insertOne({
    _id: phoneCaseId,
    tenantId: "b9c231b4-3677-4aac-8cfc-cf245d927230",
    sku: "ACC-CASE-002",
    name: "Protective Smartphone Case",
    description: "Durable silicone case with shock absorption for smartphones",
    category: "Accessories",
    unit: "PCS",
    minStockLevel: 100,
    maxStockLevel: 1000,
    reorderPoint: 200,
    status: "ACTIVE",
    deletedAt: null,
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  print("✅ Inventory items created!");

  // Create Stock records
  db.stocks.insertOne({
    tenantId: "b9c231b4-3677-4aac-8cfc-cf245d927230",
    warehouseId: mumbaiWarehouseId.toString(),
    inventoryItemId: earbudsId.toString(),
    quantity: 150,
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  db.stocks.insertOne({
    tenantId: "b9c231b4-3677-4aac-8cfc-cf245d927230",
    warehouseId: kochiWarehouseId.toString(),
    inventoryItemId: earbudsId.toString(),
    quantity: 75,
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  db.stocks.insertOne({
    tenantId: "b9c231b4-3677-4aac-8cfc-cf245d927230",
    warehouseId: mumbaiWarehouseId.toString(),
    inventoryItemId: phoneCaseId.toString(),
    quantity: 200,
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  db.stocks.insertOne({
    tenantId: "b9c231b4-3677-4aac-8cfc-cf245d927230",
    warehouseId: kochiWarehouseId.toString(),
    inventoryItemId: phoneCaseId.toString(),
    quantity: 300,
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  print("✅ Stock records created for both warehouses!");
} else {
  print("Warehouses already exist — skipping initialization");
}

// Initialize fleet-db
db = db.getSiblingDB("fleet-db");

if (db.drivers.countDocuments() === 0) {
  db.drivers.insertOne({
    userId: driverId.toString(),
    tenantId: "b9c231b4-3677-4aac-8cfc-cf245d927230",
    licenseNumber: "DL-CA-2025-987654",
    licenseExpiryDate: new Date("2030-12-31"),
    phoneNumber: "+1 555-0199-9999",
    address: {
      street: "123 Driver Lane",
      city: "San Francisco",
      state: "CA",
      postalCode: "94107",
      country: "USA"
    },
    emergencyContact: {
      name: "Alice Driver",
      relationship: "Spouse",
      phoneNumber: "+1 555-0200-0000"
    },
    status: "active",
    onboardedAt: new Date(),
    createdAt: new Date(),
    updatedAt: new Date()
  });

  print("✅ Driver profile created!");

  db.vehicles.insertOne({
    tenantId: "b9c231b4-3677-4aac-8cfc-cf245d927230",
    registrationNumber: "KL-07-CC-5555",
    make: "Toyota",
    vehicleModel: "Prius",
    year: 2023,
    vin: "1HGCM82633A004352",
    type: "sedan",
    fuelType: "hybrid",
    status: "available",
    mileage: 15000,
    insuranceExpiryDate: new Date("2026-02-01"),
    registrationExpiryDate: new Date("2026-02-01"),
    assignedDriverId: null,
    notes: "Primary fleet vehicle",
    createdAt: new Date(),
    updatedAt: new Date()
  });

  print("✅ Vehicle created!");
} else {
  print("Fleet data already exists — skipping initialization");
}

print("\n🎉 Database seeding complete!");
EOF

# Copy seed script to MongoDB pod
echo -e "${BLUE}Copying seed script to pod...${NC}"
kubectl cp /tmp/seed-data.js infrastructure/$MONGO_POD:/tmp/seed-data.js

# Execute the seed script
echo -e "${BLUE}Executing seed script in MongoDB...${NC}"
kubectl exec -n infrastructure $MONGO_POD -- mongosh -u admin -p fleetOS2024SecurePass! --authenticationDatabase admin --file /tmp/seed-data.js

echo ""
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}Import Complete!${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo -e "${YELLOW}Test Data Created:${NC}"
echo ""
echo -e "${BLUE}Users (auth-db):${NC}"
echo "  - Platform Admin: admin@fleetos.com (password: password)"
echo "  - Tenant Admin: john.doe@example.com (password: password123)"
echo "  - Operations Manager: opsmanager@fleetos.com (password: password123)"
echo "  - Driver: driver@fleetos.com (password: password123)"
echo ""
echo -e "${BLUE}Tenant:${NC}"
echo "  - ShopifyHub (E-commerce company)"
echo ""
echo -e "${BLUE}Inventory (inventory-db):${NC}"
echo "  - 2 Warehouses: Mumbai (WH001), Kochi (WH002)"
echo "  - 2 Products: Wireless Earbuds, Phone Cases"
echo "  - Stock distributed across both warehouses"
echo ""
echo -e "${BLUE}Fleet (fleet-db):${NC}"
echo "  - 1 Driver profile"
echo "  - 1 Vehicle (Toyota Prius)"
echo ""

# Cleanup
rm -f /tmp/seed-data.js

echo -e "${GREEN}✓ You can now login with any of the test users!${NC}"
echo ""
