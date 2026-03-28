# 📚 ToDoList API - Swagger & Authentication Guide

## 🎯 Project Overview

**ToDoList REST API** built with:
- **.NET 9.0** - Latest ASP.NET Core framework
- **JWT Authentication** - Secure token-based auth
- **Entity Framework Core** - SQL Server database  
- **Swagger/OpenAPI** - Interactive API documentation
- **Repository Pattern** - Clean architecture

---

## 🚀 Getting Started

### Running the Application

```bash
cd ToDoList
dotnet restore
dotnet run
```

The API will start on: `http://localhost:5071` (or check output for actual port)

Access Swagger UI at: `http://localhost:5071/swagger/ui`

---

## 🔐 Authentication Flow

### 1️⃣ Register New Account

**Endpoint**: `POST /api/user/register`

**Request Body**:
```json
{
  "userName": "john_doe",
  "email": "john@example.com",
  "password": "SecurePass123!",
  "fullName": "John Doe"
}
```

**Response** (Success):
```json
{
  "success": true,
  "message": "Đăng ký thành công",
  "token": null
}
```

---

### 2️⃣ Login

**Endpoint**: `POST /api/user/login`

**Request Body**:
```json
{
  "account": "john_doe",
  "password": "SecurePass123!"
}
```

**Response** (Success):
```json
{
  "success": true,
  "message": "Đăng nhập thành công",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiI..."
}
```

> **Note**: Save the `token` value - you'll need it for authenticated requests

---

## 🔑 Using JWT Token in Swagger

### Method 1: Auto-Bearer Token (Easiest)

1. Click the green **"Authorize"** button (🔓) at the top of Swagger page
2. In the modal that appears, enter your token in the Value field:
   ```
   Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiI...
   ```
3. Click **"Authorize"** button
4. Click **"Close"**
5. All future requests will automatically include the token! ✅

### Method 2: Manual Header

1. Find the endpoint you want to test
2. Click **"Try it out"**
3. Scroll down to **"Curl"** command and look for Headers section
4. Manually add: `Authorization: Bearer YOUR_TOKEN`

---

## 📋 API Endpoints Reference

### Authentication (No Auth Required)

#### Register User
```http
POST /api/user/register

{
  "userName": "string",
  "email": "string",
  "password": "string",
  "fullName": "string"
}
```
✅ Returns success message

#### Login
```http
POST /api/user/login

{
  "account": "string (username or email)",
  "password": "string"
}
```
✅ Returns JWT token

---

### Categories (Auth Required - Add Bearer Token)

#### Get All Categories
```http
GET /api/category/category

Headers:
  Authorization: Bearer {token}
```
✅ Returns list of user's categories

#### Create Category
```http
POST /api/category/category

Headers:
  Authorization: Bearer {token}

{
  "categoryName": "string",
  "description": "string"
}
```
✅ Returns created category

---

## 🛠️ Configuration

### JWT Settings (`appsettings.json`)

```json
{
  "Jwt": {
    "Secret": "your-super-secret-key-must-be-at-least-32-characters-long",
    "Issuer": "ToDoListApp",
    "Audience": "ToDoListUsers",
    "ExpiryMinutes": 60
  },
  "ConnectionStrings": {
    "DefaultConnection": "Server=.;Database=ToDoListDB;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
```

### Important Settings

- **Secret**: Encryption key for JWT (Change in production!)
- **ExpiryMinutes**: Token validity period (60 minutes default)
- **Issuer**: Who issued the token
- **Audience**: Who can use the token

---

## 🧪 Testing Flow

### Complete Test Scenario

1. **Register** → Get success message
   ```
   POST /api/user/register
   ```

2. **Login** → Get JWT token
   ```
   POST /api/user/login
   Copy the token from response
   ```

3. **Authorize in Swagger** → Click green Authorize button
   ```
   Enter: Bearer {your_token}
   ```

4. **Get Categories** → Should work now (returns your categories)
   ```
   GET /api/category/category
   ```

5. **Create Category** → Should work with your token
   ```
   POST /api/category/category
   Body: { "categoryName": "Work", "description": "..." }
   ```

---

## ✨ Key Features in Swagger UI

### Interactive Documentation
- ✅ Try requests directly from browser
- ✅ See request/response examples
- ✅ Automatic token injection
- ✅ Status codes & error descriptions

### Authorize Button
- Click 🔓 to add JWT token
- Automatically added to all subsequent requests
- Click again to clear authorization

### Request/Response Examples
- Swagger shows data types
- Example values for each field
- Response status codes
- Error messages

---

## 🔍 Troubleshooting

### "401 Unauthorized" Error
**Problem**: Token not being sent
**Solution**: 
1. Make sure token is copied correctly
2. Use format: `Bearer {token}` (with "Bearer " prefix)
3. Click Authorize button and confirm it shows secured padlock 🔒

### "Token Expired" Error  
**Problem**: JWT token has expired (default: 60 minutes)
**Solution**: 
1. Login again to get new token
2. Update Authorize with new token
3. Or increase `ExpiryMinutes` in appsettings.json

### Database Connection Error
**Problem**: Cannot connect to SQL Server
**Solution**:
1. Ensure SQL Server is running
2. Check connection string in appsettings.json
3. Verify database exists or run migrations

---

## 🔒 Security Notes

⚠️ **For Production**:
1. **Change JWT Secret** to a strong random value
2. **Use HTTPS only** (change to https:// URLs)
3. **Store secrets** in environment variables or Azure Key Vault
4. **Reduce token expiry** time for security
5. **Enable CORS** only for trusted domains
6. **Use strong passwords** for database connections

---

## 📚 Additional Resources

- [Microsoft JWT Bearer Documentation](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/jwt-authn)
- [Swagger/OpenAPI Specification](https://swagger.io/specification/)
- [ASP.NET Core Security Guide](https://learn.microsoft.com/en-us/aspnet/core/security/)
- [Entity Framework Core Documentation](https://learn.microsoft.com/en-us/ef/core/)

---

## 💡 Quick Commands Reference

```bash
# Start API
dotnet run

# Create database migration
dotnet ef migrations add InitialCreate

# Update database
dotnet ef database update

# View Swagger documentation
http://localhost:5071/swagger/ui

# Clear builder cache (if issues)
dotnet clean
rm -r bin obj
dotnet restore
```

---

Happy coding! 🎉
