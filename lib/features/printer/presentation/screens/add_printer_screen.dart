// lib/features/printer/presentation/screens/add_printer_screen.dart

import 'dart:async';
import 'dart:io';
import 'package:blue_thermal_printer/blue_thermal_printer.dart' as bt;
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as fbs;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../domain/entities/printer_entity.dart';
import '../providers/printer_provider.dart';

class AddPrinterScreen extends ConsumerStatefulWidget {
  const AddPrinterScreen({super.key, this.printer});

  final PrinterEntity? printer;

  @override
  ConsumerState<AddPrinterScreen> createState() => _AddPrinterScreenState();
}

class _AddPrinterScreenState extends ConsumerState<AddPrinterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controller inputs
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _portController = TextEditingController(text: '9100');

  // Config inputs
  int _paperWidth = 80; // 58 or 80 mm
  bool _isDefault = false;

  // Bluetooth Scanning
  List<dynamic> _pairedDevices = [];
  final List<dynamic> _discoveredDevices = [];
  bool _isScanning = false;
  StreamSubscription<fbs.BluetoothDiscoveryResult>? _discoverySubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (widget.printer != null) {
      final p = widget.printer!;
      _nameController.text = p.name;
      _isDefault = p.isDefault;
      _paperWidth = p.paperWidth;

      if (p.type == PrinterType.wifi) {
        _tabController.index = 1;
        final parts = p.address.split(':');
        _addressController.text = parts[0];
        if (parts.length > 1) {
          _portController.text = parts[1];
        }
      } else {
        _tabController.index = 0;
        _addressController.text = p.address;
      }
    }

    _checkPermissionsAndLoadPaired();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _portController.dispose();
    _stopScan();
    super.dispose();
  }

  // ── Bluetooth Logic ────────────────────────────────────────────────────────

  Future<void> _checkPermissionsAndLoadPaired() async {
    if (!Platform.isAndroid) return;

    // Request Android bluetooth & location permissions
    final scanStatus = await Permission.bluetoothScan.status;
    final connectStatus = await Permission.bluetoothConnect.status;
    final locationStatus = await Permission.location.status;

    if (!scanStatus.isGranted || !connectStatus.isGranted || !locationStatus.isGranted) {
      final results = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      if (results[Permission.bluetoothConnect] != PermissionStatus.granted) {
        _showPermissionDeniedDialog();
        return;
      }
    }

    // Load paired devices
    try {
      final bt.BlueThermalPrinter bluetooth = bt.BlueThermalPrinter.instance;
      final paired = await bluetooth.getBondedDevices();
      setState(() {
        _pairedDevices = paired;
      });
    } catch (_) {
      // Failed to get bonded devices
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Izin Bluetooth Diperlukan'),
        content: const Text(
          'Aplikasi kasir memerlukan izin Bluetooth Connect dan Bluetooth Scan untuk terhubung ke printer thermal Bluetooth. Aktifkan izin ini dari pengaturan sistem perangkat Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  void _startScan() async {
    if (!Platform.isAndroid) return;
    
    // Stop ongoing scan
    _stopScan();

    setState(() {
      _discoveredDevices.clear();
      _isScanning = true;
    });

    try {
      _discoverySubscription = fbs.FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
        final device = result.device;
        if (device.name != null && device.name!.trim().isNotEmpty) {
          final alreadyDiscovered = _discoveredDevices.any((d) => d.address == device.address);
          final alreadyPaired = _pairedDevices.any((d) => d.address == device.address);

          if (!alreadyDiscovered && !alreadyPaired) {
            setState(() {
              _discoveredDevices.add(device);
            });
          }
        }
      });

      // Scan timeout of 15 seconds
      Future.delayed(const Duration(seconds: 15), () {
        if (mounted && _isScanning) {
          _stopScan();
        }
      });
    } catch (error) {
      _stopScan();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memulai pemindaian Bluetooth: $error')),
        );
      }
    }
  }

  void _stopScan() {
    _discoverySubscription?.cancel();
    _discoverySubscription = null;
    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  // ── Print Actions ──────────────────────────────────────────────────────────

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    final printer = _buildPrinterFromInput();
    final notifier = ref.read(printNotifierProvider.notifier);

    final success = await notifier.triggerTestPrint(printer);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test Print berhasil dikirim ke printer!')),
        );
      } else {
        final error = ref.read(printNotifierProvider).maybeWhen(
              error: (err, _) => err.toString(),
              orElse: () => 'Koneksi gagal',
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.danger,
            content: Text('Koneksi printer gagal: $error'),
          ),
        );
      }
    }
  }

  Future<void> _savePrinter() async {
    if (!_formKey.currentState!.validate()) return;

    final printer = _buildPrinterFromInput();
    final maintenance = ref.read(printerMaintenanceNotifierProvider.notifier);

    bool success;
    if (widget.printer != null) {
      // Edit mode
      success = await maintenance.update(printer);
    } else {
      // Create mode
      success = await maintenance.add(
        printer.name,
        printer.type,
        printer.address,
        printer.paperWidth,
        printer.isDefault,
      );
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Printer "${printer.name}" berhasil disimpan')),
        );
        Navigator.pop(context);
      } else {
        final error = ref.read(printerMaintenanceNotifierProvider).maybeWhen(
              error: (err, _) => err.toString(),
              orElse: () => 'Gagal menyimpan printer',
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.danger,
            content: Text(error),
          ),
        );
      }
    }
  }

  PrinterEntity _buildPrinterFromInput() {
    final isWifi = _tabController.index == 1;
    final address = isWifi ? '${_addressController.text.trim()}:${_portController.text.trim()}' : _addressController.text.trim();

    return PrinterEntity(
      id: widget.printer?.id ?? '',
      name: _nameController.text.trim(),
      type: isWifi ? PrinterType.wifi : PrinterType.bluetooth,
      address: address,
      paperWidth: _paperWidth,
      isDefault: _isDefault,
      isActive: widget.printer?.isActive ?? true,
      createdAt: widget.printer?.createdAt ?? DateTime.now(),
    );
  }

  // ── UI Drawing ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final maintenanceState = ref.watch(printerMaintenanceNotifierProvider);
    final printState = ref.watch(printNotifierProvider);
    final theme = Theme.of(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(widget.printer != null ? 'Edit Printer' : 'Tambah Printer Baru'),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.outline,
              tabs: const [
                Tab(icon: Icon(Icons.bluetooth_rounded), text: 'Bluetooth'),
                Tab(icon: Icon(Icons.wifi_rounded), text: 'WiFi / Jaringan'),
              ],
            ),
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBluetoothTab(),
                      _buildWifiTab(),
                    ],
                  ),
                ),
                _buildCommonFieldsAndFooter(theme),
              ],
            ),
          ),
        ),
        if (maintenanceState is AsyncLoading || printState is AsyncLoading)
          const LoadingOverlay(message: 'Harap tunggu...'),
      ],
    );
  }

  Widget _buildBluetoothTab() {
    if (!Platform.isAndroid) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            'Koneksi Bluetooth hanya didukung pada perangkat Android fisik.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.outline),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Paired Devices Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Perangkat Terpasang (Paired)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.outline),
            ),
            if (_isScanning)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              )
            else
              TextButton.icon(
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                icon: const Icon(Icons.search_rounded, size: 16),
                label: const Text('Cari Perangkat', style: TextStyle(fontSize: 12)),
                onPressed: _startScan,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Paired Devices List
        if (_pairedDevices.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text('Tidak ada perangkat terpasang ditemukan.', style: TextStyle(fontSize: 12, color: AppColors.outline)),
          )
        else
          ..._pairedDevices.map((device) => _buildDeviceTile(device, isPaired: true)),

        const Divider(height: 32),

        // Discovered Devices Header
        const Text(
          'Perangkat Sekitar Terdeteksi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.outline),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Discovered Devices List
        if (_discoveredDevices.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              _isScanning ? 'Mencari printer di sekitar...' : 'Gunakan "Cari Perangkat" untuk mendeteksi printer.',
              style: const TextStyle(fontSize: 12, color: AppColors.outline),
            ),
          )
        else
          ..._discoveredDevices.map((device) => _buildDeviceTile(device, isPaired: false)),
      ],
    );
  }

  Widget _buildDeviceTile(dynamic device, {required bool isPaired}) {
    final String name = (device.name as String?) ?? 'Printer Bluetooth';
    final String address = (device.address as String?) ?? '';
    final isSelected = _addressController.text == address;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.outlineVariant,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        leading: Icon(
          Icons.print_rounded,
          color: isSelected ? AppColors.primary : AppColors.outline,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        subtitle: Text(address, style: const TextStyle(fontSize: 11)),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
            : const Icon(Icons.arrow_forward_ios_rounded, size: 12),
        onTap: () {
          setState(() {
            _addressController.text = address;
            if (_nameController.text.trim().isEmpty) {
              _nameController.text = name;
            }
          });
        },
      ),
    );
  }

  Widget _buildWifiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Konfigurasi IP & Port WiFi Printer',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.outline),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Alamat IP Printer*',
              hintText: 'Contoh: 192.168.1.100',
              prefixIcon: Icon(Icons.lan_rounded),
            ),
            keyboardType: TextInputType.values[4], // Text/numbers/dots
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Alamat IP wajib diisi';
              }
              final ipRegExp = RegExp(
                r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
              );
              if (!ipRegExp.hasMatch(val.trim())) {
                return 'Format alamat IP tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _portController,
            decoration: const InputDecoration(
              labelText: 'Port*',
              hintText: 'Default: 9100',
              prefixIcon: Icon(Icons.settings_ethernet_rounded),
            ),
            keyboardType: TextInputType.number,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Port wajib diisi';
              }
              final port = int.tryParse(val.trim());
              if (port == null || port <= 0 || port > 65535) {
                return 'Port harus berupa angka 1 - 65535';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Tip: Hubungkan printer thermal Anda ke ruter WiFi lokal yang sama dengan perangkat kasir Anda.',
            style: TextStyle(fontSize: 11, color: AppColors.outline, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonFieldsAndFooter(ThemeData theme) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Divider(),
            const SizedBox(height: AppSpacing.sm),

            // Form inputs
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama / Label Printer*',
                hintText: 'Contoh: Printer Kasir Depan',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Nama printer wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Address validator placeholder for Bluetooth validation
            if (_tabController.index == 0)
              TextFormField(
                controller: _addressController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Alamat MAC Bluetooth*',
                  hintText: 'Pilih perangkat di atas...',
                  prefixIcon: Icon(Icons.tag_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Pilih perangkat Bluetooth di atas';
                  }
                  final macRegExp = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
                  if (!macRegExp.hasMatch(val.trim())) {
                    return 'Alamat MAC tidak valid';
                  }
                  return null;
                },
              ),

            const SizedBox(height: AppSpacing.md),

            // Paper Width Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Lebar Kertas Struk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ToggleButtons(
                  isSelected: [_paperWidth == 58, _paperWidth == 80],
                  onPressed: (index) {
                    setState(() {
                      _paperWidth = index == 0 ? 58 : 80;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.white,
                  fillColor: AppColors.primary,
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('58 mm')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('80 mm')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Set Default Checkbox
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _isDefault,
              onChanged: (val) {
                setState(() {
                  _isDefault = val ?? false;
                });
              },
              title: const Text('Jadikan sebagai printer default', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: const Text('Struk belanja akan langsung diarahkan ke printer ini.', style: TextStyle(fontSize: 11)),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),

            // Footer Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.print_rounded),
                    label: const Text('Test Print'),
                    onPressed: _testConnection,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Simpan'),
                    onPressed: _savePrinter,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
