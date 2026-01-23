# Expense Tracker - Backend

Robust RESTful API built with Spring Boot to handle expense data, user sessions, and bill tracking.

## 🛠 Tech Stack
- **Java 21**
- **Spring Boot 3.2.x**
- **Spring Data JPA** (Hibernatate)
- **SQLite** for lightweight persistence
- **Lombok** for clean models
- **Gradle** for build automation

## 🚀 Getting Started

1. **Run the application:**
   ```bash
   ./gradlew bootRun
   ```

2. **Run tests:**
   ```bash
   ./gradlew test
   ```

## 🏗 API Architecture

### Endpoints

#### Expenses
- `GET /api/expenses?userId={uuid}`: Returns list of expenses filtered by user.
- `POST /api/expenses`: Create a new transaction.
- `PUT /api/expenses/{id}`: Update an existing transaction.
- `DELETE /api/expenses/{id}`: Remove a transaction.

#### Bills
- `GET /api/bills?userId={uuid}`: Returns list of bills for the user.
- `POST /api/bills`: Add a new bill.
- `PUT /api/bills/{id}/pay`: Mark a specific bill as paid.

#### User / Auth
- `POST /api/auth/signup`: Register a new account.
- `POST /api/auth/login`: Authenticate and start a session.
- `GET /api/user`: Retrieve current session user details.

## 💾 Core Logic
- **Data Isolation**: All transactions and bills are linked to a specific `User` entity.
- **Data Seeder**: Automatically generates demo data on the first run if the database is empty.
- **REST Best Practices**: Consistent JSON response structures and HTTP status codes.
- **CORS Config**: Pre-configured to allow requests from the local Vite development server.
