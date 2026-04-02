import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    'Total Plays',
                    Icons.play_arrow,
                    '12,345',
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOverviewCard(
                    'Total Listening Time',
                    Icons.access_time,
                    '48h 32m',
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Top Tracks
            _buildSectionHeader('Top Tracks'),
            const SizedBox(height: 8),
            _buildTopTracksList(),

            const SizedBox(height: 24),

            // Listening Stats
            _buildSectionHeader('Listening Statistics'),
            const SizedBox(height: 8),
            _buildListeningStats(),

            const SizedBox(height: 24),

            // Genre Distribution
            _buildSectionHeader('Genre Distribution'),
            const SizedBox(height: 8),
            _buildGenreChart(),

            const SizedBox(height: 24),

            // Time Distribution
            _buildSectionHeader('Time Distribution'),
            const SizedBox(height: 8),
            _buildTimeChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Icon(
            Icons.analytics,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
      String title, IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 32,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopTracksList() {
    final topTracks = [
      {
        'title': 'Bohemian Rhapsody',
        'artist': 'Queen',
        'plays': 1234,
        'duration': '5:55'
      },
      {
        'title': 'Stairway to Heaven',
        'artist': 'Led Zeppelin',
        'plays': 987,
        'duration': '8:02'
      },
      {
        'title': 'Hotel California',
        'artist': 'Eagles',
        'plays': 856,
        'duration': '3:31'
      },
      {
        'title': 'Sweet Child O\' Mine',
        'artist': 'Guns N\' Roses',
        'plays': 743,
        'duration': '5:44'
      },
      {
        'title': 'Don\'t Stop Believin\'',
        'artist': 'Journey',
        'plays': 654,
        'duration': '4:12'
      },
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topTracks.length,
            itemBuilder: (context, index) {
              final track = topTracks[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  track['title']?.toString() ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  track['artist']?.toString() ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                trailing: Text(
                  '${track['plays'] ?? 0} plays',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListeningStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Average',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Songs per Day', '24'),
                ),
                Expanded(
                  child: _buildStatItem('Hours per Day', '3.2'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Weekly Average',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Songs per Week', '168'),
                ),
                Expanded(
                  child: _buildStatItem('Hours per Week', '22.4'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Monthly Average',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Songs per Month', '730'),
                ),
                Expanded(
                  child: _buildStatItem('Hours per Month', '97.1'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChart() {
    final genres = {
      'Rock': 35,
      'Pop': 28,
      'Electronic': 15,
      'Classical': 12,
      'Jazz': 8,
      'Hip-Hop': 7,
      'Country': 5,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genre Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: genres.entries.map((entry) {
                  return Chip(
                    label: Text(entry.key),
                    backgroundColor: _getGenreColor(entry.key),
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGenreColor(String genre) {
    switch (genre) {
      case 'Rock':
        return Colors.red;
      case 'Pop':
        return Colors.purple;
      case 'Electronic':
        return Colors.blue;
      case 'Classical':
        return Colors.brown;
      case 'Jazz':
        return Colors.orange;
      case 'Hip-Hop':
        return Colors.green;
      case 'Country':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTimeChart() {
    final timeData = [
      {'period': 'Morning', 'hours': 2.5, 'percentage': 15},
      {'period': 'Afternoon', 'hours': 4.2, 'percentage': 25},
      {'period': 'Evening', 'hours': 3.8, 'percentage': 22},
      {'period': 'Night', 'hours': 7.5, 'percentage': 38},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Listening Pattern',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Column(
                children: timeData.map((data) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data['period']?.toString() ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '${data['percentage']}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: (data['percentage'] as int) / 100,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 4,
                              color: Colors.white,
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
      ),
    );
  }
}
