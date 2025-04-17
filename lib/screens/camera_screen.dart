import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'skin_analysis_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraPermissionGranted = false;
  bool _isCaptureInProgress = false;
  bool _flashOn = false;
  int _selectedCameraIndex = 0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    
    // App state changed before we got the chance to initialize the camera
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }
  
  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    
    setState(() {
      _isCameraPermissionGranted = status.isGranted;
    });
    
    if (status.isGranted) {
      _initializeCamera();
    }
  }
  
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No cameras found'))
        );
        return;
      }
      
      await _initializeCameraController(_cameras[_selectedCameraIndex]);
    } catch (e) {
      print('Error initializing camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing camera: $e'))
      );
    }
  }
  
  Future<void> _initializeCameraController(CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    
    _controller = cameraController;
    
    try {
      await cameraController.initialize();
      await cameraController.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
      
      setState(() {});
    } catch (e) {
      print('Error initializing camera controller: $e');
    }
  }
  
  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    setState(() {
      _flashOn = !_flashOn;
    });
    
    await _controller!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
  }
  
  Future<void> _switchCamera() async {
    if (_cameras.isEmpty || _controller == null) return;
    
    final newIndex = (_selectedCameraIndex + 1) % _cameras.length;
    
    setState(() {
      _selectedCameraIndex = newIndex;
      _isCaptureInProgress = true; // Prevent multiple taps while switching
    });
    
    await _controller!.dispose();
    await _initializeCameraController(_cameras[newIndex]);
    
    setState(() {
      _isCaptureInProgress = false;
    });
  }
  
  Future<void> _takePhoto(BuildContext context) async {
    if (_controller == null || !_controller!.value.isInitialized || _isCaptureInProgress) {
      return;
    }
    
    setState(() {
      _isCaptureInProgress = true;
    });
    
    try {
      final XFile photo = await _controller!.takePicture();
      final File photoFile = File(photo.path);
      
      setState(() {
        _isCaptureInProgress = false;
      });
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SkinAnalysisScreen(capturedImage: photoFile),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isCaptureInProgress = false;
      });
      print('Error taking photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: $e'))
      );
    }
  }
  
  Future<void> _pickImageFromGallery(BuildContext context) async {
    final PermissionStatus status = await Permission.photos.request();
    
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission to access gallery denied'))
      );
      return;
    }
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final File imageFile = File(image.path);
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SkinAnalysisScreen(capturedImage: imageFile),
            ),
          );
        }
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image from gallery: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraPermissionGranted) {
      return _buildPermissionDeniedScreen();
    }
    
    if (_controller == null || !_controller!.value.isInitialized) {
      return _buildLoadingScreen();
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize!.height,
                height: _controller!.value.previewSize!.width,
                child: CameraPreview(_controller!),
              ),
            ),
          ),
          
          // Camera UI overlay
          SafeArea(
            child: Column(
              children: [
                // Top bar with back button and settings
                _buildTopBar(context),
                
                Spacer(),
                
                // Face guide overlay
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
                
                Spacer(),
                
                // Bottom camera controls
                _buildCameraControls(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPermissionDeniedScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_photography,
              color: Colors.white,
              size: 70,
            ),
            SizedBox(height: 20),
            Text(
              'Camera permission required',
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Please grant camera permission to analyze your skin',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _requestCameraPermission(),
              child: Text('Grant Permission'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Go Back', style: TextStyle(color: Colors.white70)),
            )
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
  
  // Top bar with back button and settings
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
            ),
          ),
          
          // Flash toggle
          GestureDetector(
            onTap: _toggleFlash,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _flashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Bottom camera controls
  Widget _buildCameraControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button
          GestureDetector(
            onTap: () => _pickImageFromGallery(context),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.photo_library, color: Colors.white, size: 28),
            ),
          ),
          
          // Capture button
          GestureDetector(
            onTap: () => _takePhoto(context),
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Center(
                child: Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    color: _isCaptureInProgress ? Colors.grey : Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          
          // Switch camera button
          GestureDetector(
            onTap: _switchCamera,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.flip_camera_ios, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
} 