# QuickSlot Flutter App

Flutter client for the QuickSlot hackathon project.

```bash
flutter pub get
copy .env.example .env
flutter run
```

Set `API_BASE_URL` in `.env`:

- Android emulator: `http://10.0.2.2:8000`
- Physical phone: `http://<your-laptop-LAN-IP>:8000`
- Render: `https://<your-render-service>.onrender.com`

The app uses Riverpod for state management, GoRouter for navigation, and Dio for API calls.
