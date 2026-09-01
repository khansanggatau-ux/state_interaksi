import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Mengunci aplikasi agar selalu tampil landscape (bukan potrait)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buku Kontak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF2F6FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

/// =====================================================================
/// HALAMAN BERANDA
/// Berisi: AppBar, Navigation Drawer, TabBar, TabBarView, FloatingActionButton
/// =====================================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data kontak & kontak favorit disimpan di sini
  // supaya bisa dipakai bersama oleh semua halaman/tab
  final List<Map<String, String>> contacts = [];
  final List<Map<String, String>> favoriteContacts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Membuka Halaman Tambah Kontak, lalu memasukkan data baru ke daftar kontak
  Future<void> _bukaTambahKontak() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (context) => const TambahKontakPage()),
    );

    if (result != null) {
      setState(() {
        contacts.add(result);
      });
      // Setelah simpan, aplikasi diarahkan kembali ke halaman Kontak
      _tabController.animateTo(0);
    }
  }

  void _bukaTentang() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TentangPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BUKU KONTAK'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Kontak'),
            Tab(icon: Icon(Icons.star), text: 'Favorit'),
          ],
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF2196F3)),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'BUKU KONTAK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Kontak'),
                onTap: () {
                  Navigator.pop(context);
                  _tabController.animateTo(0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Tambah Kontak'),
                onTap: () {
                  Navigator.pop(context);
                  _bukaTambahKontak();
                },
              ),
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: const Text('Favorit'),
                onTap: () {
                  Navigator.pop(context);
                  _tabController.animateTo(1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Tentang'),
                onTap: () {
                  Navigator.pop(context);
                  _bukaTentang();
                },
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          KontakListView(contacts: contacts),
          FavoritListView(favorites: favoriteContacts),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bukaTambahKontak,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// =====================================================================
/// HALAMAN KONTAK (isi Tab pertama)
/// =====================================================================
class KontakListView extends StatelessWidget {
  final List<Map<String, String>> contacts;

  const KontakListView({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada kontak',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF2196F3),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              contact['name'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Email: ${contact['email']}\nHP: ${contact['phone']}',
            ),
          ),
        );
      },
    );
  }
}

/// =====================================================================
/// HALAMAN FAVORIT (isi Tab kedua)
/// =====================================================================
class FavoritListView extends StatelessWidget {
  final List<Map<String, String>> favorites;

  const FavoritListView({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada kontak favorit.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final contact = favorites[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF2196F3),
              child: Icon(Icons.star, color: Colors.white),
            ),
            title: Text(
              contact['name'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Email: ${contact['email']}\nHP: ${contact['phone']}',
            ),
          ),
        );
      },
    );
  }
}

/// =====================================================================
/// HALAMAN TAMBAH KONTAK
/// =====================================================================
class TambahKontakPage extends StatefulWidget {
  const TambahKontakPage({super.key});

  @override
  State<TambahKontakPage> createState() => _TambahKontakPageState();
}

class _TambahKontakPageState extends State<TambahKontakPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _simpanKontak() {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap wajib diisi')),
      );
      return;
    }

    final newContact = {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
    };

    // Mengembalikan data kontak baru ke Halaman Kontak
    Navigator.pop(context, newContact);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kontak')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'No Handphone',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _simpanKontak,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// =====================================================================
/// HALAMAN TENTANG (profil diri)
/// Ganti Nama, Kelas, dan Sekolah di bawah ini dengan data dirimu sendiri
/// =====================================================================
class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 45,
                  backgroundImage: AssetImage('lib/assets/images/asa.jpeg'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Khansa Khairunnisa', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('XII RPL B'), 
                const Text('SMK Negeri 5 Surakarta'), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}