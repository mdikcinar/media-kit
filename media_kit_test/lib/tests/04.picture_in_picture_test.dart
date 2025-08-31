/// This file is a part of media_kit (https://github.com/media-kit/media-kit).
///
/// Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:media_kit_test/common/sources/sources.dart';

/// Picture in Picture Test Screen
///
/// Bu test ekranı Picture in Picture (PiP) özelliğini test eder.
/// iOS 14.0+ ve Android API 26+ gerektirir.
class PictureInPictureTestScreen extends StatefulWidget {
  const PictureInPictureTestScreen({Key? key}) : super(key: key);

  @override
  State<PictureInPictureTestScreen> createState() => _PictureInPictureTestScreenState();
}

class _PictureInPictureTestScreenState extends State<PictureInPictureTestScreen> {
  late final Player player = Player();
  late final VideoController controller = VideoController(player);
  final GlobalKey<VideoState> _videoKey = GlobalKey<VideoState>();

  // PiP state management
  bool _isInPiP = false;
  bool _isPiPSupported = false;
  String _pipStatus = 'Checking PiP support...';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _checkPiPSupport();
  }

  void _initializePlayer() async {
    // Test videosu yükleniyor
    await player.open(Media(sources[0]));
  }

  void _checkPiPSupport() async {
    // PiP desteğini kontrol et
    try {
      final videoState = _videoKey.currentState;
      if (videoState != null) {
        final isSupported = await videoState.isPictureInPictureSupported();
        setState(() {
          _isPiPSupported = isSupported;
          _pipStatus = isSupported ? 'Picture in Picture supported ✅' : 'Picture in Picture not supported ❌';
        });
      } else {
        setState(() {
          _pipStatus = 'Video not ready yet...';
        });
      }
    } catch (e) {
      setState(() {
        _pipStatus = 'Error checking PiP support: $e';
      });
    }
  }

  void _enterPiP() async {
    try {
      final videoState = _videoKey.currentState;
      if (videoState != null) {
        final success = await videoState.enterPictureInPicture();
        setState(() {
          _pipStatus = success ? 'Entered Picture in Picture mode ✅' : 'Failed to enter Picture in Picture mode ❌';
        });
        if (success) {
          _updatePiPStatus();
        }
      }
    } catch (e) {
      setState(() {
        _pipStatus = 'Error entering PiP: $e';
      });
    }
  }

  void _exitPiP() async {
    try {
      final videoState = _videoKey.currentState;
      if (videoState != null) {
        final success = await videoState.exitPictureInPicture();
        setState(() {
          _pipStatus = success ? 'Exited Picture in Picture mode ✅' : 'Failed to exit Picture in Picture mode ❌';
        });
        if (success) {
          _updatePiPStatus();
        }
      }
    } catch (e) {
      setState(() {
        _pipStatus = 'Error exiting PiP: $e';
      });
    }
  }

  void _updatePiPStatus() async {
    try {
      final videoState = _videoKey.currentState;
      if (videoState != null) {
        final isInPiP = await videoState.isInPictureInPictureMode();
        setState(() {
          _isInPiP = isInPiP;
        });
      }
    } catch (e) {
      debugPrint('Error checking PiP status: $e');
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picture in Picture Test'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Video Player with PiP enabled
          AspectRatio(
            aspectRatio: 16.0 / 9.0,
            child: Card(
              margin: const EdgeInsets.all(16.0),
              clipBehavior: Clip.antiAlias,
              child: Video(
                key: _videoKey,
                controller: controller,
                // PiP özelliği burada aktif ediliyor!
                enablePictureInPicture: true,
                // PiP callback'leri
                onEnterPictureInPicture: () {
                  setState(() {
                    _isInPiP = true;
                    _pipStatus = 'Entered Picture in Picture mode via callback ✅';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Entered Picture in Picture mode!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                onExitPictureInPicture: () {
                  setState(() {
                    _isInPiP = false;
                    _pipStatus = 'Exited Picture in Picture mode via callback ✅';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Exited Picture in Picture mode!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                // Opsiyonel: Arkaplan moduna geçince pause etme
                pauseUponEnteringBackgroundMode: true,
                resumeUponEnteringForegroundMode: false,
                // Video kontrolcüleri
                controls: AdaptiveVideoControls,
              ),
            ),
          ),

          // Status ve Controls
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Card
                  Card(
                    color: _isPiPSupported ? Colors.green.shade50 : Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            _isPiPSupported ? Icons.picture_in_picture : Icons.error_outline,
                            size: 48,
                            color: _isPiPSupported ? Colors.green : Colors.red,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'PiP Status',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _pipStatus,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          if (_isInPiP) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Currently in PiP Mode',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Control Buttons
                  ElevatedButton.icon(
                    onPressed: _isPiPSupported && !_isInPiP ? _enterPiP : null,
                    icon: const Icon(Icons.picture_in_picture_alt),
                    label: const Text('Enter Picture in Picture'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 8),

                  ElevatedButton.icon(
                    onPressed: _isPiPSupported && _isInPiP ? _exitPiP : null,
                    icon: const Icon(Icons.fullscreen_exit),
                    label: const Text('Exit Picture in Picture'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 8),

                  ElevatedButton.icon(
                    onPressed: _checkPiPSupport,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Check PiP Support'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                  const Spacer(),

                  // Info Card
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Platform Requirements',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '• iOS: Requires iOS 14.0 or later\n'
                            '• Android: Requires API level 26 (Android 8.0) or later\n'
                            '• Web: Depends on browser support (Chrome 69+, Firefox 71+)\n'
                            '• Desktop: Not supported (Windows, Linux, macOS)',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
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
