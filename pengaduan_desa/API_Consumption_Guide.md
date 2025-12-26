# API Consumption Guide: Flutter Implementation

## 📋 Table of Contents
1. [Konsep Dasar](#konsep-dasar)
2. [Arsitektur Layer](#arsitektur-layer)
3. [Dependencies Setup](#dependencies-setup)
4. [Implementation Flow](#implementation-flow)
5. [Key Components](#key-components)
6. [UI Integration](#ui-integration)
7. [Best Practices](#best-practices)
8. [Common Issues & Solutions](#common-issues--solutions)

---

## 🎯 Konsep Dasar

### Apa itu REST API?
- **Representational State Transfer** - architectural style untuk web services
- Menggunakan **HTTP Methods**: GET, POST, PUT, DELETE
- **Stateless** - setiap request independent
- **JSON** sebagai data format standard

### Client-Server Communication
```
[Flutter App] → [HTTP Request] → [Backend Server]
              ← [JSON Response] ←
```

---

## 🏗️ Arsitektur Layer

### 1. **Presentation Layer** (`lib/ui/`)
- UI Components
- User Interactions
- Display Logic

### 2. **Business Logic Layer** (`lib/provider/`)
- State Management
- Business Rules
- Data Processing

### 3. **Data Layer** (`lib/data/`)
- API Services
- Data Models
- Data Transformation

### 4. **Core Layer** (`lib/core/`)
- Configuration
- Utilities
- Shared Services

---

## 📦 Dependencies Setup

### `pubspec.yaml`
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5          # State management
  dio: ^5.4.0               # HTTP client
  shared_preferences: ^2.2.2 # Local storage
  image_picker: ^1.0.4      # File picker
```

---

## 🔄 Implementation Flow

### Step 1: HTTP Client Configuration

**File: `lib/core/config/dio_client.dart`**
```dart
import 'package:dio/dio.dart';
import '../services/token_storage.dart';
import 'app_constants.dart';

class DioClient {
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // 🔥 PENTING: Auto Authorization
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    return dio;
  }
}
```

**Key Points:**
- ✅ Centralized HTTP configuration
- ✅ Automatic token injection via interceptors
- ✅ Timeout management
- ✅ Base URL management

---

### Step 2: API Service Layer

**File: `lib/data/api/pengaduan_api.dart`**
```dart
import 'package:dio/dio.dart';
import '../../core/config/dio_client.dart';

class PengaduanApi {
  final Dio _dio = DioClient.create();

  // GET ALL DATA
  Future<List<dynamic>> getAll() async {
    final res = await _dio.get('/pengaduan');
    return res.data['data']; // 🔥 PENTING: Access nested data
  }

  // CREATE DATA (dengan File Upload)
  Future<void> createPengaduan(FormData data) async {
    await _dio.post('/pengaduan', data: data);
  }

  // UPDATE DATA
  Future<void> updateStatus({
    required int id,
    required String status,
  }) async {
    await _dio.put('/pengaduan/$id', data: {'status': status});
  }
}
```

**Key Points:**
- ✅ Clean separation of HTTP logic
- ✅ Type-safe methods
- ✅ Proper error handling
- ✅ Support untuk file upload (FormData)

---

### Step 3: Data Models

**File: `lib/data/models/pengaduan_model.dart`**
```dart
class Pengaduan {
  final int id;
  final String judul;
  final String deskripsi;
  final String status;
  final String? imageUrl;
  final DateTime createdAt;

  // 🔥 PENTING: copyWith() untuk immutable updates
  Pengaduan copyWith({
    int? id,
    String? judul,
    String? deskripsi,
    String? status,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Pengaduan(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 🔥 PENTING: fromJson() untuk API response parsing
  factory Pengaduan.fromJson(Map<String, dynamic> json) {
    return Pengaduan(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      deskripsi: json['isi'] ?? '', // API uses 'isi' not 'deskripsi'
      status: json['status'] ?? 'menunggu',
      imageUrl: json['foto'], // API uses 'foto' not 'imageUrl'
      createdAt: json['tanggal'] != null 
          ? DateTime.parse(json['tanggal']) 
          : DateTime.now(),
    );
  }
}
```

**Key Points:**
- ✅ Immutable data classes
- ✅ Null safety dengan default values
- ✅ API field mapping (ini sering jadi problem!)
- ✅ JSON parsing dengan error handling

---

### Step 4: State Management (Provider)

**File: `lib/provider/pengaduan_provider.dart`**
```dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../data/api/pengaduan_api.dart';
import '../data/models/pengaduan_model.dart';

class PengaduanProvider extends ChangeNotifier {
  final _api = PengaduanApi();
  
  List<Pengaduan> list = [];
  bool isLoading = false;
  String? errorMessage;

  // 🔥 PENTING: Fetch dengan proper state management
  Future<void> fetchPengaduan() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final data = await _api.getAll();
      
      // 🔥 PENTING: Error handling saat parsing
      list = data.map((e) {
        try {
          return Pengaduan.fromJson(e);
        } catch (e) {
          debugPrint('Error parsing item: $e');
          debugPrint('Item data: $e');
          return Pengaduan(
            id: 0,
            judul: 'Error Loading Data',
            deskripsi: 'Could not parse this item',
            status: 'error',
            createdAt: DateTime.now(),
          );
        }
      }).where((item) => item.id != 0).toList(); // Filter out error items
    } catch (e) {
      debugPrint('ERROR FETCH PENGADUAN: $e');
      errorMessage = 'Gagal memuat data pengaduan: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔥 PENTING: Create dengan file upload
  Future<void> createPengaduan({
    required String judul,
    required String deskripsi,
    required File image,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final formData = FormData.fromMap({
        'judul': judul,
        'isi': deskripsi, // Use 'isi' to match backend schema
        'foto': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
      });

      await _api.createPengaduan(formData);
      await fetchPengaduan(); // Refresh data
    } catch (e) {
      debugPrint('ERROR CREATE PENGADUAN: $e');
      errorMessage = 'Gagal membuat pengaduan: ${e.toString()}';
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔥 PENTING: Update status dengan local state optimization
  Future<void> updateStatus({
    required int id,
    required String status,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // 1. Panggil API untuk update status di backend
      await _api.updateStatus(id: id, status: status);

      // 2. Update status di list lokal AGAR UI BERUBAH TANPA PERLU FETCH ULANG
      final index = list.indexWhere((item) => item.id == id);
      if (index != -1) {
        list[index] = list[index].copyWith(status: status);
      }
    } catch (e) {
      debugPrint('ERROR UPDATE STATUS: $e');
      errorMessage = 'Gagal mengubah status: ${e.toString()}';
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearErrorMessage() {
    errorMessage = null;
    notifyListeners();
  }
}
```

**Key Points:**
- ✅ Reactive state dengan `notifyListeners()`
- ✅ Loading states management
- ✅ Error handling dengan user-friendly messages
- ✅ Local state optimization (copyWith untuk update)

---

## 🎨 UI Integration

### A. Display Data dengan Loading States

**File: `lib/ui/warga/warga_pengaduan_page.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:pengaduan_desa/provider/pengaduan_provider.dart';
import 'package:pengaduan_desa/ui/pengaduan_detail_page.dart';
import 'package:provider/provider.dart';

class WargaPengaduanPage extends StatefulWidget {
  const WargaPengaduanPage({super.key});

  @override
  State<WargaPengaduanPage> createState() => _WargaPengaduanPageState();
}

class _WargaPengaduanPageState extends State<WargaPengaduanPage> {
  @override
  void initState() {
    super.initState();
    // 🔥 PENTING: Fetch data on init
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      context.read<PengaduanProvider>().fetchPengaduan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PengaduanProvider>();

    return Scaffold(
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.fetchPengaduan(),
              child: provider.list.isEmpty
                  ? const Center(child: Text('Belum ada pengaduan'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.list.length,
                      itemBuilder: (_, i) {
                        final p = provider.list[i];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PengaduanDetailPage(pengaduan: p),
                              ),
                            );
                          },
                          child: Card(
                            child: ListTile(
                              title: Text(p.judul),
                              subtitle: Text(p.deskripsi),
                              trailing: const Icon(Icons.arrow_forward_ios),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
```

### B. Form dengan File Upload

**File: `lib/ui/warga/warga_create_pengaduan_page.dart`**
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pengaduan_desa/provider/pengaduan_provider.dart';
import 'package:provider/provider.dart';

class WargaCreatePengaduanPage extends StatefulWidget {
  const WargaCreatePengaduanPage({super.key});

  @override
  State<WargaCreatePengaduanPage> createState() =>
      _WargaCreatePengaduanPageState();
}

class _WargaCreatePengaduanPageState
    extends State<WargaCreatePengaduanPage> {
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PengaduanProvider>();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            /// JUDUL
            TextField(
              controller: _judulController,
              decoration: const InputDecoration(
                hintText: 'Judul Pengaduan',
              ),
            ),
            const SizedBox(height: 16),

            /// DESKRIPSI
            TextField(
              controller: _deskripsiController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Deskripsi Pengaduan',
              ),
            ),
            const SizedBox(height: 16),

            /// IMAGE PICKER
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _image == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 40),
                          SizedBox(height: 8),
                          Text('Pilih Foto'),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            /// SUBMIT
            ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      // Validation
                      if (_judulController.text.isEmpty ||
                          _deskripsiController.text.isEmpty ||
                          _image == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Semua field wajib diisi'),
                          ),
                        );
                        return;
                      }

                      // Call provider method
                      await provider.createPengaduan(
                        judul: _judulController.text,
                        deskripsi: _deskripsiController.text,
                        image: _image!,
                      );

                      if (!mounted) return;

                      // Success feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pengaduan berhasil dikirim'),
                        ),
                      );

                      // Reset form
                      _judulController.clear();
                      _deskripsiController.clear();
                      setState(() => _image = null);
                    },
              child: provider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Kirim Pengaduan'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔑 Key Components Breakdown

### 1. **HTTP Client (Dio)**
- **Why Dio?** More powerful than http package
- **Features:** Interceptors, timeout, cancel requests
- **Configuration:** Centralized setup with interceptors

### 2. **State Management (Provider)**
- **Why Provider?** Simple, reactive, good for medium apps
- **Pattern:** ChangeNotifier for reactive updates
- **Benefits:** Automatic UI updates, clean separation

### 3. **Data Models**
- **Immutable Objects:** Prevent accidental mutations
- **JSON Parsing:** Safe with null checks
- **Field Mapping:** Handle API vs client naming differences

### 4. **UI Integration**
- **Loading States:** User feedback during async operations
- **Error Handling:** Graceful degradation
- **Form Validation:** Client-side validation before API calls

---

## ✅ Best Practices

### 1. **Error Handling**
```dart
try {
  final data = await _api.getAll();
  // Handle success
} catch (e) {
  debugPrint('ERROR: $e');
  errorMessage = 'User-friendly message';
  notifyListeners();
} finally {
  isLoading = false;
  notifyListeners();
}
```

### 2. **Loading States**
```dart
// Before request
isLoading = true;
notifyListeners();

// After request
isLoading = false;
notifyListeners();
```

### 3. **Form Validation**
```dart
if (_judulController.text.isEmpty ||
    _deskripsiController.text.isEmpty ||
    _image == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Semua field wajib diisi')),
  );
  return;
}
```

### 4. **Memory Management**
```dart
// Dispose controllers
@override
void dispose() {
  _judulController.dispose();
  _deskripsiController.dispose();
  super.dispose();
}
```

---

## ⚠️ Common Issues & Solutions

### 1. **JSON Parsing Errors**
**Problem:** API field names don't match client models
```dart
// API returns: { "judul": "Title", "isi": "Description" }
// Model expects: { "judul": "Title", "deskripsi": "Description" }

// Solution: Map fields in fromJson()
factory Pengaduan.fromJson(Map<String, dynamic> json) {
  return Pengaduan(
    judul: json['judul'] ?? '',
    deskripsi: json['isi'] ?? '', // Map 'isi' to 'deskripsi'
  );
}
```

### 2. **Null Safety Issues**
**Problem:** Null values crash the app
```dart
// Bad: No null checks
final id = json['id'];

// Good: With default values
final id = json['id'] ?? 0;
```

### 3. **File Upload Issues**
**Problem:** MultipartFile not working
```dart
// Wrong: Direct file path
'foto': '/path/to/image.jpg'

// Correct: MultipartFile
'foto': await MultipartFile.fromFile(
  image.path,
  filename: image.path.split('/').last,
),
```

### 4. **Authentication Issues**
**Problem:** 401 Unauthorized errors
```dart
// Solution: Auto-inject token via interceptors
dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await TokenStorage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
  ),
);
```

---

## 🔄 Complete Data Flow

```
1. User Action (Button Click)
   ↓
2. UI Event → Provider Method
   ↓
3. Provider → API Service
   ↓
4. API Service → HTTP Request (Dio)
   ↓
5. Server → JSON Response
   ↓
6. JSON → Model (fromJson)
   ↓
7. Model → Provider State
   ↓
8. notifyListeners() → UI Rebuild
```

---

## 📊 Performance Optimization

### 1. **Efficient List Rendering**
```dart
ListView.builder(
  itemCount: provider.list.length,
  itemBuilder: (_, i) => PengaduanCard(provider.list[i]),
)
```

### 2. **Local State Updates**
```dart
// Instead of re-fetching all data
list[index] = list[index].copyWith(status: newStatus);
notifyListeners();
```

### 3. **Image Optimization**
```dart
// Compress images before upload
final compressedImage = await compressImage(_image!);
```

---

## 🎯 Demo Flow for Presentation

1. **Architecture Overview**
   - Show layered architecture diagram
   - Explain separation of concerns

2. **HTTP Client Setup**
   - Show Dio configuration
   - Demonstrate interceptors

3. **API Service**
   - Show clean API methods
   - Explain error handling

4. **State Management**
   - Live demo of Provider pattern
   - Show reactive updates

5. **UI Integration**
   - Live demo of form submission
   - Show loading states and error handling

6. **Advanced Features**
   - File upload demo
   - Authentication flow

7. **Q&A Session**
   - Address common issues
   - Share troubleshooting tips

---

## 🔗 Additional Resources

- [Dio Documentation](https://pub.dev/packages/dio)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [REST API Best Practices](https://restfulapi.net/)

---

*This guide covers a production-ready implementation of API consumption in Flutter. The patterns and practices shown here are used in real-world applications and follow industry best practices.*
