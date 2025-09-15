import qrcode
import json

# Example student data
student_data = {
    "student_id": "2025_001",
    "name": "Ravi Kumar",
    "class_id": "8A",
    "roll_number": "15"
}

# Convert dict to JSON string for QR code
qr_payload = json.dumps(student_data)

# Generate QR code
qr = qrcode.QRCode(
    version=1,  # controls size, 1 = 21x21
    error_correction=qrcode.constants.ERROR_CORRECT_H,  # high error correction
    box_size=10,
    border=4
)
qr.add_data(qr_payload)
qr.make(fit=True)

# Save as image
img = qr.make_image(fill_color="black", back_color="white")
img.save("student_qr.png")

print("✅ QR code saved as student_qr.png")
