from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
import uvicorn
import os
from prometheus_client import Counter, Histogram, generate_latest
from fastapi.responses import Response

app = FastAPI(title="Payment Service", version="1.0.0")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Prometheus metrics
payments_counter = Counter('payments_total', 'Total payments processed', ['status'])
payment_amount = Histogram('payment_amount_dollars', 'Payment amount in dollars')

# In-memory storage (replace with database in production)
payments_db = {}
payment_id_counter = 1

# Models
class PaymentRequest(BaseModel):
    order_id: int
    amount: float
    payment_method: str
    card_number: Optional[str] = None
    card_holder: Optional[str] = None
    cvv: Optional[str] = None

class PaymentResponse(BaseModel):
    id: int
    order_id: int
    amount: float
    status: str
    transaction_id: str
    created_at: datetime

# Health check
@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "service": "payment-service",
        "timestamp": datetime.now()
    }

# Metrics endpoint
@app.get("/metrics")
async def metrics():
    return Response(content=generate_latest(), media_type="text/plain")

# Process payment
@app.post("/api/payments", response_model=PaymentResponse)
async def create_payment(payment: PaymentRequest):
    global payment_id_counter
    
    # Simulate payment processing
    if payment.amount <= 0:
        payments_counter.labels(status='failed').inc()
        raise HTTPException(status_code=400, detail="Invalid payment amount")
    
    # Simulate payment gateway integration
    # In production, integrate with Stripe, PayPal, etc.
    transaction_id = f"TXN-{payment_id_counter}-{int(datetime.now().timestamp())}"
    
    payment_record = {
        "id": payment_id_counter,
        "order_id": payment.order_id,
        "amount": payment.amount,
        "payment_method": payment.payment_method,
        "status": "completed",
        "transaction_id": transaction_id,
        "created_at": datetime.now()
    }
    
    payments_db[payment_id_counter] = payment_record
    payment_id_counter += 1
    
    payments_counter.labels(status='completed').inc()
    payment_amount.observe(payment.amount)
    
    return payment_record

# Get payment by ID
@app.get("/api/payments/{payment_id}", response_model=PaymentResponse)
async def get_payment(payment_id: int):
    if payment_id not in payments_db:
        raise HTTPException(status_code=404, detail="Payment not found")
    
    return payments_db[payment_id]

# Get payments by order ID
@app.get("/api/payments/order/{order_id}")
async def get_payments_by_order(order_id: int):
    order_payments = [p for p in payments_db.values() if p["order_id"] == order_id]
    return order_payments

# Refund payment
@app.post("/api/payments/{payment_id}/refund")
async def refund_payment(payment_id: int):
    if payment_id not in payments_db:
        raise HTTPException(status_code=404, detail="Payment not found")
    
    payment = payments_db[payment_id]
    
    if payment["status"] == "refunded":
        raise HTTPException(status_code=400, detail="Payment already refunded")
    
    payment["status"] = "refunded"
    payment["refunded_at"] = datetime.now()
    
    payments_counter.labels(status='refunded').inc()
    
    return payment

if __name__ == "__main__":
    port = int(os.getenv("PORT", 3004))
    uvicorn.run(app, host="0.0.0.0", port=port)
