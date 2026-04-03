import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/analytics_provider.dart';
import '../../data/models/track_model.dart';
import '../../core/constants/app_spacing.dart';

class RecapScreen extends StatefulWidget {
  const RecapScreen({super.key});

  @override
  State<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends State<RecapScreen> {
  String _selectedPeriod = 'year';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Recap',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _shareRecap();
            },
            icon: const Icon(Icons.share),
            tooltip: 'Share recap',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildRecapContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Period',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildPeriodButton('Year', 'year'),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildPeriodButton('Month', 'month'),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildPeriodButton('Week', 'week'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = value == _selectedPeriod;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = value;
        });
        _loadRecapData();
      },
      child: Container(
        padding: AppSpacing.verticalMD,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRecapContent() {
    return Consumer<AnalyticsProvider>(
      builder: (context, analyticsProvider, child) {
        return SingleChildScrollView(
          padding: AppSpacing.paddingMD,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopStatsCard(analyticsProvider),
              SizedBox(height: AppSpacing.xl),
              _buildTopArtistsCard(analyticsProvider),
              SizedBox(height: AppSpacing.xl),
              _buildTopTracksCard(analyticsProvider),
              SizedBox(height: AppSpacing.xl),
              _buildListeningHabitsCard(analyticsProvider),
              SizedBox(height: AppSpacing.xl),
              _buildDiscoveriesCard(analyticsProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopStatsCard(AnalyticsProvider provider) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Year in Music',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      '${provider.totalPlays} total plays',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      '${_formatDuration(provider.totalListeningTime)} total listening time',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopArtistsCard(AnalyticsProvider provider) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Artists',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: AppSpacing.md),
          Column(
            children: provider.topArtists
                .take(5)
                .toList()
                .asMap()
                .entries
                .map((entry) {
              return _buildArtistItem(entry.key + 1, entry.value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistItem(int rank, artist) {
    return Padding(
      padding: AppSpacing.verticalSM,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              '$rank',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  '${artist.playcount} plays • ${artist.trackcount} tracks',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTracksCard(AnalyticsProvider provider) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Tracks',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: AppSpacing.md),
          Column(
            children: provider.topTracks
                .take(5)
                .toList()
                .asMap()
                .entries
                .map((entry) {
              return _buildTrackItem(entry.key + 1, entry.value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackItem(int rank, track) {
    return Padding(
      padding: AppSpacing.verticalSM,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              '$rank',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  track.artists.isNotEmpty
                      ? track.artists.first.name
                      : 'Unknown Artist',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  '${track.playcount} plays • ${_formatDuration(track.playduration)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListeningHabitsCard(AnalyticsProvider provider) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Listening Habits',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: AppSpacing.md),
          _buildHabitItem(
              'Most Active Day', provider.mostActiveDay, Icons.calendar_today),
          _buildHabitItem(
              'Peak Hour', '${provider.peakHour}:00', Icons.schedule),
          _buildHabitItem(
              'Favorite Genre', provider.favoriteGenre, Icons.category),
          _buildHabitItem('Average Session',
              '${provider.averageSessionLength} min', Icons.timer),
        ],
      ),
    );
  }

  Widget _buildHabitItem(String label, String value, IconData icon) {
    return Padding(
      padding: AppSpacing.verticalSM,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveriesCard(AnalyticsProvider provider) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Discoveries',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            '${provider.uniqueTracksPlayed} new artists discovered',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          SizedBox(height: AppSpacing.md),
          Column(
            children: provider.newDiscoveries.take(3).map((track) {
              return _buildDiscoveryItem(track);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryItem(TrackModel track) {
    return Padding(
      padding: AppSpacing.verticalSM,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              image: DecorationImage(
                image: NetworkImage(track.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  track.artists.isNotEmpty
                      ? track.artists.first.name
                      : 'Unknown Artist',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    }
    return '${remainingMinutes}m';
  }

  void _loadRecapData() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _shareRecap() {
    // Share recap functionality
  }
}
