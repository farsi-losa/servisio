import 'dart:io';

import 'package:flutter/material.dart';
import 'package:servisio/add_item_screen.dart';
import 'package:servisio/category_detail_screen.dart';
import 'package:servisio/item_detail_screen.dart';
import 'package:servisio/manage_category_screen.dart';
import 'package:servisio/screens/all_items_screen.dart';
import '../helpers/database_helper.dart';
import '../models/maintenance_models.dart';

void main() {
  runApp(const MaterialApp(home: HomeScreen()));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Category>> _categoriesFuture;
  late Future<List<Item>> _itemsFuture;

  Future<void> _navigateToAddItem() async {
    // Melakukan navigasi ke AddItemScreen dan menunggu respon (result)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddItemScreen()),
    );

    // Jika result == true (dikirim saat barang berhasil disimpan), refresh data di Home
    if (result == true) {
      _refreshData();
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _categoriesFuture = DatabaseHelper.instance.getCategories();
      _itemsFuture = DatabaseHelper.instance.getAllItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddItem,
        backgroundColor: const Color(0xFF0F2537),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Item',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP APP BAR
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    const Text(
                      'Home Care',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2939),
                      ),
                    ),
                    const Spacer(),
                    _buildIconButton(Icons.notifications_none_rounded),
                    const SizedBox(width: 10),
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(
                        'assets/images/profile.png',
                      ), // Ganti dengan asset profil Anda
                    ),
                  ],
                ),
              ),
              // 2. HORIZONTAL ITEM CAROUSEL (Terhubung ke SQLite)
              SizedBox(
                height: 250,
                child: FutureBuilder<List<Item>>(
                  future: _itemsFuture,
                  builder: (context, snapshot) {
                    // 1. Tampilan Loading
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0F2537),
                        ),
                      );
                    }

                    // 2. Tampilan jika Kosong / Belum ada barang
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Belum Ada Barang',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tambahkan barang baru untuk mulai mencatat jadwal maintenance.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // 3. Render List Barang Asli dari SQLite
                    final items = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _buildFeaturedCard(items[index]);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Contoh pada bagian Header Seksi Barang di HomeScreen:
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2939),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllItemsScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          color: Color(0xFF0F2537),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 3. BOTTOM SECTION: CATEGORY SELECTOR
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Header Category & Action Buttons
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Select a\ncategory type',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                              color: Color(0xFF1D2939),
                            ),
                          ),
                        ),
                        // _buildIconButton(Icons.search),
                        // const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const ManageCategoryScreen(),
                              ),
                            );
                            _refreshData(); // Refresh Home saat kembali
                          },
                        ),
                        _buildIconButton(
                          Icons.add,
                          onTap: _showAddCategoryDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // GRID CATEGORIES DARI SQLITE
                    FutureBuilder<List<Category>>(
                      future: _categoriesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('Kategori kosong'));
                        }

                        final categories = snapshot.data!;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.1,
                              ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return _buildCategoryCard(categories[index]);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Button Bulat Putih
  Widget _buildIconButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF344054)),
      ),
    );
  }

  // Card Barang Atas (Horizontal)
  Widget _buildFeaturedCard(Item item) {
    return GestureDetector(
      onTap: () async {
        // 1. Ambil data kategori pendukung dari SQLite berdasarkan categoryId barang
        final categories = await DatabaseHelper.instance.getCategories();
        final category = categories.firstWhere(
          (c) => c.id == item.categoryId,
          orElse: () => Category(id: 0, name: 'Umum'),
        );

        // 2. Navigasi ke Halaman Detail Barang
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ItemDetailScreen(item: item, categoryName: category.name),
          ),
        );

        // 3. Refresh data Home saat kembali dari Halaman Detail (jika ada perubahaan/servis selesai)
        _refreshData();
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(
            0xFF0F2537,
          ), // Background default jika gambar tidak ada
          borderRadius: BorderRadius.circular(28),
          image:
              item.photoPath != null && item.photoPath!.isNotEmpty
                  ? DecorationImage(
                    image: FileImage(File(item.photoPath!)),
                    fit: BoxFit.cover,
                  )
                  : null,
        ),
        child: Stack(
          children: [
            // Dark Overlay tipis jika ada gambar agar teks tetap terlihat jelas
            if (item.photoPath != null && item.photoPath!.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),

            // Tampilan jika tidak ada foto (Placeholder Icon)
            if (item.photoPath == null || item.photoPath!.isEmpty)
              const Center(
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: Colors.white24,
                ),
              ),

            // Glassmorphism Card Info di Bagian Bawah
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF1D2939),
                            ),
                          ),
                          Text(
                            item.location ?? 'Tanpa Lokasi',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F2537),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card Kategori Bawah (Grid)
  Widget _buildCategoryCard(Category category) {
    return GestureDetector(
      onTap: () {
        // NAVIGASI KE CATEGORY DETAIL
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(category: category),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                height: 1.1,
                color: Color(0xFF1D2939),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Mengambil jumlah barang berdasar category ID dari SQLite
                FutureBuilder<List<Item>>(
                  future: DatabaseHelper.instance.getItemsByCategory(
                    category.id!,
                  ),
                  builder: (context, snapshot) {
                    int itemCount =
                        snapshot.hasData ? snapshot.data!.length : 0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$itemCount',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'items',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.category_outlined,
                    color: Color(0xFF344054),
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // DIALOG TAMBAH KATEGORI BARU
  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tambah Kategori Baru'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Nama Kategori (Cth: Taman)',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    await DatabaseHelper.instance.insertCategory(
                      Category(name: controller.text),
                    );
                    Navigator.pop(context);
                    _refreshData(); // Refresh tampilan UI
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }
}
