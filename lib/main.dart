import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

void main() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER ERROR: ${details.exceptionAsString()}');
  };
  runApp(const FlingShotApp());
}

class FlingShotApp extends StatelessWidget {
  const FlingShotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlingShot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

/// Pure Flutter UI first — proves the app runs without Flutter Scene.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading3d = false;
  String? errorMessage;

  Future<void> _open3d() async {
    setState(() {
      loading3d = true;
      errorMessage = null;
    });

    try {
      await Scene.initializeStaticResources();
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SceneScreen()),
      );
    } catch (e, st) {
      debugPrint('SCENE INIT ERROR: $e\n$st');
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) setState(() => loading3d = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'FlingShot',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Knock Down Blocks',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.orangeAccent.withValues(alpha: 0.9),
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              if (errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent),
                  ),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              FilledButton(
                onPressed: loading3d ? null : _open3d,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: loading3d
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Play 3D Scene',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                'UI loads without Scene. Tap button to init 3D.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// 3D scene — only opened after successful init.
class SceneScreen extends StatefulWidget {
  const SceneScreen({super.key});

  @override
  State<SceneScreen> createState() => _SceneScreenState();
}

class _SceneScreenState extends State<SceneScreen> {
  final Scene scene = Scene();
  bool ready = false;
  String status = 'Building scene...';
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _buildScene();
  }

  Future<void> _buildScene() async {
    try {
      final groundMat = PhysicallyBasedMaterial();
      groundMat.baseColorFactor = vm.Vector4(0.35, 0.55, 0.25, 1.0);

      final ground = Node(
        mesh: Mesh(
          PlaneGeometry(width: 20, depth: 20),
          groundMat,
        ),
      );
      scene.add(ground);

      final colors = [
        vm.Vector4(0.9, 0.2, 0.2, 1.0),
        vm.Vector4(0.2, 0.6, 0.9, 1.0),
        vm.Vector4(0.95, 0.75, 0.1, 1.0),
        vm.Vector4(0.3, 0.8, 0.3, 1.0),
        vm.Vector4(0.9, 0.4, 0.1, 1.0),
      ];

      int colorIndex = 0;
      for (int row = 0; row < 4; row++) {
        final count = 4 - row;
        for (int i = 0; i < count; i++) {
          final mat = PhysicallyBasedMaterial();
          mat.baseColorFactor = colors[colorIndex % colors.length];

          final block = Node(
            mesh: Mesh(
              CuboidGeometry(vm.Vector3(0.9, 0.9, 0.9)),
              mat,
            ),
          );
          final x = (i - (count - 1) / 2) * 1.05;
          final y = 0.45 + row * 1.0;
          block.position = vm.Vector3(x, y, 0);
          scene.add(block);
          colorIndex++;
        }
      }

      final ballMat = PhysicallyBasedMaterial();
      ballMat.baseColorFactor = vm.Vector4(0.95, 0.95, 0.95, 1.0);
      ballMat.metallicFactor = 0.3;
      ballMat.roughnessFactor = 0.4;

      final ball = Node(
        mesh: Mesh(
          SphereGeometry(radius: 0.35),
          ballMat,
        ),
      );
      ball.position = vm.Vector3(-4.5, 0.5, 0);
      scene.add(ball);

      if (mounted) {
        setState(() {
          ready = true;
          status = 'Scene ready';
        });
      }
    } catch (e, st) {
      debugPrint('SCENE BUILD ERROR: $e\n$st');
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          status = 'Failed';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (ready)
            SceneView(
              scene,
              camera: PerspectiveCamera(
                position: vm.Vector3(0, 4, 10),
                target: vm.Vector3(0, 1.5, 0),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Text(
                        status,
                        style: TextStyle(
                          color: errorMessage != null
                              ? Colors.redAccent
                              : Colors.greenAccent,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (!ready && errorMessage == null)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.orangeAccent,
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
