import 'dart:math';
import 'package:camera/camera.dart';

// --- Helper Fungsi Matematika ---
class SensorRepository {
  /// Menghitung Rata-rata (Mean)
  double calculateMean(List<double> data) {
    if (data.isEmpty) return 0.0;
    return data.reduce((a, b) => a + b) / data.length;
  }
  /// Menghitung Variansi (Variance)
  double calculateVariance(List<double> data) {
    if (data.isEmpty) return 0.0;
    double mean = calculateMean(data);
    double sumSquaredDiff = data.fold(0.0, (sum, element) {
      double diff = element - mean;
      return sum + (diff * diff);
    });
    return sumSquaredDiff / data.length;
  }
  /// Menghitung Magnitude dari 3 sumbu accelerometer
  double calculateMagnitude(double x, double y, double z) {
    return sqrt(x * x + y * y + z * z);
  }

  // --- PPG Logic (Camera) ---
  /// Menghitung intensitas cahaya rata-rata dari frame kamera
  double calculateFrameIntensity(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    int centerX = width ~/ 2;
    int centerY = height ~/ 2;
    int boxSize = 50;

    double totalIntensity = 0.0;
    int pixelCount = 0;

    var yPlane = image.planes[0].bytes;

    for (int y = centerY - (boxSize ~/ 2); y < centerY + (boxSize ~/ 2); y++) {
      for (int x = centerX - (boxSize ~/ 2); x < centerX + (boxSize ~/ 2); x++) {
        if (x >= 0 && x < width && y >= 0 && y < height) {
          int index = y * width + x;
          totalIntensity += yPlane[index];
          pixelCount++;
        }
      }
    }

    if (pixelCount == 0) return 0.0;
    return (totalIntensity / pixelCount) / 255.0;
  }
}