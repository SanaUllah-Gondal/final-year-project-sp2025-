SKILLLINK MIXED FILES PACK (Laravel + Flutter)
=================================================
This pack contains *flattened* source stubs for a SkillLink demo.
It is NOT a full production-ready system and excludes heavy folders
like vendor/ and build/ to keep the zip small.

HOW TO REBUILD FOLDERS:
1) Install Python 3.
2) Extract this zip.
3) Run:  python reconstruct.py
4) The proper tree will appear in ./reconstructed/laravel and ./reconstructed/flutter

BACKEND QUICK START (after reconstruction):
- cd reconstructed/laravel
- composer install
- cp .env.example .env   (create if needed)
- php artisan key:generate
- php artisan serve

FRONTEND QUICK START (after reconstruction):
- cd reconstructed/flutter
- flutter pub get
- flutter run

NOTE: These are minimal stubs to demonstrate structure & integration.
Replace with your full project code if you have it.
