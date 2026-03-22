import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';

class RecapScreen extends StatefulWidget {
  const RecapScreen({super.key});

  @override
  State<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends State<RecapScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = true;
  Map<String, dynamic> _recapData = {};

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _loadRecapData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadRecapData() async {
    // Simulate loading recap data
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _recapData = {
        'totalMinutes': 1847, // 30+ hours
        'totalTracks': 1234,
        'topArtist': 'Queen',
        'topAlbum': 'A Night at the Opera',
        'topTrack': 'Bohemian Rhapsody',
        'favoriteGenre': 'Rock',
        'newDiscoveries': 89,
        'listeningStreak': 15,
        'topGenres': [
          {'name': 'Rock', 'percentage': 35, 'color': Colors.red},
          {'name': 'Pop', 'percentage': 28, 'color': Colors.purple},
          {'name': 'Electronic', 'percentage': 15, 'color': Colors.blue},
          {'name': 'Classical', 'percentage': 12, 'color': Colors.brown},
          {'name': 'Jazz', 'percentage': 10, 'color': Colors.orange},
        ],
        'monthlyListening': [
          {'month': 'Jan', 'hours': 45},
          {'month': 'Feb', 'hours': 52},
          {'month': 'Mar', 'hours': 38},
          {'month': 'Apr', 'hours': 61},
          {'month': 'May', 'hours': 49},
          {'month': 'Jun', 'hours': 73},
          {'month': 'Jul', 'hours': 67},
          {'month': 'Aug', 'hours': 58},
          {'month': 'Sep', 'hours': 71},
          {'month': 'Oct', 'hours': 64},
          {'month': 'Nov', 'hours': 69},
          {'month': 'Dec', 'hours': 82},
        ],
        'dayOfWeekStats': [
          {'day': 'Mon', 'hours': 3.2},
          {'day': 'Tue', 'hours': 4.1},
          {'day': 'Wed', 'hours': 3.8},
          {'day': 'Thu', 'hours': 4.5},
          {'day': 'Fri', 'hours': 5.2},
          {'day': 'Sat', 'hours': 6.1},
          {'day': 'Sun', 'hours': 5.8},
        ],
        'timeOfDayStats': [
          {'period': 'Morning', 'hours': 2.5, 'percentage': 15},
          {'period': 'Afternoon', 'hours': 4.2, 'percentage': 25},
          {'period': 'Evening', 'hours': 3.8, 'percentage': 22},
          {'period': 'Night', 'hours': 7.5, 'percentage': 38},
        ],
      };
      _isLoading = false;
    });
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _isLoading ? _buildLoadingState() : _buildRecapContent(),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.music_note,
                color: Theme.of(context).colorScheme.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Creating Your 2024 Recap',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyzing your listening habits...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecapContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Main Stats
          _buildMainStats(),
          
          // Top Artist/Album/Track
          _buildTopContent(),
          
          // Genre Distribution
          _buildGenreDistribution(),
          
          // Listening Patterns
          _buildListeningPatterns(),
          
          // Monthly Chart
          _buildMonthlyChart(),
          
          // Share Section
          _buildShareSection(),
          
          // Bottom padding
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingXL,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Text(
                    '2024 Recap',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _shareRecap,
                    icon: const Icon(Icons.share, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Your Year in Music',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Discover your listening journey',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainStats() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: AppSpacing.marginLG,
        padding: AppSpacing.paddingLG,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
                Expanded(
                  child: _buildStatCard(
                    'Total Listening',
                    '${(_recapData['totalMinutes'] / 60).toStringAsFixed(1)}h',
                    Icons.access_time,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Tracks Played',
                    '${_recapData['totalTracks']}',
                    Icons.music_note,
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Listening Streak',
                    '${_recapData['listeningStreak']} days',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'New Discoveries',
                    '${_recapData['newDiscoveries']}',
                    Icons.explore,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopContent() {
    return Container(
      margin: AppSpacing.marginLG,
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Favorites',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildTopItem('Top Artist', _recapData['topArtist'], Icons.person, Colors.purple),
          const SizedBox(height: 12),
          _buildTopItem('Top Album', _recapData['topAlbum'], Icons.album, Colors.blue),
          const SizedBox(height: 12),
          _buildTopItem('Top Track', _recapData['topTrack'], Icons.music_note, Colors.red),
          const SizedBox(height: 12),
          _buildTopItem('Favorite Genre', _recapData['favoriteGenre'], Icons.category, Colors.green),
        ],
      ),
    );
  }

  Widget _buildTopItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreDistribution() {
    final genres = List<Map<String, dynamic>>.from(_recapData['topGenres']);
    
    return Container(
      margin: AppSpacing.marginLG,
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Genre Distribution',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Column(
              children: genres.map((genre) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            genre['name'],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${genre['percentage']}%',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: genre['color'],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: genre['percentage'] / 100,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: genre['color'],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListeningPatterns() {
    return Container(
      margin: AppSpacing.marginLG,
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Listening Patterns',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Day of Week
          Text(
            'Day of Week',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List<Map<String, dynamic>>.from(_recapData['dayOfWeekStats'])
                  .map((day) => Column(
                        children: [
                          Container(
                            width: 30,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: day['hours'] / 7.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            day['day'],
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    final monthlyData = List<Map<String, dynamic>>.from(_recapData['monthlyListening']);
    final maxHours = monthlyData.map((m) => m['hours']).reduce((a, b) => a > b ? a : b);
    
    return Container(
      margin: AppSpacing.marginLG,
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Listening',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: monthlyData.map((month) {
                return Column(
                  children: [
                    Container(
                      width: 20,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: month['hours'] / maxHours,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      month['month'],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${month['hours']}h',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareSection() {
    return Container(
      margin: AppSpacing.marginLG,
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.share,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Share Your Recap',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Show your friends what you listened to this year',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareButton('Share Story', Icons.share, Colors.blue),
              _buildShareButton('Copy Link', Icons.link, Colors.green),
              _buildShareButton('Download', Icons.download, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () => _handleShareAction(label),
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _shareRecap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing your recap...')),
    );
  }

  void _handleShareAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action feature coming soon!')),
    );
  }
}
