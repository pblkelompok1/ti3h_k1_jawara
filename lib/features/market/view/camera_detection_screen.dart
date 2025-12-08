import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';
import 'package:ti3h_k1_jawara/core/services/predict_service.dart';
import 'result_screen.dart';

class CameraDetectionScreen extends StatefulWidget {
  const CameraDetectionScreen({super.key});

  @override
  State<CameraDetectionScreen> createState() => _CameraDetectionScreenState();
}

class _CameraDetectionScreenState extends State<CameraDetectionScreen> with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _cameraController!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Gagal inisialisasi kamera: $e");
    }
  }

  Future<void> _takePicture() async {
    if (_isProcessing) return;
    
    try {
      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        return;
      }

      await _initializeControllerFuture;

      setState(() {
        _isProcessing = true;
      });

      final file = await _cameraController!.takePicture();

      if (!mounted) return;

      // PAUSE camera sebelum navigasi untuk stop buffer
      await _cameraController?.pausePreview();

      // Navigate to result screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(imagePath: file.path),
        ),
      );

      // RESUME camera setelah kembali
      if (mounted && _cameraController != null && _cameraController!.value.isInitialized) {
        await _cameraController?.resumePreview();
      }
    } catch (e) {
      debugPrint("Gagal ambil foto: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil foto: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });
    
    final picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null && mounted) {
      // PAUSE camera untuk gallery
      await _cameraController?.pausePreview();

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(imagePath: picked.path),
        ),
      );

      // RESUME camera setelah kembali
      if (mounted && _cameraController != null && _cameraController!.value.isInitialized) {
        await _cameraController?.resumePreview();
      }
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Deteksi Sayur"),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _initializeControllerFuture == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // area kamera
                Expanded(
                  child: FutureBuilder(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          CameraPreview(_cameraController!),
                          Center(
                            child: Container(
                              width: 260,
                              height: 260,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.9),
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: const EdgeInsets.only(top: 16),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                "Arahkan kamera ke sayur yang ingin dideteksi",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // panel bawah tombol kamera dan galeri
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Ambil foto langsung atau pilih gambar dari galeri",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isProcessing ? null : _takePicture,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Ambil Foto",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isProcessing ? null : _pickFromGallery,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: BorderSide(color: primary, width: 1.8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.photo_library_outlined,
                                  color: primary,
                                ),
                                label: Text(
                                  "Dari Galeri",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
