# Tech Stack

## Frontend

| Technology | Version | Purpose |
|-----------|---------|---------|
| **React** | 19 | Component-based UI framework |
| **TypeScript** | 5.x | Type safety across the entire codebase |
| **React Router** | 7.x | Client-side routing and navigation |
| **Tailwind CSS** | 3.x | Utility-first CSS framework |

---

## Backend

| Technology | Version | Purpose |
|-----------|---------|---------|
| **Node.js** | 22 LTS | Server runtime |
| **Express.js** | 4.x | REST API framework |
| **TypeScript** | 5.x | Type safety on the server |
- Database sessions for authentication 
---

## Database

| Technology | Purpose |
|-----------|---------|
| **PostgreSQL** | Primary relational database for tickets, users, messages |

---

### ORM 

- Prisma

## AI (TBD — pick one)

| Option | Notes |
|--------|-------|
| **Google Gemini API** | Generous free tier, strong at summarization |
| **OpenAI API** | Industry standard, GPT-4o |

Used for:
- Ticket classification (General / Technical / Refund)
- Thread summarization
- Suggested reply generation

---

## Email (TBD — pick one for inbound)

| Direction | Technology | Notes |
|-----------|-----------|-------|
| **Outbound** | Nodemailer (Postmark SMTP) | Sending replies to customers |
| **Inbound** | TBD | Options: SendGrid Inbound Parse, Mailgun Routes, or IMAP polling |


## Deployment 
- Docker + cloud provider (AWS, Railway, fly.io, etc.)