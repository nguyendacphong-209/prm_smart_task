# Cloudinary Integration Documentation

## Setup

### 1. Create a Cloudinary Account
- Go to https://cloudinary.com and sign up (free tier available)
- Verify your email

### 2. Get Your Credentials
- Go to https://console.cloudinary.com/settings/c/{cloud-name}/access_keys
- Copy your credentials:
  - Cloud name
  - API Key
  - API Secret

### 3. Configure Backend
- Copy `.env.example` to `.env` in backend folder
- Fill in your Cloudinary credentials:
```
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
```

- Or set environment variables before running the app

### 4. Database Migration
Run the migration SQL to add image_url columns:
```sql
-- Run file: docs/migrations/001_add_image_url_to_workspace_project_task.sql
ALTER TABLE workspaces ADD COLUMN image_url TEXT;
ALTER TABLE projects ADD COLUMN image_url TEXT;
ALTER TABLE tasks ADD COLUMN image_url TEXT;
```

## API Endpoints

### Upload Workspace Image
```
POST /api/images/workspace/{workspaceId}/upload
Content-Type: multipart/form-data

Parameters:
- file: Image file (jpeg, png, etc.)

Response:
{
  "imageUrl": "https://res.cloudinary.com/.../workspace_image.jpg",
  "message": "Workspace image uploaded successfully"
}
```

### Upload Project Image
```
POST /api/images/project/{projectId}/upload
Content-Type: multipart/form-data

Parameters:
- file: Image file (jpeg, png, etc.)

Response:
{
  "imageUrl": "https://res.cloudinary.com/.../project_image.jpg",
  "message": "Project image uploaded successfully"
}
```

### Upload Task Image
```
POST /api/images/task/{taskId}/upload
Content-Type: multipart/form-data

Parameters:
- file: Image file (jpeg, png, etc.)

Response:
{
  "imageUrl": "https://res.cloudinary.com/.../task_image.jpg",
  "message": "Task image uploaded successfully"
}
```

### Delete Image
```
DELETE /api/images/delete?imageUrl=https://res.cloudinary.com/.../image.jpg

Response:
{
  "message": "Image deleted successfully"
}
```

## File Structure

```
backend/
├── src/main/java/com/example/prm_smart_task/
│   ├── config/
│   │   └── CloudinaryConfig.java         # Spring Bean configuration
│   ├── controller/
│   │   └── ImageUploadController.java    # REST API endpoints
│   ├── service/
│   │   └── CloudinaryService.java        # Cloudinary operations
│   ├── entity/
│   │   ├── Workspace.java                # Added imageUrl field
│   │   ├── Project.java                  # Added imageUrl field
│   │   └── Task.java                     # Added imageUrl field
│   └── dto/
│       ├── ImageUploadResponseDto.java
│       ├── WorkspaceResponseDto.java     # With imageUrl
│       ├── ProjectResponseDto.java       # With imageUrl
│       └── TaskResponseDto.java          # With imageUrl
├── src/main/resources/
│   └── application.properties             # Cloudinary config properties
└── docs/
    └── migrations/
        └── 001_add_image_url_to_workspace_project_task.sql

```

## How It Works

1. **Upload Flow**:
   - User sends image file via multipart/form-data
   - `ImageUploadController` receives request
   - `CloudinaryService.uploadImage()` uploads to Cloudinary
   - Returns secure URL (HTTPS)
   - URL is saved in database (workspace.imageUrl, project.imageUrl, task.imageUrl)
   - Old image is automatically deleted if exists

2. **Delete Flow**:
   - URL is extracted to get Cloudinary public ID
   - Image is deleted from Cloudinary
   - Entity.imageUrl is cleared (optional, done via UPDATE query)

3. **Image Optimization**:
   - Auto quality detection (`quality: auto`)
   - Auto format selection for browser (`fetch_format: auto`)
   - Organized in folders: workspace/, project/, task/

## Security Notes

- **Never commit credentials** to git
- Use environment variables for deployment
- Cloudinary API Secret is server-side only
- File size limit: 10MB (configurable in application.properties)
- Validate file type on frontend (image/* only)

## Environment Variables for Different Stages

### Development
```
CLOUDINARY_CLOUD_NAME=dev-cloud
CLOUDINARY_API_KEY=dev-key
CLOUDINARY_API_SECRET=dev-secret
```

### Production
```
# Set via .env file or Docker secrets
CLOUDINARY_CLOUD_NAME=prod-cloud
CLOUDINARY_API_KEY=prod-key
CLOUDINARY_API_SECRET=prod-secret
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| 401 Unauthorized | Check API key and secret are correct |
| 413 Payload Too Large | Increase max file size in application.properties |
| Image not saved in DB | Check database connection and entity mapping |
| Cannot delete old image | Check if image URL format is correct |
