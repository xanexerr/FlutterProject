# Senior Step Pass - ตัวอย่าง Source Code ที่น่าสนใจ

## 🎯 บทนำ
โปรเจค Senior Step Pass มีลักษณะเด่นในการออกแบบ architecture และการจัดการข้อมูล ขอแสดง 3 ตัวอย่าง source code ที่น่าสนใจดังนี้:

---

## 1️⃣ Admin Dashboard - Multi-Tab Navigation Pattern

### 📍 ไฟล์: `lib/screens/admin/admin_dashboard_screen.dart`

### 🎨 หน้าจอ
Admin Dashboard ที่มี 6 โมดูลการจัดการ ผ่าน Navigation Drawer

### 💻 Source Code ที่น่าสนใจ

```dart
// ส่วน initialization - จัดเก็บหน้าจอและชื่อทั้ง 6 โมดูล
class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _OverviewScreen(),
    const UserManagementScreen(),
    const ProjectManagementScreen(),
    const CompanyManagementScreen(),
    const ReviewModerationScreen(),
    const WorkplaceRequestsManagementScreen(),
  ];

  final List<String> _titles = [
    'Dashboard Overview',
    'User Management',
    'Project Management',
    'Company Management',
    'Review Moderation',
    'Workplace Requests',
  ];
```

### 🛠️ Navigation Drawer Implementation

```dart
// การสร้าง Navigation Drawer ที่เปลี่ยน Title ตามหน้าจอที่เลือก
drawer: Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      const DrawerHeader(
        decoration: BoxDecoration(color: AppTheme.primaryTeal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 48, color: AppTheme.white),
            SizedBox(height: 12),
            Text('Portal Admin', style: TextStyle(color: AppTheme.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      // ListTile สำหรับแต่ละโมดูล
      ListTile(
        leading: const Icon(Icons.people),
        title: const Text('User Management'),
        selected: _selectedIndex == 1,  // ✨ Highlight เมื่อเลือก
        onTap: () {
          setState(() => _selectedIndex = 1);  // เปลี่ยนหน้าจอ
          Navigator.pop(context);
        },
      ),
      // ... โมดูลอื่นๆ
    ],
  ),
),

// body เปลี่ยนตามค่า _selectedIndex
body: _pages[_selectedIndex],
```

### ✨ ลักษณะเด่น

| ลักษณะ | รายละเอียด |
|-------|-----------|
| **Pattern** | Multi-Tab Navigation ใช้ State Management |
| **Dynamic Title** | AppBar title เปลี่ยนตามหน้าจอที่เลือก |
| **Clean Code** | Parallel lists สำหรับ pages และ titles |
| **UX** | Navigation drawer บ่งบอกหน้าที่เลือก (selected) |

### 📚 สิ่งที่เรียนรู้ได้
- ✅ Stateful Widget management
- ✅ Navigation pattern
- ✅ Dynamic UI based on state
- ✅ Professional drawer design

---

## 2️⃣ Profile Screen - Complex Firestore Queries

### 📍 ไฟล์: `lib/screens/profile/profile_screen.dart`

### 🎨 หน้าจอ
Profile screen แสดงข้อมูลผู้ใช้ โปรเจคที่เข้าร่วม และรายได้จาก internship

### 💻 Source Code ที่น่าสนใจ

```dart
// Loading data จาก Firestore แบบ Dual-Method
Future<void> _loadAllData() async {
  final userEmail = CurrentUserService().getCurrentUserEmail();
  if (userEmail != null) {
    // ดึง user data พื้นฐาน
    final data = await _dbService.getUserData(userEmail);
    
    // หา user document ID สำหรับ query subcollections
    String userDocId = '';
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        userDocId = userDoc.docs.first.id;
      }
    } catch (e) {
      print('Error fetching user doc ID: $e');
    }
```

### 🔄 Dual Data Fetching Method

```dart
// Method 1: ดึงจาก subcollection users/{userId}/projects
final joinedSnapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(userDocId)
    .collection('projects')
    .get();

// Method 2: ดึงจาก main collection โดยค้นหา studentId ใน members map
final allProjectsSnapshot = await FirebaseFirestore.instance
    .collection('projects')
    .get();

for (var doc in allProjectsSnapshot.docs) {
  final members = doc['members'] as Map<String, dynamic>?;
  
  // ตรวจสอบว่า user อยู่ใน members map
  if (members != null && members.containsKey(data.student_id)) {
    final projectId = doc.id;
    final projectData = {...doc.data(), 'id': projectId};
    joinedProjects.add(projectData);
  }
}
```

### 🔐 Data Consistency Management

```dart
// ตรวจสอบและ sync ข้อมูลระหว่าง subcollection และ main collection
final userProjectDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(userDocId)
    .collection('projects')
    .doc(projectId)
    .get();

if (!userProjectDoc.exists) {
  // ถ้ายังไม่มี subcollection ให้สร้างขึ้น
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userDocId)
      .collection('projects')
      .doc(projectId)
      .set({
        'project_id': projectId,
        'project_title': doc['name'] ?? doc['title'],
        'joined_at': FieldValue.serverTimestamp(),
      });
}
```

### ✨ ลักษณะเด่น

| ลักษณะ | รายละเอียด |
|-------|-----------|
| **Dual Query** | ดึงจากหลาย collection เพื่อความแม่นยำ |
| **Data Sync** | ตรวจสอบ consistency ระหว่าง collections |
| **Error Handling** | Try-catch บน query ที่ซับซ้อน |
| **Performance** | Subcollections สำหรับข้อมูลที่เข้าถึงบ่อย |

### 📚 สิ่งที่เรียนรู้ได้
- ✅ Advanced Firestore queries
- ✅ Subcollections vs main collections
- ✅ Data consistency patterns
- ✅ Handling async operations

---

## 3️⃣ Internship Detail - User Interaction & Data Updates

### 📍 ไฟล์: `lib/screens/internship/internship_detail_screen.dart`

### 🎨 หน้าจอ
Internship detail screen ให้ผู้ใช้เลือก internship เพื่อเพิ่มลงในโปรไฟล์

### 💻 Source Code ที่น่าสนใจ

```dart
// ตรวจสอบว่า internship นี้เลือกไปแล้วหรือไม่
Future<void> _checkIfSelected() async {
  try {
    final userEmail = CurrentUserService().getCurrentUserEmail();
    if (userEmail == null) return;

    final userDoc = await _firestore
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (userDoc.docs.isNotEmpty) {
      final userData = userDoc.docs.first.data();
      final internList = userData['intern_list'] as List<dynamic>? ?? [];
      
      // ตรวจสอบว่า internship นี้อยู่ใน list หรือไม่
      bool isSelected = internList.any((item) =>
          item['company'] == widget.company.company_name &&
          item['role'] == widget.company.department);

      setState(() => _isSelected = isSelected);
    }
  } catch (e) {
    print('Error checking selected internship: $e');
  }
}
```

### ➕ Add Internship Logic

```dart
Future<void> _selectInternship() async {
  // ✅ ตรวจสอบว่าเลือกไปแล้วหรือไม่
  if (_isSelected) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This internship is already selected'),
        backgroundColor: AppTheme.warning,
      ),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    // หา user document
    final userEmail = CurrentUserService().getCurrentUserEmail();
    if (userEmail == null) throw Exception('User not authenticated');

    final userQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      throw Exception('User not found');
    }

    final userDocId = userQuery.docs.first.id;
    final userData = userQuery.docs.first.data();
    final internList = userData['intern_list'] as List<dynamic>? ?? [];

    // สร้าง internship object ใหม่
    final newInternship = {
      'company': widget.company.company_name,
      'role': widget.company.department,
      'logo_url': widget.company.logo_url,
    };

    internList.add(newInternship);  // เพิ่มลงใน list

    // อัพเดท Firebase
    await _firestore.collection('users').doc(userDocId).update({
      'intern_list': internList,
    });

    setState(() => _isSelected = true);

    // แสดง success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Internship added to your profile!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.bad,
        ),
      );
    }
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### ✨ ลักษณะเด่น

| ลักษณะ | รายละเอียด |
|-------|-----------|
| **Validation** | ตรวจสอบ duplicate ก่อนเพิ่ม |
| **List Mutation** | ถูกวิธีการอัพเดท array ใน Firestore |
| **UX Feedback** | Loading state + Success/Error messages |
| **Null Safety** | Handle optional values อย่างปลอดภัย |

### 📚 สิ่งที่เรียนรู้ได้
- ✅ User action handling
- ✅ Array manipulation in Firestore
- ✅ Loading states
- ✅ User feedback (SnackBar)

---

## 📊 การเปรียบเทียบทั้ง 3 ตัวอย่าง

| ลักษณะ | Admin Dashboard | Profile Screen | Internship Detail |
|-------|-----------------|----------------|-------------------|
| **Focus** | UI Architecture | Backend Integration | User Interaction |
| **Complexity** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Firebase** | ❌ | ✅✅ (Complex) | ✅ (Simple) |
| **State Mgmt** | ✅ | ✅✅ | ✅ |
| **Best For** | Navigation Patterns | Data Management | CRUD Operations |

---

## 🚀 ข้อเสนอสำหรับนำเสนอ

### ชุดนำเสนอที่ 1: Frontend Developer
**แนะนำ:** Admin Dashboard + Internship Detail
- แสดง UI/UX patterns
- State management
- User interaction handling

### ชุดนำเสนอที่ 2: Backend/Database Developer
**แนะนำ:** Profile Screen + Internship Detail
- Firebase integration
- Data modeling
- CRUD operations

### ชุดนำเสนอที่ 3: Full Stack Developer
**แนะนำ:** ทั้ง 3 ตัวอย่าง
- Complete architecture overview
- Best practices across layers

---

## 📸 หน้าจอประกอบ
เมื่อนำเสนอ ควรแสดง screenshot เพื่อให้ผู้ฟังเห็นว่า code นี้สร้าง UI อะไรขึ้นมา

---

**สร้างโดย:** Senior Step Pass Development Team  
**วันที่:** April 2026
