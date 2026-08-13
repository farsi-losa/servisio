import 'package:flutter/material.dart';
import 'package:servisio/screens/edit_item_screen.dart';
import 'dart:io';
import '../helpers/database_helper.dart';
import '../models/maintenance_models.dart';

class ItemDetailScreen extends StatefulWidget {
  final Item item;
  final String categoryName;

  const ItemDetailScreen({
    super.key,
    required this.item,
    required this.categoryName,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late Future<List<MaintenanceTask>> _tasksFuture;
  late Future<List<ServiceLog>> _allLogsFuture;

  int _selectedLogIndex = 0;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _tasksFuture = DatabaseHelper.instance.getTasksByItem(widget.item.id!);
      _allLogsFuture = _loadAllLogs();
    });
  }

  // Mengambil semua histori servis untuk ditampilkan pada bagian "Historical Logs"
  Future<List<ServiceLog>> _loadAllLogs() async {
    final tasks = await DatabaseHelper.instance.getTasksByItem(widget.item.id!);
    List<ServiceLog> allLogs = [];
    for (var task in tasks) {
      final logs = await DatabaseHelper.instance.getServiceLogsByTask(task.id!);
      allLogs.addAll(logs);
    }
    allLogs.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
    return allLogs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFEBE7DF,
      ), // Light warm grey/beige background

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP BAR & IMAGE PRODUCT
              // Gantilah bagian Stack (Atas) pada ItemDetailScreen dengan kode ini:
              Stack(
                children: [
                  // 1. FULL BACKGROUND IMAGE HEADER
                  Container(
                    height: 320,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDD7CD), // Fallback color
                      image:
                          widget.item.photoPath != null &&
                                  widget.item.photoPath!.isNotEmpty
                              ? DecorationImage(
                                image: FileImage(File(widget.item.photoPath!)),
                                fit:
                                    BoxFit
                                        .cover, // Gambar memenuhi seluruh area header
                              )
                              : const DecorationImage(
                                image: NetworkImage(
                                  'https://png.pngtree.com/png-vector/20230906/ourmid/pngtree-white-air-conditioner-isolated-png-image_10006282.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                    ),
                    // 2. GRADIENT OVERLAY (Agar tombol & teks tetap terbaca jelas)
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(
                              alpha: 0.4,
                            ), // Gelap di atas untuk tombol
                            Colors.transparent, // Jernih di tengah
                            Colors.black.withValues(
                              alpha: 0.2,
                            ), // Shadow tipis di bawah
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. ACTION BUTTONS OVERLAY (Tombol Back & Favorite)
                  Positioned(
                    top: 16,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCircleButton(
                          Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF0F2537),
                              size: 18,
                            ),
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        EditItemScreen(item: widget.item),
                              ),
                            );

                            // Jika data berhasil di-update, tutup halaman detail untuk refresh data di halaman sebelumnya
                            if (result == true && context.mounted) {
                              Navigator.pop(context, true);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Text(
                      widget.item.brand != null && widget.item.brand!.isNotEmpty
                          ? widget.item.brand!
                          : 'No Brand',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(0, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // 2. TITLE & ACTION BUTTONS (Phone & Calendar)
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                              color: Color(0xFF1D2939),
                            ),
                          ),
                          if (widget.item.location != null)
                            Text(
                              widget.item.location!,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D2939),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            widget.categoryName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildCircleButton(Icons.phone_outlined),
                    const SizedBox(width: 12),
                    _buildCircleButton(Icons.calendar_today_outlined),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. STATS CARD (Age & Total Services)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDD7CD).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      // Age Stat
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.speed_outlined,
                              size: 32,
                              color: Color(0xFF344054),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '3 Years',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF1D2939),
                                  ),
                                ),
                                Text(
                                  'Age',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(height: 30, width: 1, color: Colors.black12),
                      // Total Services Stat
                      Expanded(
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.build_outlined,
                              size: 30,
                              color: Color(0xFF344054),
                            ),
                            const SizedBox(width: 12),
                            FutureBuilder<List<ServiceLog>>(
                              future: _allLogsFuture,
                              builder: (context, snapshot) {
                                int total =
                                    snapshot.hasData
                                        ? snapshot.data!.length
                                        : 0;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$total+',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF1D2939),
                                      ),
                                    ),
                                    Text(
                                      'Total Services',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
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

              const SizedBox(height: 24),

              // 4. BOTTOM SHEET CONTENT (Daftar Maintenance & Historical Logs)
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daftar Maintenance',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2939),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // LIST TUGAS MAINTENANCE DARI SQLITE
                    FutureBuilder<List<MaintenanceTask>>(
                      future: _tasksFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return _buildEmptyTaskState();
                        }

                        final tasks = snapshot.data!;
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tasks.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            // Selang-seling warna kartu (Light Grey vs Light Mint Green)
                            bool isMint = index % 2 != 0;
                            return _buildMaintenanceCard(
                              tasks[index],
                              isMint: isMint,
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // HISTORICAL LOGS SECTION
                    const Text(
                      'Historical Logs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2939),
                      ),
                    ),
                    const SizedBox(height: 12),

                    FutureBuilder<List<ServiceLog>>(
                      future: _allLogsFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text(
                            'Belum ada riwayat servis terrekam.',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          );
                        }

                        final logs = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Horizontal Date Tabs
                            SizedBox(
                              height: 40,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: logs.length,
                                itemBuilder: (context, index) {
                                  bool isSelected = _selectedLogIndex == index;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedLogIndex = index;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 20),
                                      padding: const EdgeInsets.only(bottom: 6),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color:
                                                isSelected
                                                    ? const Color(0xFF1D2939)
                                                    : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        logs[index].serviceDate,
                                        style: TextStyle(
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                          color:
                                              isSelected
                                                  ? const Color(0xFF1D2939)
                                                  : Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Details of selected log
                            Text(
                              logs[_selectedLogIndex].notes ??
                                  'Servis Rutin Berhasil',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF344054),
                              ),
                            ),
                          ],
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

  // WIDGET CARD MAINTENANCE (Cuci AC / Ganti Freon)
  Widget _buildMaintenanceCard(MaintenanceTask task, {bool isMint = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMint ? const Color(0xFFE8FAF6) : const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.taskName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2939),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'periode ${task.intervalMonths} bulan sekali',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    text: 'Berikutnya: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: task.nextDueDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Mark As Done Button
          GestureDetector(
            onTap: () => _showServiceModal(task),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF10B981),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'mark as\ndone',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF344054),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF344054)),
        ],
      ),
    );
  }

  // DIALOG MODAL SAMA SEPERTI GAMBAR 2 (POPUPS MARK SERVICE COMPLETED)
  void _showServiceModal(MaintenanceTask task) {
    showDialog(
      context: context,
      builder:
          (context) => ServiceDetailDialog(
            task: task,
            onCompleted: () {
              _refreshData(); // Refresh UI setelah servis ditandai selesai
            },
          ),
    );
  }

  Widget _buildEmptyTaskState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Belum ada jadwal maintenance',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF0F2537),
            ),
            onPressed: _showAddTaskDialog,
          ),
        ],
      ),
    );
  }

  // DIALOG TAMBAH TASK MAINTENANCE BARU
  void _showAddTaskDialog() {
    final nameCtrl = TextEditingController();
    final intervalCtrl = TextEditingController(text: '3');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tambah Tugas Maintenance'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Tugas (cth: Cuci AC)',
                  ),
                ),
                TextField(
                  controller: intervalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Interval (Bulan)',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isNotEmpty) {
                    final newTask = MaintenanceTask(
                      itemId: widget.item.id!,
                      taskName: nameCtrl.text,
                      intervalMonths: int.tryParse(intervalCtrl.text) ?? 3,
                      nextDueDate:
                          DateTime.now().toIso8601String().split('T')[0],
                    );
                    await DatabaseHelper.instance.insertTask(newTask);
                    Navigator.pop(context);
                    _refreshData();
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  Widget _buildCircleButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF344054)),
      ),
    );
  }
}

// ============================================================================
// WIDGET MODAL DIALOG (GAMBAR 2: POP-UP HISTORI & MARK COMPLETED)
// ============================================================================
class ServiceDetailDialog extends StatefulWidget {
  final MaintenanceTask task;
  final VoidCallback onCompleted;

  const ServiceDetailDialog({
    super.key,
    required this.task,
    required this.onCompleted,
  });

  @override
  State<ServiceDetailDialog> createState() => _ServiceDetailDialogState();
}

class _ServiceDetailDialogState extends State<ServiceDetailDialog> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _costController = TextEditingController(
    text: '60000',
  );
  late Future<List<ServiceLog>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = DatabaseHelper.instance.getServiceLogsByTask(widget.task.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Dialog (Title & Close 'x')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.task.taskName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2939),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              'History logs',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // History Logs List inside Modal
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: FutureBuilder<List<ServiceLog>>(
                future: _logsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text(
                      'Belum ada log histori',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    );
                  }
                  final logs = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              log.serviceDate,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF344054),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Rp ${log.cost.toInt()}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF344054),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'ok',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Input Notes
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Notes',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button ("mark last service as completed")
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final cost = double.tryParse(_costController.text) ?? 0.0;
                  final today = DateTime.now().toIso8601String().split('T')[0];

                  await DatabaseHelper.instance.completeTaskAndLog(
                    task: widget.task,
                    serviceDate: today,
                    cost: cost,
                    notes:
                        _notesController.text.isNotEmpty
                            ? _notesController.text
                            : null,
                  );

                  widget.onCompleted();
                  if (mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0097B2), // Tosca button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'mark last service as completed',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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
