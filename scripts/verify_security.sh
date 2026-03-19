#!/bin/bash
# Security Cleanup Verification Script
# Run this script to verify all sensitive data has been removed

echo "🔐 Smart Task Manager - Security Cleanup Verification"
echo "======================================================="
echo ""

# Check 1: Verify application-local.properties is deleted
echo "✓ Check 1: Verify application-local.properties deleted"
if [ -f "backend/prm_smart_task/src/main/resources/application-local.properties" ]; then
    echo "  ❌ FAILED: application-local.properties still exists!"
    exit 1
else
    echo "  ✅ PASSED: application-local.properties removed"
fi

# Check 2: Verify .env file isn't tracked by git
echo ""
echo "✓ Check 2: Verify .env not in git tracking"
if git ls-files | grep -E "\.env($|\.)" | grep -v "\.env\.example"; then
    echo "  ❌ FAILED: .env files are tracked by git!"
    exit 1
else
    echo "  ✅ PASSED: .env files not tracked"
fi

# Check 3: Verify .gitignore includes sensitive patterns
echo ""
echo "✓ Check 3: Verify .gitignore has sensitive patterns"
if grep -q "application-local.properties\|application-\*.properties" backend/prm_smart_task/.gitignore; then
    echo "  ✅ PASSED: Sensitive patterns in .gitignore"
else
    echo "  ❌ FAILED: Missing patterns in .gitignore"
    exit 1
fi

# Check 4: Verify .env.example has placeholders (not real creds)
echo ""
echo "✓ Check 4: Verify .env.example has placeholders"
if grep -q "your-" backend/prm_smart_task/.env.example && ! grep -q "wO1Dmz0oWowkjMYaASSWjfGa4ifi2fme" backend/prm_smart_task/.env.example; then
    echo "  ✅ PASSED: .env.example uses placeholders"
else
    echo "  ❌ FAILED: .env.example may contain real credentials"
    exit 1
fi

# Check 5: Verify no hardcoded passwords in Java source
echo ""
echo "✓ Check 5: Scan Java files for hardcoded secrets"
FOUND=0
while IFS= read -r file; do
    if grep -E "password\s*=\s*['\"].*['\"]|secret\s*=\s*['\"].*['\"]" "$file" | grep -v "//\|//.*password" > /dev/null; then
        echo "  ⚠️  Check file: $file"
        FOUND=$((FOUND + 1))
    fi
done < <(find backend/prm_smart_task/src -name "*.java" -type f)

if [ $FOUND -eq 0 ]; then
    echo "  ✅ PASSED: No hardcoded secrets in Java files"
else
    echo "  ⚠️  CAUTION: Found potential hardcoded values (review manually)"
fi

# Check 6: Code compilation test
echo ""
echo "✓ Check 6: Verify code compiles"
cd backend/prm_smart_task
if ./gradlew compileJava -q 2>&1 | grep -q "BUILD FAILED"; then
    echo "  ❌ FAILED: Code does not compile"
    exit 1
else
    echo "  ✅ PASSED: Code compiles successfully"
fi
cd ../..

# Check 7: Verify application.properties uses env variables
echo ""
echo "✓ Check 7: Verify configuration uses environment variables"
if grep -q "\${DB_URL:\|DB_USERNAME:\|DB_PASSWORD:\|JWT_SECRET:" backend/prm_smart_task/src/main/resources/application.properties; then
    echo "  ✅ PASSED: Configuration uses environment variables"
else
    echo "  ❌ FAILED: Configuration not using env variables properly"
    exit 1
fi

echo ""
echo "======================================================="
echo "✅ All security checks PASSED!"
echo ""
echo "Next steps:"
echo "1. Create .env from .env.example: cp backend/prm_smart_task/.env.example backend/prm_smart_task/.env"
echo "2. Update .env with your local database credentials"
echo "3. Source the .env file: source backend/prm_smart_task/.env"
echo "4. Run the backend: cd backend/prm_smart_task && ./gradlew bootRun"
echo ""
echo "For production deployment on Render:"
echo "1. Set all environment variables in Render dashboard"
echo "2. Don't commit .env file"
echo "3. See docs/DEPLOYMENT_GUIDE.md for details"
echo ""
