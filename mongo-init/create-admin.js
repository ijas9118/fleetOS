db = db.getSiblingDB("fleetOS-auth");

if (db.users.countDocuments() === 0) {
  db.users.insertOne({
    email: "admin@fleetos.com",
    password:
      "$argon2id$v=19$m=16,t=2,p=1$N1BvQjVKejJMNGxCSWtXTw$ud5KDL2sRoeRJRu3R2A5iw",
    name: "Admin",
    role: "PLATFORM_ADMIN",
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  print("✅ Admin user created!");
} else {
  print("Users already exist — skipping admin creation");
}
