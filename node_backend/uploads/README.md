# Uploads Directory

This directory stores uploaded files:

- `videos/` - User uploaded videos
- `profiles/` - Profile pictures and cover images

## File Structure

```
uploads/
├── videos/
│   └── [uuid]-[timestamp].mp4
└── profiles/
    └── [uuid]-[timestamp].[ext]
```

## Notes

- Files are automatically organized by type
- Unique filenames prevent conflicts
- File size limits are enforced in the API
- Local storage is used for development
- Production should use cloud storage (AWS S3, Google Cloud Storage)