# Expense Tracker - Backend API

The core backend service for the Expense Tracker ecosystem, built with **Spring Boot 3**. It handles user management, expense logging, and specialized parsing logic for financial data.

## 🛠️ Technology Stack
*   **Language**: Java 21
*   **Framework**: Spring Boot 3.2.3
*   **Database**: SQLite (Default) / PostgreSQL (Supported)
*   **ORM**: Hibernate / Spring Data JPA
*   **AI/LLM**: OpenAI GPT-4o-mini (via `GeminiService`)
*   **Docs**: OpenAPI (Swagger UI)
*   **Build Tool**: Gradle

## 🚀 Getting Started

### 1. Prerequisites
*   Java JDK 21 installed (`java -version`)
*   **OpenAI API Key**: Required for smart parsing and insights.


### 2. Run Locally
```bash
# MacOS / Linux
./gradlew bootRun

# Windows
./gradlew.bat bootRun
```
*   **API URL**: `http://localhost:8080/api`
*   **Swagger Docs**: `http://localhost:8080/swagger-ui/index.html`

### 3. Run with Docker
This application is containerized for easy deployment.
```bash
# Build the image
docker build -t expense-backend .

# Run container (Limit memory to prevent crashes on small VPS)
docker run -p 8080:8080 --memory="512m" expense-backend
```

---

## 🗄️ Database Configuration

### Default: SQLite (Local Dev)
By default, the app uses a file-based **SQLite** database for zero-config development.
*   **File**: `expense-tracker.db` (Created in root directory)
*   **Driver**: `org.sqlite.JDBC`

### Production: PostgreSQL (Neon/AWS)
To switch to PostgreSQL for production:

1.  **Update `build.gradle`**:
    Swap the SQLite dependency for the PostgreSQL driver.
    ```gradle
    // implementation 'org.xerial:sqlite-jdbc:3.45.2.0'
    implementation 'org.postgresql:postgresql'
    ```

2.  **Update `application.yml`**:
    Set your DB credentials (use Environment Variables for security).
    ```yaml
    spring:
      datasource:
        url: ${DATABASE_URL}
        username: ${DATABASE_USERNAME}
        password: ${DATABASE_PASSWORD}
    ```

### OpenAI API Key
The application requires an OpenAI API key for parsing emails and generating insights.
1.  **Environment Variable**: Set `OPENAI_API_KEY` in your environment.
2.  **Application Config**: Or update `application.yml`:
    ```yaml
    openai:
      api:
        key: ${OPENAI_API_KEY}
    ```




---

## 💰 Currency Handling
*   **Storage**: Expenses are stored with their **original currency code** (e.g., USD, EUR, INR) and amount. 
*   **Logic**: The backend does NOT perform currency conversion. It serves raw data to clients. All conversion logic (e.g., for aggregate charts) is offloaded to the frontend (Static Map strategy) to ensure simplicity and reliability without dependence on external exchange rate APIs.

---

---

## 🤖 AI Features
Powered by **GPT-4o-mini**, the backend provides:
*   **Smart Parsing**: Tries to extract structured data (amount, merchant, category) from raw email/SMS text.
*   **Financial Insights**: Analyzes monthly spending to offer actionable savings advice.
*   **Chatbot Context**: Provides context-aware answers to user queries about their financial data (last 30 days).

---

## 🔑 Key API Endpoints


### Authentication
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/api/auth/signup` | Register a new user |
| `POST` | `/api/auth/login` | Login with mobile/password |

### Expenses
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/expenses` | Get all expenses (filterable) |
| `POST` | `/api/expenses` | Log a new expense |
| `PUT` | `/api/expenses/{id}` | Update details |
| `DELETE` | `/api/expenses/{id}` | Remove an expense |

### Bills
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/bills` | List upcoming bills |
| `POST` | `/api/bills` | Add a recurring bill |
| `PUT` | `/api/bills/{id}` | Update bill details |
| `DELETE` | `/api/bills/{id}` | Delete a recurring bill |
| `POST` | `/api/bills/{id}/pay` | Manually mark a bill as paid (advances due date) |

> **Note**: The system also includes an **Auto-Pay Engine** that:
> 1.  Automatically detects recurring bills from email patterns.
> 2.  Matches incoming expenses to existing bills to mark them as paid.
> 3.  Manages recurrence by automatically advancing the due date upon payment.

---

## 📂 Project Structure
```
src/main/java/com/antigravity/expensetracker/
├── config/         # App configurations (Swagger, CORS)
├── controller/     # REST API Controllers
├── model/          # JPA Entities (DB Tables)
├── repository/     # Data Access Interfaces
├── service/        # Business Logic (Parsing, Auth)
└── util/           # Helper classes
```
