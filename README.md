# Girls — Premium Period Tracking & Women's Wellness App

Girls is a premium, comprehensive mobile application designed for women's wellness, cycle tracking, and reproductive health. Built with a modern tech stack featuring a **Flutter** frontend and a **Django** backend, it leverages the **Google Gemini AI** to provide personalized, dynamic daily health guidance.

## Features

- **📱 Beautiful & Responsive UI:** Premium design with light and dark modes, smooth micro-animations, and intuitive calendar interfaces.
- **🔐 Passwordless Authentication:** Phone number-based login with OTP verification for seamless access.
- **📅 Advanced Cycle Tracking:** Log your periods, flow intensity, and daily symptoms.
- **✨ Smart Predictions:** Accurately predict upcoming periods, fertile windows, and ovulation days based on your historical cycle data.
- **🔔 Local Notifications:** Get timely on-device reminders before your period and on your peak fertility days.
- **🤖 AI-Powered Daily Guidance:** Dynamic, tailored daily health insights and wellness tips powered by Google Gemini AI.
- **🌍 Bilingual Support:** Full localization in both English and Bengali.

---

## Tech Stack

### Frontend (Mobile & Web)
- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **State Management:** Riverpod
- **Routing:** GoRouter
- **Local Storage:** Flutter Secure Storage, Shared Preferences
- **UI & Charts:** FL Chart, Table Calendar, Lottie
- **Networking:** Dio
- **Notifications:** Flutter Local Notifications

### Backend (API)
- **Framework:** [Django](https://www.djangoproject.com/) & Django REST Framework (Python)
- **Authentication:** Custom JWT authentication & OTP handling
- **Database:** SQLite (Development) / PostgreSQL (Production ready)
- **AI Integration:** Google Generative AI (Gemini) SDK
- **Environment Management:** Python-dotenv

---

## Project Structure

```
Girls aPP/
│
├── backend/                  # Django REST API backend
│   ├── apps/
│   │   ├── accounts/         # User models, OTP, Auth endpoints
│   │   ├── cycles/           # Cycle logging & prediction logic
│   │   ├── guidance/         # Gemini AI integration for daily tips
│   │   └── profiles/         # User settings & profile management
│   ├── core/                 # Main Django settings & routing
│   └── manage.py
│
├── lib/                      # Flutter Frontend Application
│   ├── constants/            # Theming, Colors, Text Styles
│   ├── l10n/                 # Localization (English/Bengali)
│   ├── models/               # Dart data models
│   ├── providers/            # Riverpod state management
│   ├── screens/              # UI screens (Auth, Calendar, Profile, etc.)
│   └── services/             # API services & Notification Handlers
│
├── pubspec.yaml              # Flutter dependencies
└── README.md                 # Project documentation
```

---

## Setup Instructions

### 1. Backend Setup (Django)

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Create and activate a virtual environment:
   ```bash
   python -m venv venv
   source venv/Scripts/activate  # On Windows
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Configure Environment Variables:
   - Create a `.env` file in the `backend/` directory.
   - Add your Gemini API Key and secret key:
     ```env
     GEMINI_API_KEY=your_gemini_api_key_here
     SECRET_KEY=your_django_secret_key
     ```
5. Run Migrations & Start Server:
   ```bash
   python manage.py migrate
   python manage.py runserver 0.0.0.0:8000
   ```
6. **(Optional)** Create a Superuser to access the Django Admin panel:
   ```bash
   python manage.py createsuperuser
   ```

### 2. Frontend Setup (Flutter)

1. Make sure the backend server is running and accessible.
2. In the root directory, fetch Flutter packages:
   ```bash
   flutter pub get
   ```
3. Run the app on your preferred device or emulator:
   ```bash
   flutter run
   ```

---

## Authors & Contributors
Developed as a complete solution combining state-of-the-art mobile UI with robust backend engineering and Artificial Intelligence.
