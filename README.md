# SeniorStepPass

SeniorStepPass เป็นแอปพลิเคชัน Flutter ที่ช่วยให้นักศึกษา สามารถค้นหา และติดต่อโครงการฝึกงานได้อย่างสะดวก รวมถึงสามารถติดตามความคืบหน้า และอ่านรีวิวจากรุ่นพี่ได้

---

## Features

- 👤 **ระบบการตรวจสอบสิทธิ์** - เข้าสู่ระบบอย่างปลอดภัยสำหรับนักศึกษา
- 🏢 **การค้นหาโครงการ** - ค้นหาและกรองโครงการฝึกงานตามความสนใจ
- 📋 **รายละเอียดโครงการ** - ดูข้อมูลโครงการ บริษัท และความต้องการอย่างละเอียด
- ⭐ **ระบบรีวิว** - อ่านประสบการณ์จากรุ่นพี่ที่เข้าร่วมมาแล้ว
- 📊 **การติดตามความคืบหน้า** - ติดตามสถานะของใบสมัครและโครงการฝึกงาน
- 💬 **ติดต่อเรา** - ช่องทางติดต่อสำหรับคำถามและข้อสงสัย

---

## Technologies

- **Flutter** - Cross-platform mobile development
- **Dart** - Programming language
- **SQLite** - Local database
- **Provider / State Management** - State management
- **Material Design 3** - UI/UX design system

---

## 📁 โครงสร้างโปรเจค

```
lib/
├── main.dart                    # Entry point ของแอป
├── models/                      # Data models
│   ├── user_model.dart
│   ├── company_model.dart
│   ├── project_model.dart
│   ├── review_model.dart
│   └── index.dart
├── screens/                     # UI screens
│   ├── auth/                    # Authentication screens
│   ├── internship/              # Internship program screens
│   ├── main_screen/             # Home screen
│   ├── menu/                    # Menu screens
│   └── project_main/            # Project detail screens
├── widgets/                     # Reusable widgets
│   ├── common_buttons.dart
│   ├── item_card.dart
│   └── ...
├── database/                    # Database operations
│   └── db_helper.dart
├── theme/                       # App theme configuration
│   └── app_theme.dart
├── contact_us_screen.dart       # Contact screen
├── landing_page.dart            # Landing page
└── loading_screen.dart          # Loading screen
```

---

## How to get started

### Installation Requirements

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (เวอร์ชี่น 3.0 ขึ้นไป)
- [Dart SDK](https://dart.dev/get-dart) (รวมอยู่ใน Flutter)
- IDE: Android Studio, VS Code หรือ Xcode

### ขั้นตอนการติดตั้ง

1. **Clone โปรเจค**
   ```bash
   git clone <repository-url>
   cd seniorsteppass_source
   ```

2. **ดาวน์โหลด dependencies**
   ```bash
   flutter pub get
   ```

3. **รัน แอป**
   ```bash
   flutter run 
   ```

---

## ลิงค์ที่สำคัญ

- 📄 **รายงาน**: [ดูรายงานโปรเจค](https://1drv.ms/w/c/b7f7bebe2926ada8/IQAjzjtF8n_MRahJeZvEa0zHAQ-BF2wC3WG7fsp2cadTSts?e=v057qF)
- 🎨 **Figma Design**: [ดูการออกแบบ](https://www.figma.com/design/4H4p9yVVLmX5pfVAu20lrw/SeniorPassStep?node-id=0-1&t=6PBT7YAdrbyh4aad-1)

---
