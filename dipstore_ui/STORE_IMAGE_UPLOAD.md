# Store Image Upload Feature

## Summary
Added the ability for superadmins to upload store images from local files instead of using icons or URLs.

## Changes Made

### 1. Added Dependencies
- `image_picker` - For selecting images from device gallery
- `firebase_storage` - For uploading images to Firebase Storage

### 2. Created StorageService
**File:** `lib/core/services/storage_service.dart`
- Handles image uploads to Firebase Storage
- Supports both web and mobile platforms
- Returns download URLs for uploaded images
- Includes image deletion functionality

### 3. Updated StoreManagementScreen
**File:** `lib/features/profile/store_management_screen.dart`
- Added image picker UI to "Add Store" dialog
- Added image picker UI to "Edit Store" dialog
- Shows preview of selected image before upload
- Displays existing store images in store cards
- Uploads images to Firebase Storage when adding/editing stores

### 4. Firebase Storage Rules
**File:** `storage.rules`
- Created security rules for Firebase Storage
- Allows authenticated users to upload/delete images
- Allows public read access to store and product images

### 5. UI Features
- **Add Store Dialog**: Click on the image placeholder to select an image from your device
- **Edit Store Dialog**: Shows existing image or placeholder, click to change
- **Store Cards**: Display uploaded images with fallback to icons
- **Business Details**: Shows store image in the header

## How to Use

1. Navigate to Profile → Manage Stores (superadmin only)
2. Click "Add Store" button
3. Click on the gray image placeholder
4. Select an image from your device
5. Fill in store details
6. Click "Add" to save

## Next Steps

To deploy the storage rules to Firebase:
```bash
firebase deploy --only storage
```

Or if you haven't initialized Firebase CLI yet:
```bash
firebase init storage
firebase deploy --only storage
```

## Notes
- Images are stored in Firebase Storage under `/stores/` path
- Each image is named with a timestamp to ensure uniqueness
- The system gracefully falls back to category icons if no image is uploaded
- Works on both web and mobile platforms
