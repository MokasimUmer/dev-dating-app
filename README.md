# Dev Dating App

A dating application for developers built with Flutter (frontend) and FastAPI (backend), using Supabase as the backend service.

## Project Structure

```
dev-dating-app/
├── frontend/               # Flutter mobile app
│   ├── lib/
│   │   ├── core/          # Navigation, Themes, DI, Errors
│   │   ├── features/      # Feature modules (Clean Architecture)
│   │   │   ├── auth/      # Authentication
│   │   │   ├── discovery/ # Swiping/Matching
│   │   │   └── chat/      # Messaging
│   │   ├── init/          # App initialization
│   │   └── main.dart
│   ├── pubspec.yaml
│   └── .cursorrules       # AI coding guidelines
│
└── backend/               # FastAPI server
    ├── app/
    │   ├── api/v1/        # API routes
    │   ├── core/          # Configuration
    │   ├── domain/        # Business entities & schemas
    │   ├── services/      # Business logic
    │   └── infrastructure/ # External integrations
    ├── main.py
    ├── requirements.txt
    └── .env
```

## Architecture

### Frontend (Flutter)
- **Pattern**: Clean Architecture with BLoC
- **State Management**: flutter_bloc + provider
- **Dependency Injection**: GetIt
- **Backend**: Supabase Flutter SDK

### Backend (FastAPI)
- **Pattern**: Layered Architecture
- **Layers**: API → Services → Infrastructure
- **Database**: Supabase (PostgreSQL)
- **Auth**: JWT tokens

## Getting Started

### Backend Setup

1. Navigate to backend directory:
   ```bash
   cd backend
   ```

2. Create virtual environment:
   ```bash
   python -m venv venv
   venv\Scripts\activate  # Windows
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Configure `.env` file with your Supabase credentials

5. Run the server:
   ```bash
   uvicorn main:app --reload
   ```

### Frontend Setup

1. Navigate to frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Next Steps

1. Set up Supabase project and configure credentials
2. Implement authentication flow
3. Design database schema
4. Build discovery/swiping feature
5. Implement real-time chat

## Tech Stack

**Frontend:**
- Flutter 3.0+
- flutter_bloc (State Management)
- GetIt (DI)
- Supabase Flutter

**Backend:**
- FastAPI
- Pydantic
- Supabase Python SDK
- JWT Authentication
