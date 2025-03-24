# 🏎 Tire Request Portal

## Demo Video (March 24, 2025)
[![86 Challenge Tire Request Portal Demo](https://img.youtube.com/vi/WrBqmoCdKxM/0.jpg)](https://youtu.be/WrBqmoCdKxM)

# Product Requirements Document (PRD)

## Overview

The Tire Request Portal allows **86 Challenge participants** to request tires via points or payments, and enables **representatives** to process these requests. **Admins** manage users, assign points, and oversee all requests.

---

## Users

### 1. Participants
- 86 Challenge members
- Can:
  - Submit tire requests
  - View their request history and point status
  - Withdraw `SUBMITTED` requests
  - Mark requests as `PAID` and `RECEIVED`
  - Communicate via request replies

### 2. Representatives
- Work for the tire supplier
- Can:
  - View unassigned requests
  - Assign themselves to a request (exclusive edit rights)
  - Update request statuses (e.g., `AWAITING PAYMENT`, `SHIPPED`, `BACKORDERED`, etc.)
  - Communicate via request replies

### 3. Admins
- Select participants with elevated privileges
- Can:
  - Approve/reject user signup requests
  - Bulk-add points to participant accounts
  - View and filter all requests
  - Switch between user dashboard and admin dashboard
  - Edit all request details (if needed)

---

## Authentication & Onboarding

- **Google Sign-In** is required for all users.
- On first login, users choose:
  - "Participant"
  - "Representative"
- CAPTCHA is required before submitting role request.
- Admins receive email notification to approve/reject each signup request.
- Admin emails are stored in a backend-configured table.

---

## Tire Request Types

| Type               | Flow                                                                 |
|--------------------|----------------------------------------------------------------------|
| PayPal Payment     | Representative adds PayPal invoice link to the request replies.      |
| Credit Card Payment| Representative posts total cost + instructions (e.g., email address).|
| Tire Points        | Participant redeems points (4 = 1 tire).                             |

---

## Points System

Participants have:
- `Available Points`
- `Pending Points` (requested but unfulfilled)
- `Redeemed Points` (fulfilled)

Admins can:
- Bulk add available points to participant accounts.

Participants can:
- View full point breakdown and history.

---

## Request Lifecycle

### States
- `SUBMITTED`: User submitted request
- `AWAITING PAYMENT`: Representative posted invoice or payment instructions
- `PAID`: Participant marked the request as paid
- `SHIPPED`: Representative entered shipping info
- `RECEIVED`: Participant confirms delivery
- `BACKORDERED`: Order delayed by supplier
- `CANCELED`: Either party canceled the request

### Fields
| Field                 | Who Can Edit           |
|----------------------|------------------------|
| Status               | Participant or Representative |
| Product              | Locked after submission |
| Quantity             | Locked after submission |
| Price/Payment Notes  | Representative only     |
| Shipping Info        | Representative only     |
| Tracking Info        | Representative only     |
| Received Date        | Participant only        |
| Chat Replies         | Both parties            |

---

## UI Behavior

### General
- All updates are **real-time (websocket or polling)**.
- No edits allowed after submission, only status transitions.
- Unauthorized actions result in **403 Forbidden** from backend.
- UI should reflect access (e.g., grey out buttons and forms).

### Request Submission
- Large “Request Tires” button on participant dashboard
  - Disabled + red warning if user has ≥ 5 `SUBMITTED` or `AWAITING PAYMENT` requests

- Request Creation Flow:
  1. Product selection (grid with images)
  2. Quantity (1–10)
  3. Payment method selection
  4. Summary + Submit

  - Only **one SKU per request** allowed.

### Request Details Page
- Status tracker
- Chat reply section
- Action buttons (based on role and state)
- Shipping info (if available)
- Payment info (if available)

---

## Chat Replies

- Any participant or representative assigned to the request can post replies.
- Every reply triggers an **email notification** to the other party with a link to the request.

---

## Admin Dashboard

- Admins can:
  - View all requests
  - Filter/sort by:
    - Status
    - Date range
    - Participant name
    - Product name
  - Approve/reject signups
  - Bulk assign points to participants
  - Manually edit any request

Admins can toggle between:
- **Admin dashboard**
- **Participant dashboard** (for their own usage)

---

## Roles Summary

| Capability                                | Participant | Representative | Admin |
|-------------------------------------------|-------------|----------------|-------|
| Submit tire requests                      | ✅          | ❌             | ✅    |
| View/edit own requests                    | ✅          | ✅ (if assigned)| ✅    |
| Assign request                            | ❌          | ✅             | ✅    |
| Post chat replies                         | ✅          | ✅             | ✅    |
| View point balances                       | ✅          | ❌             | ✅    |
| Bulk update points                        | ❌          | ❌             | ✅    |
| Approve/reject user roles                 | ❌          | ❌             | ✅    |
| View all user requests                    | ❌          | ❌             | ✅    |

---

## Technical Requirements

- **Frontend**: Real-time updates (websockets or polling)
- **Backend**:
  - Enforce role-based access (403 on violations)
  - Store request history + timestamps
  - Send email notifications for signup approvals and request replies
- **Database**:
  - Users: id, email, role, status (pending/approved/rejected), is_admin flag
  - Points: participant_id, available, pending, redeemed
  - Requests: product_id, quantity, payment_type, state, shipping info, timestamps, assigned_rep_id
  - Replies: request_id, author_id, message, timestamp
