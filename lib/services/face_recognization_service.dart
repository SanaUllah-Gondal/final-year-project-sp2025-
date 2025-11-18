import 'dart:io';
import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:get/get.dart';

class FacialFeature {
  final String name;
  final List<Point<double>> points;
  final Point<double>? centerPoint;

  FacialFeature({
    required this.name,
    required this.points,
    this.centerPoint,
  });
}

class FaceAnalysisResult {
  final Face face;
  final List<double> embedding;
  final Map<String, FacialFeature> features;
  final Map<String, double> expressions;

  FaceAnalysisResult({
    required this.face,
    required this.embedding,
    required this.features,
    required this.expressions,
  });
}

class FaceRecognitionService extends GetxService {
  late FaceDetector faceDetector;

  final RxBool isServiceReady = true.obs; // Always ready since we're using ML Kit only
  final RxString statusMessage = 'Face detection ready'.obs;

  @override
  void onInit() {
    super.onInit();
    initializeFaceDetection();
  }

  Future<void> initializeFaceDetection() async {
    try {
      final options = FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableContours: true,
        enableClassification: true,
        enableTracking: true,
        minFaceSize: 0.15,
      );
      faceDetector = FaceDetector(options: options);

      statusMessage.value = 'Face detection service ready';
      print('Face detection service initialized successfully');

    } catch (e) {
      statusMessage.value = 'Failed to initialize face detection: $e';
      print('Face detection initialization error: $e');
    }
  }

  Future<List<FaceAnalysisResult>> analyzeFaces(File imageFile) async {
    try {
      final faces = await detectFaces(imageFile);
      final results = <FaceAnalysisResult>[];

      for (final face in faces) {
        // Generate a basic embedding based on facial features (not from a model)
        final embedding = _generateBasicEmbedding(face);
        final features = extractFacialFeatures(face);
        final expressions = analyzeFacialExpressions(face);

        final result = FaceAnalysisResult(
          face: face,
          embedding: embedding,
          features: features,
          expressions: expressions,
        );

        results.add(result);
      }

      return results;
    } catch (e) {
      print('Face analysis failed: $e');
      return [];
    }
  }

  Future<List<Face>> detectFaces(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final faces = await faceDetector.processImage(inputImage);
      print('Detected ${faces.length} faces');
      return faces;
    } catch (e) {
      print('Face detection failed: $e');
      return [];
    }
  }

  List<double> _generateBasicEmbedding(Face face) {
    // Create a simple embedding based on face geometry and features
    final embedding = List<double>.filled(128, 0.0);

    // Use face bounding box and landmarks to create a unique signature
    final rect = face.boundingBox;

    // Basic face geometry features
    embedding[0] = rect.width / 1000.0;   // Normalized width
    embedding[1] = rect.height / 1000.0;  // Normalized height
    embedding[2] = rect.center.dx / 1000.0; // Normalized center X
    embedding[3] = rect.center.dy / 1000.0; // Normalized center Y

    // Use landmarks if available
    final landmarks = face.landmarks;
    if (landmarks != null) {
      int index = 4;
      for (final landmark in landmarks.values) {
        if (landmark != null && index < embedding.length - 1) {
          embedding[index] = landmark.position.x / 1000.0;
          embedding[index + 1] = landmark.position.y / 1000.0;
          index += 2;
        }
        if (index >= embedding.length) break;
      }
    }

    // Add expression probabilities
    if (face.smilingProbability != null && 10 < embedding.length) {
      embedding[10] = face.smilingProbability!;
    }
    if (face.leftEyeOpenProbability != null && 11 < embedding.length) {
      embedding[11] = face.leftEyeOpenProbability!;
    }
    if (face.rightEyeOpenProbability != null && 12 < embedding.length) {
      embedding[12] = face.rightEyeOpenProbability!;
    }

    return _normalizeEmbedding(embedding);
  }

  Map<String, FacialFeature> extractFacialFeatures(Face face) {
    final features = <String, FacialFeature>{};

    // Extract landmarks
    final landmarksMap = face.landmarks;
    if (landmarksMap != null && landmarksMap.isNotEmpty) {
      for (final entry in landmarksMap.entries) {
        final key = entry.key;
        final landmark = entry.value;
        if (landmark == null) continue;

        final points = <Point<double>>[
          Point(landmark.position.x.toDouble(), landmark.position.y.toDouble())
        ];

        final name = landmarkTypeToString(key);
        features[name] = FacialFeature(
          name: name,
          points: points,
          centerPoint: Point(landmark.position.x.toDouble(), landmark.position.y.toDouble()),
        );
      }
    }

    // Extract contours
    final contoursMap = face.contours;
    if (contoursMap != null && contoursMap.isNotEmpty) {
      for (final entry in contoursMap.entries) {
        final key = entry.key;
        final contour = entry.value;
        if (contour == null) continue;

        final points = contour.points
            .map((point) => Point(point.x.toDouble(), point.y.toDouble()))
            .toList();

        final name = contourTypeToString(key);
        features[name] = FacialFeature(
          name: name,
          points: points,
        );
      }
    }

    return features;
  }

  Map<String, double> analyzeFacialExpressions(Face face) {
    final expressions = <String, double>{};

    // Smile probability
    if (face.smilingProbability != null) {
      expressions['smiling'] = face.smilingProbability!;
    }

    // Eye open probabilities
    if (face.leftEyeOpenProbability != null) {
      expressions['left_eye_open'] = face.leftEyeOpenProbability!;
    }
    if (face.rightEyeOpenProbability != null) {
      expressions['right_eye_open'] = face.rightEyeOpenProbability!;
    }

    // Additional expression analysis based on landmark positions
    expressions.addAll(_analyzeFacialGestures(face));

    return expressions;
  }

  Map<String, double> _analyzeFacialGestures(Face face) {
    final gestures = <String, double>{};

    try {
      // Analyze mouth openness
      final mouthOpenness = _calculateMouthOpenness(face);
      gestures['mouth_open'] = mouthOpenness;

      // Analyze eyebrow raise
      final eyebrowRaise = _calculateEyebrowRaise(face);
      gestures['eyebrow_raised'] = eyebrowRaise;

      // Analyze head tilt
      final headTilt = _calculateHeadTilt(face);
      gestures['head_tilt'] = headTilt;

      // Analyze smile intensity
      final smileIntensity = _calculateSmileIntensity(face);
      gestures['smile_intensity'] = smileIntensity;

    } catch (e) {
      // If landmark analysis fails, use default values
      gestures['mouth_open'] = 0.0;
      gestures['eyebrow_raised'] = 0.0;
      gestures['head_tilt'] = 0.5;
      gestures['smile_intensity'] = 0.0;
    }

    return gestures;
  }

  double _calculateMouthOpenness(Face face) {
    final landmarksMap = face.landmarks;
    if (landmarksMap == null) return 0.0;

    final bottom = landmarksMap[FaceLandmarkType.bottomMouth];
    final left = landmarksMap[FaceLandmarkType.leftMouth];
    final right = landmarksMap[FaceLandmarkType.rightMouth];

    if (bottom == null || left == null || right == null) return 0.0;

    final mouthCenterY = (left.position.y + right.position.y) / 2;
    final mouthHeight = (bottom.position.y - mouthCenterY).abs();
    final faceHeight = face.boundingBox.height > 0 ? face.boundingBox.height : 1.0;

    final openness = (mouthHeight / faceHeight);
    return openness.clamp(0.0, 1.0).toDouble();
  }

  double _calculateEyebrowRaise(Face face) {
    final lm = face.landmarks;
    if (lm == null) return 0.0;

    final leftEye = lm[FaceLandmarkType.leftEye];
    final rightEye = lm[FaceLandmarkType.rightEye];
    final leftCheek = lm[FaceLandmarkType.leftCheek];
    final rightCheek = lm[FaceLandmarkType.rightCheek];
    final noseBase = lm[FaceLandmarkType.noseBase];

    if (leftEye == null || rightEye == null || leftCheek == null || rightCheek == null || noseBase == null) {
      return 0.0;
    }

    final leftEyebrowY = leftEye.position.y - (leftEye.position.y - leftCheek.position.y) * 0.3;
    final rightEyebrowY = rightEye.position.y - (rightEye.position.y - rightCheek.position.y) * 0.3;

    final leftDistance = (leftEyebrowY - leftEye.position.y).abs();
    final rightDistance = (rightEyebrowY - rightEye.position.y).abs();
    final averageDistance = (leftDistance + rightDistance) / 2.0;

    final normalized = (averageDistance / 50.0).clamp(0.0, 1.0);
    return normalized.toDouble();
  }

  double _calculateHeadTilt(Face face) {
    final lm = face.landmarks;
    if (lm == null) return 0.0;

    final leftEye = lm[FaceLandmarkType.leftEye];
    final rightEye = lm[FaceLandmarkType.rightEye];

    if (leftEye == null || rightEye == null) return 0.0;

    final deltaY = rightEye.position.y - leftEye.position.y;
    final deltaX = rightEye.position.x - leftEye.position.x;

    if (deltaX == 0) return 0.5;

    final angle = atan2(deltaY, deltaX) * (180 / pi);

    final normalized = ((angle.abs() / 45.0).clamp(0.0, 1.0) * 0.5) + (angle > 0 ? 0.5 : 0.0);
    return normalized;
  }

  double _calculateSmileIntensity(Face face) {
    final lm = face.landmarks;
    if (lm == null) return 0.0;

    final leftMouth = lm[FaceLandmarkType.leftMouth];
    final rightMouth = lm[FaceLandmarkType.rightMouth];
    final bottomMouth = lm[FaceLandmarkType.bottomMouth];

    if (leftMouth == null || rightMouth == null || bottomMouth == null) return 0.0;

    final mouthWidth = (rightMouth.position.x - leftMouth.position.x).abs();
    final faceWidth = face.boundingBox.width > 0 ? face.boundingBox.width : 1.0;

    final widthRatio = (mouthWidth / faceWidth).clamp(0.0, 1.0);

    final mouthCenterY = (leftMouth.position.y + rightMouth.position.y) / 2;
    final curvature = (mouthCenterY - bottomMouth.position.y).abs();
    final normalizedCurvature = (curvature / face.boundingBox.height).clamp(0.0, 1.0);

    return (widthRatio * 0.6 + normalizedCurvature * 0.4).clamp(0.0, 1.0);
  }

  List<double> _normalizeEmbedding(List<double> embedding) {
    double sum = 0.0;
    for (final value in embedding) {
      sum += value * value;
    }
    final norm = sqrt(sum);
    if (norm == 0.0) return embedding;
    return embedding.map((value) => value / norm).toList();
  }

  // Face tracking methods
  Future<List<FaceAnalysisResult>> processVideoFrame(InputImage image) async {
    try {
      final faces = await faceDetector.processImage(image);
      final results = <FaceAnalysisResult>[];

      for (final face in faces) {
        final trackingId = face.trackingId ?? _nextTrackingId++;

        final embedding = _generateBasicEmbedding(face);
        final features = extractFacialFeatures(face);
        final expressions = analyzeFacialExpressions(face);

        final result = FaceAnalysisResult(
          face: face,
          embedding: embedding,
          features: features,
          expressions: expressions,
        );

        _trackedFaces[trackingId] = result;
        results.add(result);
      }

      return results;
    } catch (e) {
      print('Video frame processing failed: $e');
      return [];
    }
  }

  double calculateSimilarity(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) {
      return 0.0;
    }

    double dotProduct = 0.0;
    for (int i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];
    }
    return dotProduct;
  }

  // Utility methods for converting enum to string
  String landmarkTypeToString(FaceLandmarkType type) {
    return type.toString().split('.').last;
  }

  String contourTypeToString(FaceContourType type) {
    return type.toString().split('.').last;
  }

  // Get detailed face information for display/analysis
  Map<String, dynamic> getFaceDetails(FaceAnalysisResult result) {
    return {
      'bounding_box': {
        'left': result.face.boundingBox.left,
        'top': result.face.boundingBox.top,
        'right': result.face.boundingBox.right,
        'bottom': result.face.boundingBox.bottom,
        'width': result.face.boundingBox.width,
        'height': result.face.boundingBox.height,
      },
      'rotation': {
        'y_angle': result.face.headEulerAngleY ?? 0.0,
        'z_angle': result.face.headEulerAngleZ ?? 0.0,
      },
      'tracking_id': result.face.trackingId,
      'landmarks': result.features.map((key, value) => MapEntry(key, {
        'points': value.points.map((point) => {'x': point.x, 'y': point.y}).toList(),
        'center': value.centerPoint != null ? {'x': value.centerPoint!.x, 'y': value.centerPoint!.y} : null,
      })),
      'expressions': result.expressions,
      'contours': result.features.entries
          .where((entry) => entry.key.toLowerCase().contains('contour'))
          .map((entry) => entry.key)
          .toList(),
    };
  }

  // For face tracking across frames
  final Map<int, FaceAnalysisResult> _trackedFaces = {};
  int _nextTrackingId = 1;

  // Get all tracked faces
  Map<int, FaceAnalysisResult> get trackedFaces => Map.from(_trackedFaces);

  // Clear tracked faces
  void clearTrackedFaces() {
    _trackedFaces.clear();
    _nextTrackingId = 1;
  }

  @override
  void onClose() {
    faceDetector.close();
    _trackedFaces.clear();
    super.onClose();
  }
}