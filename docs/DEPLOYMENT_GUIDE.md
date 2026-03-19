# Smart Task Manager - Deployment Guide

This guide covers local development setup and production deployment on Render.

---

## 📋 Security Checklist

Before deploying to production, ensure you've completed:

- ✅ Removed `application-local.properties` (contains hardcoded credentials)
- ✅ Updated `.gitignore` to exclude sensitive files
- ✅ Generated strong JWT_SECRET (minimum 32 characters)
- ✅ Set all environment variables in Render dashboard
- ✅ Never commit `.env` files or password configs
- ✅ Changed `JPA_DDL_AUTO` to `validate` in production (not `update`)

---

## 🖥️ Local Development Setup

### Prerequisites

- **Java 17+** (Spring Boot 4.0.3 requires Java 17)
- **Gradle** (included via gradlew)
- **PostgreSQL 13+** (local or cloud database)
- **.env file** (copy from .env.example)

### Step 1: Clone Repository

```bash
git clone <your-repo-url>
cd prm_smart_task/backend/prm_smart_task
```

### Step 2: Create .env File

```bash
cp .env.example .env
```

### Step 3: Configure .env for Local Development

Edit `.env` with your local PostgreSQL credentials:

```env
PORT=8080

# PostgreSQL - Configure for your local setup
DB_URL=jdbc:postgresql://localhost:5432/prm_smart_task?sslmode=disable
DB_USERNAME=postgres
DB_PASSWORD=postgres

# JWT - Generate a strong secret for local testing
JWT_SECRET=your-local-secret-key-minimum-32-characters-required
JWT_EXPIRATION_MS=86400000
JWT_REFRESH_EXPIRATION_MS=604800000

# Database Schema
JPA_DDL_AUTO=update
JPA_SHOW_SQL=false
```

### Step 4: Create Local PostgreSQL Database

```bash
# If using PostgreSQL locally, connect and run:
createdb prm_smart_task
```

Or if using pgAdmin / GUI client, create a database named `prm_smart_task`.

### Step 5: Load Environment Variables and Run

```bash
cd /path/to/prm_smart_task/backend/prm_smart_task

# Export environment variables from .env
set -a
source .env
set +a

# Run the backend
./gradlew bootRun
```

You should see:
```
Started PrmSmartTaskApplication in X seconds
```

Visit: `http://localhost:8080/api/auth/register` (to verify server is running)

### Step 6: Test API Endpoints

Use provided `.http` files in `test_api/` folder:

```bash
# Example: Test registration endpoint
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test@123456",
    "fullName": "Test User",
    "avatarUrl": "https://example.com/avatar.jpg"
  }'
```

Or use VS Code REST Client extension to run `.http` files directly.

---

## ☁️ Production Deployment on Render

### Step 1: Create Web Service on Render

1. Go to [render.com](https://render.com)
2. Create new Web Service
3. Connect your GitHub repository
4. Select the branch to deploy

### Step 2: Configure Environment Variables

In Render service settings, add these environment variables:

```
PORT=10000
DB_URL=jdbc:postgresql://<your-host>:5432/<your-database>?sslmode=require
DB_USERNAME=<your-username>
DB_PASSWORD=<your-strong-password>
JWT_SECRET=<generate-strong-32-char-secret>
JWT_EXPIRATION_MS=86400000
JWT_REFRESH_EXPIRATION_MS=604800000
JPA_DDL_AUTO=validate
JPA_SHOW_SQL=false
```

### Step 3: Add Build and Start Commands

In Render service settings:

**Build Command:**
```bash
cd backend/prm_smart_task && ./gradlew bootJar
```

**Start Command:**
```bash
cd backend/prm_smart_task && java -jar build/libs/prm_smart_task-*.jar
```

### Step 4: Configure PostgreSQL Database

Option A: Use Render PostgreSQL addon
- Create PostgreSQL database in Render
- Copy connection details to environment variables

Option B: Use external PostgreSQL
- Ensure database allows external connections
- Use JDBC URL format: `jdbc:postgresql://host:5432/db?sslmode=require`

### Step 5: Deploy

1. Commit all changes to git
2. Push to your GitHub branch
3. Render automatically triggers deployment
4. Monitor logs in Render dashboard

### Step 6: Verify Deployment

Once deployment succeeds:

```bash
# Test the API
curl -X POST https://your-render-url/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "prod@example.com",
    "password": "Prod@123456",
    "fullName": "Production User",
    "avatarUrl": "https://example.com/avatar.jpg"
  }'
```

---

## 🔐 Production Security Best Practices

### 1. JWT Secret Management

Generate a strong JWT secret:

```bash
# On macOS/Linux
openssl rand -base64 32

# Output example (use this):
# ABC+/1234567890abcdefghijklmnopqrstuv==
```

Use this in `JWT_SECRET` environment variable.

### 2. Database Security

- Use `sslmode=require` in JDBC URL (encrypted connection)
- Only allow connections from Render IP
- Use strong passwords (20+ characters, mixed case, numbers, symbols)
- Regularly rotate database passwords
- Use environment variables, never hardcode passwords

### 3. API Security

- All non-auth endpoints require JWT token
- Tokens expire after 24 hours
- Refresh tokens stored in database (server-side revocation possible)
- Workspace membership enforced for all operations
- Admin role required for project/kanban management

### 4. Monitoring

- Enable Spring Cloud Config for distributed configuration
- Set up application logs aggregation
- Monitor database performance in Render dashboard
- Set up alerts for failed deployments

---

## 🚨 Troubleshooting

### Build Fails: "Gradle daemon could not connect"

Solution:
```bash
./gradlew --stop
./gradlew clean bootJar
```

### Database Connection Error: "postgres role does not exist"

Solution: Check `DB_USERNAME` and `DB_PASSWORD` match your PostgreSQL credentials

### JWT Token Error: "secret key too short"

Solution: Ensure `JWT_SECRET` is minimum 32 characters

### Render Deployment Timeout

Solution: Check Render build logs for specific errors. Increase timeout or reduce JAR size by:
```gradle
// In build.gradle, add excludes if needed
jar {
    exclude 'META-INF/MANIFEST.MF'
}
```

### Application Port Already in Use

Solution:
```bash
# Find process using port 8080
lsof -i :8080

# Kill the process
kill -9 <PID>
```

---

## 📊 Monitoring Deployment

### View Render Logs

```bash
# Via Render dashboard logs tab
# Real-time monitoring available
```

### Check Application Health

```bash
# Add health check endpoint (optional)
curl https://your-render-url/actuator/health
```

### Database Connection Pool Stats

Enable in application.properties:
```properties
spring.jpa.properties.hibernate.generate_statistics=true
```

---

## 🔄 Database Migrations

If you need to migrate database schema:

1. **Development:** Set `JPA_DDL_AUTO=update` (auto-creates tables)
2. **Production:** Set `JPA_DDL_AUTO=validate` (prevents unwanted changes)
3. For major migrations, consider using Flyway or Liquibase

---

## 📚 Additional Resources

- [Render Documentation](https://render.com/docs)
- [Spring Boot Deployment Guide](https://spring.io/guides/gs/spring-boot/)
- [PostgreSQL JDBC Configuration](https://jdbc.postgresql.org/documentation/head/connect.html)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8949)

---

## ✅ Deployment Checklist

Before going to production:

- [ ] All environment variables configured in Render
- [ ] Database created and accessible
- [ ] JWT_SECRET is 32+ characters, strong, and unique
- [ ] `JPA_DDL_AUTO=validate` set in production
- [ ] `JPA_SHOW_SQL=false` in production
- [ ] Build command tested locally: `./gradlew bootJar`
- [ ] Start command verified
- [ ] API endpoints tested after deployment
- [ ] HTTPS enabled (Render provides automatic SSL)
- [ ] Logs monitored for errors
- [ ] Backup strategy in place for database

---

**Last Updated:** March 2026  
**Maintained By:** Smart Task Manager Team
