require("dotenv").config();
const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const { sequelize } = require("./models");
const authRoutes = require("./routes/authRoutes");
const patientRoutes = require("./routes/patientRoutes");
const alertRoutes = require("./routes/alertRoutes");
const sensorDataRoutes = require("./routes/sensorDataRoutes");
const medicationRoutes = require("./routes/medicationRoutes");

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.use("/api/auth", authRoutes);
app.use("/api/patients", patientRoutes);
app.use("/api/alerts", alertRoutes);
app.use("/api/sensorData", sensorDataRoutes);
app.use("/api/medications", medicationRoutes);

app.get("/", (req, res) => {
  res.send("Hello World!");
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

sequelize
  .sync()
  .then(() => console.log("Database synchronized"))
  .catch((err) => console.error("Error synchronizing the database:", err));
