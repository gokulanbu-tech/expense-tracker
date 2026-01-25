# Expense Tracker - Backend (Spring Boot)

RESTful API backend for the Expense Tracker application with SQLite database.

## 🛠️ Tech Stack

- **Framework**: Spring Boot 3.2.3
- **Language**: Java 21
- **Database**: SQLite (file-based)
- **ORM**: Hibernate/JPA with Community Dialects
- **Build Tool**: Gradle
- **API Documentation**: Swagger/OpenAPI (Springdoc)

## 🚀 Getting Started

### Prerequisites
- Java JDK 21
- Gradle (included via wrapper)

### Run the Application
```bash
./gradlew bootRun
```

The server will start at `http://localhost:8080`

### API Documentation
Once running, visit: `http://localhost:8080/swagger-ui.html`

## 📊 Database

### SQLite Configuration
The application uses SQLite with a file-based database (`expense-tracker.db`) created automatically in the project root.

**Configuration** (`application.yml`):
```yaml
spring:
  datasource:
    url: jdbc:sqlite:expense-tracker.db
    driver-class-name: org.sqlite.JDBC
  jpa:
    database-platform: org.hibernate.community.dialect.SQLiteDialect
    hibernate:
      ddl-auto: update
```

### Schema
Tables are auto-created via Hibernate:
- `users` - User profiles
- `expenses` - Transaction records
- `bills` - Bill tracking
- `sms_messages` - SMS transaction history

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/signup` - Register new user
  ```json
  {
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "mobileNumber": "1234567890",
    "password": "password123",
    "monthlyBudget": 50000.0
  }
  ```

- `POST /api/auth/login` - Login with mobile number
  ```json
  {
    "mobileNumber": "1234567890",
    "password": "password123"
  }
  ```

- `POST /api/auth/google-login` - Google OAuth login
  ```json
  {
    "email": "user@gmail.com",
    "firstName": "John",
    "lastName": "Doe"
  }
  ```

### Expenses
- `GET /api/expenses?userId={uuid}` - Get all expenses for a user
- `POST /api/expenses` - Create new expense
  ```json
  {
    "amount": 500.00,
    "currency": "INR",
    "merchant": "Starbucks",
    "category": "Food",
    "type": "Purchase",
    "date": "2026-01-26T00:00:00Z",
    "source": "Manual",
    "notes": "Coffee with team",
    "user": { "id": "user-uuid-here" }
  }
  ```
- `PUT /api/expenses/{id}` - Update expense
- `DELETE /api/expenses/{id}` - Delete expense

### Bills
- `GET /api/bills?userId={uuid}` - Get all bills for a user
- `POST /api/bills` - Create new bill
- `PUT /api/bills/{id}/pay` - Mark bill as paid

### User Management
- `PUT /api/user/{id}` - Update user profile

## 🗂️ Project Structure

```
src/main/java/com/antigravity/expensetracker/
├── controller/          # REST endpoints
│   ├── AuthController.java
│   ├── ExpenseController.java
│   ├── BillController.java
│   └── UserController.java
├── model/              # JPA entities
│   ├── User.java
│   ├── Expense.java
│   ├── Bill.java
│   └── SmsMessage.java
├── repository/         # Data access layer
│   ├── UserRepository.java
│   ├── ExpenseRepository.java
│   ├── BillRepository.java
│   └── SmsMessageRepository.java
├── service/           # Business logic
│   └── UserService.java
└── ExpenseTrackerBackendApplication.java
```

## 🔐 Security Notes

⚠️ **Development Mode**: 
- Passwords are stored in plain text
- No JWT/token authentication
- CORS enabled for `localhost:5173`

**For Production**:
- Implement password hashing (BCrypt)
- Add JWT authentication
- Configure proper CORS policies
- Use environment variables for sensitive data

## 🔄 CORS Configuration

Currently allows requests from:
- `http://localhost:5173` (React frontend)
- Methods: GET, POST, PUT, DELETE, OPTIONS

## 📦 Dependencies

```gradle
implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
implementation 'org.springframework.boot:spring-boot-starter-web'
implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:2.3.0'
implementation 'org.xerial:sqlite-jdbc:3.45.2.0'
implementation 'org.hibernate.orm:hibernate-community-dialects:6.4.4.Final'
compileOnly 'org.projectlombok:lombok'
annotationProcessor 'org.projectlombok:lombok'
```

## 🐛 Troubleshooting

### Port 8080 Already in Use
```bash
# Kill the process
lsof -ti:8080 | xargs kill -9

# Or change port in application.yml
server:
  port: 8081
```

### Database Locked
SQLite doesn't handle concurrent writes well. For production, migrate to PostgreSQL.

## 🚀 Production Deployment

### Switch to PostgreSQL
1. Update `build.gradle`:
   ```gradle
   implementation 'org.postgresql:postgresql'
   ```

2. Update `application.yml`:
   ```yaml
   spring:
     datasource:
       url: jdbc:postgresql://localhost:5432/expense_tracker
       username: postgres
       password: your_password
     jpa:
       database-platform: org.hibernate.dialect.PostgreSQLDialect
   ```

## 📝 License

Educational project - not for commercial use.
