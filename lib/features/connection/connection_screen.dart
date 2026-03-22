import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isConnecting = false;
  bool _isConnected = false;
  String _serverUrl = '';
  String _connectionStatus = 'Disconnected';
  List<DiscoveredServer> _discoveredServers = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _loadSavedConnection();
    _startServerDiscovery();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedConnection() async {
    // Simulate loading saved connection
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _serverUrl = 'http://192.168.1.100:1970';
    });
  }

  Future<void> _startServerDiscovery() async {
    setState(() {
      _isScanning = true;
    });
    
    // Simulate server discovery
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _discoveredServers = [
        DiscoveredServer(
          name: 'SwingMusic Server',
          url: 'http://192.168.1.100:1970',
          version: '2.1.0',
          isActive: true,
        ),
        DiscoveredServer(
          name: 'SwingMusic Desktop',
          url: 'http://192.168.1.101:1970',
          version: '2.0.5',
          isActive: true,
        ),
        DiscoveredServer(
          name: 'SwingMusic Laptop',
          url: 'http://192.168.1.102:1970',
          version: '2.1.0',
          isActive: false,
        ),
      ];
      _isScanning = false;
    });
    
    _pulseController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Connection',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        actions: [
          IconButton(
            onPressed: _refreshServers,
            icon: _isScanning 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh Servers',
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection Status Card
          _buildConnectionStatusCard(),
          
          // Server Discovery
          Expanded(
            child: _buildServerDiscovery(),
          ),
          
          // Manual Connection
          _buildManualConnection(),
        ],
      ),
    );
  }

  Widget _buildConnectionStatusCard() {
    return Container(
      margin: AppSpacing.marginLG,
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isConnected 
              ? [Colors.green, Colors.lightGreen]
              : [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isConnecting ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isConnected ? Icons.cloud_done : Icons.cloud_queue,
                        color: _isConnected ? Colors.green : Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _connectionStatus,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isConnected ? 'Connected to SwingMusic server' : 'Not connected to any server',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isConnected)
                ElevatedButton.icon(
                  onPressed: _disconnect,
                  icon: const Icon(Icons.link_off),
                  label: const Text('Disconnect'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServerDiscovery() {
    return Container(
      margin: AppSpacing.marginLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discovered Servers',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_isScanning)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Scanning for servers...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_discoveredServers.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No servers found',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Make sure SwingMusic is running on your network',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _discoveredServers.length,
                itemBuilder: (context, index) {
                  final server = _discoveredServers[index];
                  return ServerTile(
                    server: server,
                    onConnect: () => _connectToServer(server),
                    onForget: () => _forgetServer(server),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildManualConnection() {
    return Container(
      margin: AppSpacing.marginLG,
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manual Connection',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          TextField(
            decoration: InputDecoration(
              labelText: 'Server URL',
              hintText: 'http://192.168.1.100:1970',
              prefixIcon: const Icon(Icons.link),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            controller: TextEditingController(text: _serverUrl),
            onChanged: (value) {
              _serverUrl = value;
            },
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isConnecting ? null : _connectManually,
                  icon: _isConnecting
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.link),
                  label: Text(_isConnecting ? 'Connecting...' : 'Connect'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _scanQRCode,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan QR'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _connectToServer(DiscoveredServer server) async {
    setState(() {
      _isConnecting = true;
      _connectionStatus = 'Connecting...';
    });
    
    // Simulate connection
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isConnecting = false;
      _isConnected = true;
      _connectionStatus = 'Connected to ${server.name}';
      _serverUrl = server.url;
    });
    
    _pulseController.forward();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${server.name}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _connectManually() async {
    if (_serverUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a server URL')),
      );
      return;
    }
    
    setState(() {
      _isConnecting = true;
      _connectionStatus = 'Connecting...';
    });
    
    // Simulate connection
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isConnecting = false;
      _isConnected = true;
      _connectionStatus = 'Connected manually';
    });
    
    _pulseController.forward();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connected successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _disconnect() {
    setState(() {
      _isConnected = false;
      _connectionStatus = 'Disconnected';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Disconnected from server')),
    );
  }

  void _forgetServer(DiscoveredServer server) {
    setState(() {
      _discoveredServers.remove(server);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Forgot ${server.name}')),
    );
  }

  void _refreshServers() {
    _discoveredServers.clear();
    _startServerDiscovery();
  }

  void _scanQRCode() {
    Navigator.pushNamed(context, '/qr-scanner').then((result) {
      if (result != null && result is String) {
        setState(() {
          _serverUrl = result;
        });
      }
    });
  }
}

class DiscoveredServer {
  final String name;
  final String url;
  final String version;
  final bool isActive;

  DiscoveredServer({
    required this.name,
    required this.url,
    required this.version,
    required this.isActive,
  });
}

class ServerTile extends StatelessWidget {
  final DiscoveredServer server;
  final VoidCallback onConnect;
  final VoidCallback onForget;

  const ServerTile({
    super.key,
    required this.server,
    required this.onConnect,
    required this.onForget,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Server Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: server.isActive 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.dns,
                color: server.isActive ? Colors.green : Colors.grey,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Server Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    server.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    server.url,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'v${server.version}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: server.isActive ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        server.isActive ? 'Active' : 'Inactive',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: server.isActive ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!server.isActive)
                  IconButton(
                    onPressed: null,
                    icon: const Icon(Icons.link_off),
                    tooltip: 'Server is inactive',
                  )
                else
                  IconButton(
                    onPressed: onConnect,
                    icon: const Icon(Icons.link),
                    tooltip: 'Connect',
                  ),
                IconButton(
                  onPressed: onForget,
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'More options',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
