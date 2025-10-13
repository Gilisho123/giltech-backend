import { createRequest, getAllRequests } from "../models/requestModel.js";

export const addRequest = async (req, res) => {
  try {
    const { name, phone, service } = req.body;
    const fileName = req.file ? req.file.filename : null;
    const newRequest = await createRequest(name, phone, service, fileName);
    res.json({ success: true, data: newRequest });
    console.log("Received new request:");
console.log("Name:", name);
console.log("Phone:", phone);
console.log("Service:", service);
console.log("File:", fileName);

  } catch (err) {
    console.error("❌ Error adding request:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const listRequests = async (req, res) => {
  try {
    const requests = await getAllRequests();
    // Return the raw array to match the admin UI expectation (admin client expects an array)
    res.json(requests);
  } catch (err) {
    console.error("❌ Error fetching requests:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

