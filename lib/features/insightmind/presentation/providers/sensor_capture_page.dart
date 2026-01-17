import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Tambahkan Riverpod
import 'package:sensors_plus/sensors_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/repositories/sensor_repository.dart';
import '../../../models/feature_vector.dart';
import '../../domain/predict_risk_ai.dart';
import '../providers/ppg_provider.dart'; // Import Provider

// Ubah ke ConsumerStatefulWidget agar bisa update provider
class SensorCapturePage extends ConsumerStatefulWidget {
  const SensorCapturePage({super.key});

  @override
  ConsumerState<SensorCapturePage> createState() => _SensorCapturePageState();
}

class _SensorCapturePageState extends ConsumerState<SensorCapturePage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isRecording = false;

  // Timer dihapus sesuai permintaan
  // int _timeLeft = 30;
  // Timer? _timer;

  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;

  final List<double> _accelerometerMagnitudes = [];
  final List<double> _ppgIntensities = [];

  StreamSubscription<UserAccelerometerEvent>? _accelSubscription;

  final SensorRepository _sensorRepo = SensorRepository();
  final PredictRiskAI _aiModel = PredictRiskAI();

  Map<String, dynamic>? _predictionResult;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    var status = await Permission.camera.request();
    if (status.isDenied) return;

    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    _selectedCameraIndex = _cameras.indexWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
    );
    if (_selectedCameraIndex == -1) _selectedCameraIndex = 0;

    _initSelectedCamera();
  }

  Future<void> _initSelectedCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    _cameraController = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.medium, // Menggunakan medium agar performa lebih stabil
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  void _switchCamera() {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _initSelectedCamera();
  }

  void _startCapture() async {
    if (!_isCameraInitialized) return;

    setState(() {
      _isRecording = true;
      _predictionResult = null;
      _accelerometerMagnitudes.clear();
      _ppgIntensities.clear();
    });

    if (_cameras[_selectedCameraIndex].lensDirection == CameraLensDirection.back) {
      await _cameraController!.setFlashMode(FlashMode.torch);
    }

    _accelSubscription = userAccelerometerEvents.listen((event) {
      double magnitude = _sensorRepo.calculateMagnitude(event.x, event.y, event.z);
      _accelerometerMagnitudes.add(magnitude);
    });

    await _cameraController!.startImageStream((CameraImage image) {
      double intensity = _sensorRepo.calculateFrameIntensity(image);
      _ppgIntensities.add(intensity);
    });

    // Timer dihapus, capture berjalan sampai user menekan stop
  }

  void _stopCapture() async {
    _accelSubscription?.cancel();

    if (_cameraController != null && _cameraController!.value.isStreamingImages) {
      await _cameraController!.stopImageStream();
      await _cameraController!.setFlashMode(FlashMode.off);
    }

    setState(() => _isRecording = false);
    _processData();
  }

  void _processData() {
    // 1. Hitung Statistik
    double accelVariance = _sensorRepo.calculateVariance(_accelerometerMagnitudes);
    double ppgVariance = _sensorRepo.calculateVariance(_ppgIntensities);

    double accelMean = _accelerometerMagnitudes.isEmpty
        ? 0
        : _accelerometerMagnitudes.reduce((a, b) => a + b) / _accelerometerMagnitudes.length;

    double ppgMean = _ppgIntensities.isEmpty
        ? 0
        : _ppgIntensities.reduce((a, b) => a + b) / _ppgIntensities.length;

    // 2. UPDATE PROVIDER (Menyimpan data ke State Global agar muncul di halaman depan)
    // List _ppgIntensities dikirim sebagai samples
    ref.read(ppgProvider.notifier).updateData(_ppgIntensities, ppgMean, ppgVariance);

    // 3. AI Prediction Logic (Opsional, tetap dibiarkan)
    double dummyScreeningScore = 15.0;
    final features = FeatureVector(
      screeningScore: dummyScreeningScore,
      activityVar: accelVariance,
      ppgVar: ppgVariance,
      activityMean: accelMean,
      ppgMean: ppgMean,
    );

    final result = _aiModel.predict(features);

    setState(() {
      _predictionResult = result;
    });
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Full-screen Camera Background
          Positioned.fill(
            child: _isCameraInitialized
                ? CameraPreview(_cameraController!)
                : const Center(child: CircularProgressIndicator()),
          ),

          // 2. Overlay Bingkai
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.55,
                      width: MediaQuery.of(context).size.width * 0.85,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. UI Header
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Scan Biometrik',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Posisikan wajah atau jari Anda pada area bingkai lalu tekan tombol fingerprint.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          // 4. Garis Bingkai Putih
          Align(
            alignment: Alignment.center,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              width: MediaQuery.of(context).size.width * 0.85,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

          // 5. Controls Bottom (Tanpa Timer Merah)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Switch Camera Button
                _buildSecondaryButton(
                  icon: Icons.flip_camera_ios,
                  onPressed: _switchCamera,
                ),

                // Main Capture Button (Start / Stop)
                GestureDetector(
                  onTap: () {
                    if (_isRecording) {
                      _stopCapture(); // Klik kedua: Stop & Analisis
                    } else {
                      _startCapture(); // Klik pertama: Start
                    }
                  },
                  child: Container(
                    height: 85,
                    width: 85,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.redAccent : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.fingerprint,
                        size: 40,
                        color: _isRecording ? Colors.white : Colors.blueAccent,
                      ),
                    ),
                  ),
                ),

                // Flash Button
                _buildSecondaryButton(
                  icon: Icons.flashlight_on,
                  onPressed: () {
                    if (_cameraController != null) {
                      _cameraController!.setFlashMode(
                        _cameraController!.value.flashMode == FlashMode.torch
                            ? FlashMode.off
                            : FlashMode.torch,
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          if (_predictionResult != null) _buildResultDialog(),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildResultDialog() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text(
                'Hasil Analisis',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 32),
              Text(
                'Risiko: ${_predictionResult!['riskLevel']}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.blueAccent),
              ),
              const SizedBox(height: 8),
              Text(
                'Skor Gabungan: ${_predictionResult!['weightedScore'].toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    setState(() => _predictionResult = null);
                    Navigator.pop(context); // Kembali ke halaman utama setelah hasil
                  },
                  child: const Text('Simpan & Tutup', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}