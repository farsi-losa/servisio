import 'package:flutter/material.dart';
import 'package:servisio/add_item_screen.dart';
import 'package:servisio/item_detail_screen.dart';
import 'dart:io';
import '../helpers/database_helper.dart';
import '../models/maintenance_models.dart';

class AllItemsScreen extends StatefulWidget {
  const AllItemsScreen({Key? key}) : super(key: key);

  @override
  State<AllItemsScreen> createState() => _AllItemsScreenState();
}

class _AllItemsScreenState extends State<AllItemsScreen> {
  List<Item> _allItems = [];
  List<Item> _filteredItems = [];
  Map<int, String> _categoryMap = {};
  bool _isLoading = true;
  bool _isManageMode = false; // Status mode kelola aktif/tidak

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    final categories = await DatabaseHelper.instance.getCategories();
    final Map<int, String> catMap = {
      for (var cat in categories) cat.id!: cat.name,
    };

    final items = await DatabaseHelper.instance.getAllItems();

    setState(() {
      _categoryMap = catMap;
      _allItems = items;
      _filteredItems = items;
      _isLoading = false;
    });
  }

  void _filterItems(String query) {
    if (query.isEmpty) {
      setState(() => _filteredItems = _allItems);
    } else {
      setState(() {
        _filteredItems =
            _allItems.where((item) {
              final nameMatch = item.name.toLowerCase().contains(
                query.toLowerCase(),
              );
              final brandMatch =
                  item.brand?.toLowerCase().contains(query.toLowerCase()) ??
                  false;
              final locationMatch =
                  item.location?.toLowerCase().contains(query.toLowerCase()) ??
                  false;
              return nameMatch || brandMatch || locationMatch;
            }).toList();
      });
    }
  }

  void _confirmDeleteItem(Item item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Hapus Barang'),
          content: Text('Apakah Anda yakin ingin menghapus "${item.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await DatabaseHelper.instance.deleteItem(item.id!);
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.name} berhasil dihapus')),
                );
                _loadAllData();
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1D2939),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Semua Barang',
          style: TextStyle(
            color: Color(0xFF1D2939),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // TOMBOL KELOLA / SELESAI
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isManageMode = !_isManageMode;
                });
              },
              child: Text(
                _isManageMode ? 'Selesai' : 'Kelola',
                style: TextStyle(
                  color:
                      _isManageMode
                          ? Colors.redAccent
                          : const Color(0xFF0F2537),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _filterItems,
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama, merek, lokasi...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF667085),
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _filterItems('');
                          },
                        )
                        : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF0F2537),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // GRID BARANG
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredItems.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Belum ada barang yang tersimpan.'
                                : 'Barang tidak ditemukan.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final categoryName =
                            _categoryMap[item.categoryId] ?? 'Umum';
                        return _buildGridCard(item, categoryName);
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F2537),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          );
          if (result == true) {
            _loadAllData();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Barang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildGridCard(Item item, String categoryName) {
    return GestureDetector(
      onTap: () async {
        if (_isManageMode)
          return; // Nonaktifkan klik ke detail saat mode kelola
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ItemDetailScreen(item: item, categoryName: categoryName),
          ),
        );
        _loadAllData();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(77),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail Foto Barang
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2537),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      image:
                          item.photoPath != null && item.photoPath!.isNotEmpty
                              ? DecorationImage(
                                image: FileImage(File(item.photoPath!)),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        item.photoPath == null || item.photoPath!.isEmpty
                            ? const Center(
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: 40,
                                color: Colors.white30,
                              ),
                            )
                            : null,
                  ),
                ),

                // Informasi Barang
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[500],
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              item.location ?? '-',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // TOMBOL SAMPAH (HANYA MUNCUL SAAT MODE KELOLA AKTIF)
            if (_isManageMode)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _confirmDeleteItem(item),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
