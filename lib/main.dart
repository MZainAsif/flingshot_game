import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

void main() {
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Scene scene = Scene();
  bool ready = false;

  @override
  void initState() {
    super.initState();
    _setupScene();
  }

  Future<void> _setupScene() async {
    // Initialize Flutter Scene static resources (shaders etc.)
    await Scene.initializeStaticResources();

    // Ground plane (PlaneGeometry uses named width/depth, not Vector3)
    final ground = Node(
      mesh: Mesh(
        PlaneGeometry(width: 20, depth: 20),
        PhysicallyBasedMaterial()
          ..baseColorFactor = vm.Vector4(0.35, 0.55, 0.25, 1.0),
      ),
    );
    ground.position = vm.Vector3(0, 0, 0);
    scene.add(ground);

    // Colorful blocks (like the target tower)
    final colors = [
      vm.Vector4(0.9, 0.2, 0.2, 1.0), // red
      vm.Vector4(0.2, 0.6, 0.9, 1.0), // blue
      vm.Vector4(0.95, 0.75, 0.1, 1.0), // yellow
      vm.Vector4(0.3, 0.8, 0.3, 1.0), // green
      vm.Vector4(0.9, 0.4, 0.1, 1.0), // orange
    ];

    // Simple pyramid of blocks
    int colorIndex = 0;
    for (int row = 0; row < 4; row++) {
      final count = 4 - row;
      for (int i = 0; i < count; i++) {
        final block = Node(
          mesh: Mesh(
            CuboidGeometry(vm.Vector3(0.9, 0.9, 0.9)),
            PhysicallyBasedMaterial()
              ..baseColorFactor = colors[colorIndex % colors.length],
          ),
        );
        final x = (i - (count - 1) / 2) * 1.05;
        final y = 0.45 + row * 1.0;
        block.position = vm.Vector3(x, y, 0);
        scene.add(block);
        colorIndex++;
      }
    }

    // Placeholder ball
    final ball = Node(
      mesh: Mesh(
        SphereGeometry(radius: 0.35),
        PhysicallyBasedMaterial()
          ..baseColorFactor = vm.Vector4(0.95, 0.95, 0.95, 1.0)
          ..metallicFactor = 0.3
          ..roughnessFactor = 0.4,
      ),
    );
    ball.position = vm.Vector3(-4.5, 0.5, 0);
    scene.add(ball);

    if (mounted) {
      setState(() => ready = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 3D Scene
          if (ready)
            SceneView(
              scene,
              camera: PerspectiveCamera(
                position: vm.Vector3(0, 4, 10),
                target: vm.Vector3(0, 1.5, 0),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),

          // Simple HUD
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FlingShot',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Basic 3D Scene • Flutter Scene',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Next: Physics + Aim & Fling',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
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
