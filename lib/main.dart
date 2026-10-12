import 'dart:math' as math;

import 'package:flutter/material.dart';

const _background = Color(0xFF090A0F);
const _surface = Color(0xFF13151D);
const _muted = Color(0xFF888B9B);
const _lime = Color(0xFFC8FA68);

void main() {
  runApp(const SoundwaveApp());
}

class SoundwaveApp extends StatelessWidget {
  const SoundwaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soundwave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _lime,
          brightness: Brightness.dark,
          surface: _surface,
        ),
        useMaterial3: true,
      ),
      home: const MusicDashboard(),
    );
  }
}

class MusicDashboard extends StatefulWidget {
  const MusicDashboard({super.key});

  @override
  State<MusicDashboard> createState() => _MusicDashboardState();
}

class _MusicDashboardState extends State<MusicDashboard> {
  final _searchController = TextEditingController();
  String _query = '';
  int _selectedNavigation = 0;
  int _currentTrack = 0;
  bool _isPlaying = true;
  bool _isLiked = false;
  bool _isShuffling = false;
  bool _isRepeating = false;
  double _progress = 0.34;
  double _volume = 0.72;

  static const _navigation = [
    (label: 'Home', icon: Icons.home_rounded),
    (label: 'Discover', icon: Icons.explore_rounded),
    (label: 'Radio', icon: Icons.radio_rounded),
    (label: 'Your library', icon: Icons.library_music_rounded),
  ];

  static const _tracks = [
    _Track(
      title: 'Midnight City',
      artist: 'M83',
      album: 'Hurry Up, We’re Dreaming',
      duration: '4:03',
      artwork: 0,
    ),
    _Track(
      title: 'The Less I Know The Better',
      artist: 'Tame Impala',
      album: 'Currents',
      duration: '3:36',
      artwork: 1,
    ),
    _Track(
      title: 'Sunset Lover',
      artist: 'Petit Biscuit',
      album: 'Presence',
      duration: '3:57',
      artwork: 2,
    ),
    _Track(
      title: 'Sweet Disposition',
      artist: 'The Temper Trap',
      album: 'Conditions',
      duration: '3:54',
      artwork: 3,
    ),
  ];

  static const _playlists = [
    _Playlist(
      title: 'Late night drive',
      subtitle: 'The perfect after-hours mix',
      artwork: 0,
    ),
    _Playlist(
      title: 'Golden hour',
      subtitle: 'A little sunshine for your day',
      artwork: 1,
    ),
    _Playlist(
      title: 'Soft focus',
      subtitle: 'Find your quiet place',
      artwork: 2,
    ),
    _Playlist(
      title: 'New frequencies',
      subtitle: 'Fresh sounds, on repeat',
      artwork: 3,
    ),
  ];

  _Track get _activeTrack => _tracks[_currentTrack];

  List<_Track> get _visibleTracks {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _tracks;
    return _tracks
        .where(
          (track) =>
              track.title.toLowerCase().contains(query) ||
              track.artist.toLowerCase().contains(query) ||
              track.album.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectTrack(int index) {
    final track = _visibleTracks[index];
    setState(() {
      _currentTrack = _tracks.indexOf(track);
      _isPlaying = true;
      _progress = 0;
    });
  }

  void _skipTrack(int direction) {
    setState(() {
      _currentTrack =
          (_currentTrack + direction + _tracks.length) % _tracks.length;
      _progress = 0;
      _isPlaying = true;
      _isLiked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 860;
        return Scaffold(
          body: SafeArea(
            child: isMobile ? _buildMobileBody() : _buildDesktopBody(),
          ),
          bottomNavigationBar: isMobile
              ? _buildMobilePlayerAndNavigation()
              : _buildDesktopPlayer(),
        );
      },
    );
  }

  Widget _buildDesktopBody() {
    return Row(
      children: [
        _buildSidebar(),
        Expanded(
          child: Column(
            children: [
              _buildHeader(isMobile: false),
              Expanded(child: _buildContent(isMobile: false)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBody() {
    return Column(
      children: [
        _buildHeader(isMobile: true),
        Expanded(child: _buildContent(isMobile: true)),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 224,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFF1B1D26))),
      ),
      padding: const EdgeInsets.fromLTRB(24, 30, 18, 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.graphic_eq_rounded, color: _lime, size: 28),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'soundwave',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.7,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            const _Eyebrow('MENU'),
            const SizedBox(height: 14),
            for (var index = 0; index < _navigation.length; index++)
              _NavigationItem(
                label: _navigation[index].label,
                icon: _navigation[index].icon,
                selected: _selectedNavigation == index,
                onTap: () => setState(() => _selectedNavigation = index),
              ),
            const SizedBox(height: 38),
            const _Eyebrow('YOUR PLAYLISTS'),
            const SizedBox(height: 12),
            for (final playlist in _playlists.take(3))
              _PlaylistShortcut(
                title: playlist.title,
                artwork: playlist.artwork,
                onTap: () => setState(() => _selectedNavigation = 3),
              ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF171A20),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF252832)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: _lime,
                    size: 20,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your sound, upgraded.',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'A little space for the music you love.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({required bool isMobile}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 20 : 36,
        isMobile ? 18 : 26,
        isMobile ? 20 : 36,
        16,
      ),
      child: Row(
        children: [
          if (isMobile) ...[
            const Icon(Icons.graphic_eq_rounded, color: _lime, size: 24),
            const SizedBox(width: 8),
            const Text(
              'soundwave',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const Spacer(),
          ] else
            Expanded(
              child: Text(
                _selectedNavigation == 0
                    ? 'Home'
                    : _navigation[_selectedNavigation].label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          SizedBox(
            width: isMobile ? 140 : 250,
            height: 42,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: isMobile ? 'Search' : 'Search songs, artists...',
                hintStyle: const TextStyle(color: _muted, fontSize: 12),
                prefixIcon: const Icon(Icons.search_rounded, size: 19),
                prefixIconConstraints: const BoxConstraints(minWidth: 40),
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: _surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: _lime, width: 1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF29251F),
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: const Text(
              'M',
              style: TextStyle(color: _lime, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent({required bool isMobile}) {
    final horizontalPadding = isMobile ? 20.0 : 36.0;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 6, horizontalPadding, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(isMobile: isMobile),
          const SizedBox(height: 22),
          _buildFeaturedCard(isMobile: isMobile),
          const SizedBox(height: 32),
          _SectionHeading(
            title: _query.isEmpty ? 'Made for your moments' : 'Search results',
            action:
                _query.isEmpty ? 'See all' : '${_visibleTracks.length} tracks',
            onAction: () => setState(() => _selectedNavigation = 3),
          ),
          const SizedBox(height: 16),
          _buildPlaylistRow(isMobile: isMobile),
          const SizedBox(height: 30),
          _SectionHeading(
            title: 'Recently played',
            action: 'View history',
            onAction: () => setState(() => _selectedNavigation = 3),
          ),
          const SizedBox(height: 10),
          _buildTrackList(isMobile: isMobile),
        ],
      ),
    );
  }

  Widget _buildGreeting({required bool isMobile}) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning.'
        : (hour < 18 ? 'Good afternoon.' : 'Good evening.');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: isMobile ? 27 : 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.1,
              ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Here’s a little soundtrack for right now.',
          style: TextStyle(color: _muted, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard({required bool isMobile}) {
    return Container(
      height: isMobile ? 224 : 280,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [Color(0xFF3A2A68), Color(0xFF191D32), Color(0xFF15211F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF3A384C)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: isMobile ? -48 : 75,
            top: isMobile ? -54 : -85,
            child: Container(
              width: isMobile ? 230 : 360,
              height: isMobile ? 230 : 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFAC78FF).withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 19 : 30),
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _Eyebrow('THIS WEEK’S FEATURED MIX'),
                      SizedBox(height: isMobile ? 10 : 14),
                      Text(
                        'Afterglow',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontSize: isMobile ? 30 : 44,
                                  height: 1.05,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.7,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isMobile
                            ? 'A mix for the in-between hours.'
                            : 'A mix for the in-between hours. Made just for you.',
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.68),
                          fontSize: isMobile ? 11 : 13,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: isMobile ? 14 : 20),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentTrack = 0;
                            _isPlaying = true;
                            _progress = 0;
                          });
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: const Text('Play mix'),
                        style: FilledButton.styleFrom(
                          backgroundColor: _lime,
                          foregroundColor: const Color(0xFF15180E),
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 14 : 18,
                            vertical: isMobile ? 10 : 13,
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 4,
                  child: AspectRatio(
                    aspectRatio: 0.92,
                    child: Transform.rotate(
                      angle: 0.075,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(isMobile ? 18 : 24),
                        child: const _AlbumArtwork(artwork: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistRow({required bool isMobile}) {
    final width = isMobile ? 145.0 : 176.0;
    final playlists = _query.isEmpty
        ? _playlists
        : _playlists
            .where(
              (playlist) =>
                  playlist.title.toLowerCase().contains(_query.toLowerCase()),
            )
            .toList();
    if (playlists.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Text(
          'No mixes match that search yet.',
          style: TextStyle(color: _muted, fontSize: 13),
        ),
      );
    }
    return SizedBox(
      height: isMobile ? 206 : 237,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: playlists.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return SizedBox(
            width: width,
            child: InkWell(
              onTap: () {
                final trackIndex = playlist.artwork % _tracks.length;
                setState(() {
                  _currentTrack = trackIndex;
                  _isPlaying = true;
                  _progress = 0;
                });
              },
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: _AlbumArtwork(artwork: playlist.artwork),
                            ),
                          ),
                          Positioned(
                            right: 9,
                            bottom: 9,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: _lime,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: _background,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      playlist.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playlist.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrackList({required bool isMobile}) {
    final tracks = _visibleTracks;
    if (tracks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Text(
          'No tracks found. Try a different search.',
          style: TextStyle(color: _muted, fontSize: 13),
        ),
      );
    }
    return Column(
      children: [
        if (!isMobile)
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 4, 16, 7),
            child: Row(
              children: [
                SizedBox(width: 34),
                SizedBox(width: 42),
                Expanded(flex: 5, child: _Eyebrow('TITLE')),
                Expanded(flex: 4, child: _Eyebrow('ALBUM')),
                Icon(Icons.schedule_rounded, size: 14, color: _muted),
                SizedBox(width: 24),
              ],
            ),
          ),
        for (var index = 0; index < tracks.length; index++)
          _TrackRow(
            track: tracks[index],
            index: index,
            isCurrent: tracks[index] == _activeTrack,
            compact: isMobile,
            onTap: () => _selectTrack(index),
          ),
      ],
    );
  }

  Widget _buildDesktopPlayer() {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Color(0xFF101117),
        border: Border(top: BorderSide(color: Color(0xFF242630))),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildPlayerTrackInfo()),
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPlaybackControls(),
                const SizedBox(height: 2),
                _buildProgressSlider(),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.queue_music_rounded, size: 19, color: _muted),
                const SizedBox(width: 13),
                const Icon(Icons.devices_rounded, size: 18, color: _muted),
                const SizedBox(width: 12),
                const Icon(Icons.volume_up_rounded, size: 18, color: _muted),
                SizedBox(
                  width: 84,
                  child: Slider(
                    value: _volume,
                    onChanged: (value) => setState(() => _volume = value),
                    activeColor: Colors.white,
                    inactiveColor: const Color(0xFF343642),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilePlayerAndNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        color: const Color(0xFF101117),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 2),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: _AlbumArtwork(artwork: _activeTrack.artwork),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _activeTrack.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _activeTrack.artist,
                          style: const TextStyle(color: _muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip:
                        _isLiked ? 'Remove from favorites' : 'Add to favorites',
                    onPressed: () => setState(() => _isLiked = !_isLiked),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      _isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 20,
                      color: _isLiked ? _lime : _muted,
                    ),
                  ),
                  IconButton(
                    tooltip: _isPlaying ? 'Pause' : 'Play',
                    onPressed: () => setState(() => _isPlaying = !_isPlaying),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 25,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 4,
                  ),
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  value: _progress,
                  onChanged: (value) => setState(() => _progress = value),
                  activeColor: _lime,
                  inactiveColor: const Color(0xFF343642),
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFF242630)),
            Row(
              children: [
                for (var index = 0; index < _navigation.length; index++)
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedNavigation = index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _navigation[index].icon,
                              size: 20,
                              color:
                                  _selectedNavigation == index ? _lime : _muted,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _navigation[index].label == 'Your library'
                                  ? 'Library'
                                  : _navigation[index].label,
                              style: TextStyle(
                                fontSize: 9,
                                color: _selectedNavigation == index
                                    ? _lime
                                    : _muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerTrackInfo() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 52,
            height: 52,
            child: _AlbumArtwork(artwork: _activeTrack.artwork),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _activeTrack.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _activeTrack.artist,
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: _isLiked ? 'Remove from favorites' : 'Add to favorites',
          onPressed: () => setState(() => _isLiked = !_isLiked),
          icon: Icon(
            _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: _isLiked ? _lime : _muted,
            size: 19,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Shuffle',
          visualDensity: VisualDensity.compact,
          onPressed: () => setState(() => _isShuffling = !_isShuffling),
          icon: Icon(
            Icons.shuffle_rounded,
            size: 17,
            color: _isShuffling ? _lime : _muted,
          ),
        ),
        IconButton(
          tooltip: 'Previous track',
          visualDensity: VisualDensity.compact,
          onPressed: () => _skipTrack(-1),
          icon: const Icon(Icons.skip_previous_rounded, size: 24),
        ),
        IconButton.filled(
          tooltip: _isPlaying ? 'Pause' : 'Play',
          visualDensity: VisualDensity.compact,
          onPressed: () => setState(() => _isPlaying = !_isPlaying),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _background,
            minimumSize: const Size(35, 35),
          ),
          icon: Icon(
            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 22,
          ),
        ),
        IconButton(
          tooltip: 'Next track',
          visualDensity: VisualDensity.compact,
          onPressed: () => _skipTrack(1),
          icon: const Icon(Icons.skip_next_rounded, size: 24),
        ),
        IconButton(
          tooltip: 'Repeat',
          visualDensity: VisualDensity.compact,
          onPressed: () => setState(() => _isRepeating = !_isRepeating),
          icon: Icon(
            Icons.repeat_rounded,
            size: 17,
            color: _isRepeating ? _lime : _muted,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSlider() {
    return Row(
      children: [
        Text(
          _progress == 0
              ? '0:00'
              : '1:${(_progress * 59).floor().toString().padLeft(2, '0')}',
          style: const TextStyle(color: _muted, fontSize: 9),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: _progress,
              onChanged: (value) => setState(() => _progress = value),
              activeColor: _lime,
              inactiveColor: const Color(0xFF343642),
            ),
          ),
        ),
        Text(
          _activeTrack.duration,
          style: const TextStyle(color: _muted, fontSize: 9),
        ),
      ],
    );
  }
}

class _Track {
  const _Track({
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.artwork,
  });

  final String title;
  final String artist;
  final String album;
  final String duration;
  final int artwork;
}

class _Playlist {
  const _Playlist({
    required this.title,
    required this.subtitle,
    required this.artwork,
  });

  final String title;
  final String subtitle;
  final int artwork;
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: _muted,
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.25,
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Material(
        color: selected ? const Color(0xFF20231A) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(icon, size: 19, color: selected ? _lime : _muted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.white : _muted,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaylistShortcut extends StatelessWidget {
  const _PlaylistShortcut({
    required this.title,
    required this.artwork,
    required this.onTap,
  });

  final String title;
  final int artwork;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 31,
                height: 31,
                child: _AlbumArtwork(artwork: artwork),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.action,
    required this.onAction,
  });

  final String title;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.25),
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: _muted,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: Text(action),
        ),
      ],
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({
    required this.track,
    required this.index,
    required this.isCurrent,
    required this.compact,
    required this.onTap,
  });

  final _Track track;
  final int index;
  final bool isCurrent;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isCurrent ? const Color(0xFF181B20) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  isCurrent ? '♪' : '${index + 1}',
                  style: TextStyle(
                    color: isCurrent ? _lime : _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: _AlbumArtwork(artwork: track.artwork),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isCurrent ? _lime : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track.artist,
                      style: const TextStyle(color: _muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              if (!compact) ...[
                Expanded(
                  flex: 4,
                  child: Text(
                    track.album,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 10),
                  ),
                ),
                Text(
                  track.duration,
                  style: const TextStyle(color: _muted, fontSize: 10),
                ),
                const SizedBox(width: 11),
                const Icon(Icons.more_horiz_rounded, size: 19, color: _muted),
              ] else
                Text(
                  track.duration,
                  style: const TextStyle(color: _muted, fontSize: 10),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlbumArtwork extends StatelessWidget {
  const _AlbumArtwork({required this.artwork});

  final int artwork;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _ArtworkPainter(artwork),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ArtworkPainter extends CustomPainter {
  const _ArtworkPainter(this.artwork);

  final int artwork;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final presets = [
      (
        base: const Color(0xFF25245A),
        accent: const Color(0xFFFF9B70),
        glow: const Color(0xFF9664FF),
      ),
      (
        base: const Color(0xFF613C39),
        accent: const Color(0xFFFFBE73),
        glow: const Color(0xFFF06652),
      ),
      (
        base: const Color(0xFF162C57),
        accent: const Color(0xFF84D7EE),
        glow: const Color(0xFF987DFF),
      ),
      (
        base: const Color(0xFF354B34),
        accent: const Color(0xFFC9E88A),
        glow: const Color(0xFF64A883),
      ),
    ];
    final colors = presets[artwork % presets.length];
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors.base,
          Color.lerp(colors.base, colors.glow, 0.7)!,
          const Color(0xFF11131D),
        ],
      ).createShader(bounds);
    canvas.drawRect(bounds, paint);

    final center = Offset(size.width * 0.57, size.height * 0.43);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          colors.accent.withValues(alpha: 0.9),
          colors.glow.withValues(alpha: 0.32),
          Colors.transparent,
        ],
        stops: const [0, 0.48, 1],
      ).createShader(
        Rect.fromCircle(center: center, radius: size.width * 0.72),
      );
    canvas.drawRect(bounds, glowPaint);

    final artIndex = artwork % presets.length;
    final foreground = Paint()
      ..color = colors.accent.withValues(alpha: 0.66)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.3, size.width * 0.012);
    if (artIndex == 0) {
      for (var index = 0; index < 8; index++) {
        canvas.drawArc(
          Rect.fromCircle(
            center: center,
            radius: size.width * (0.14 + index * 0.064),
          ),
          -math.pi * 0.76 + index * 0.08,
          math.pi * (1.28 + (index % 3) * 0.16),
          false,
          foreground
            ..color = colors.accent.withValues(alpha: 0.38 - index * 0.025),
        );
      }
      canvas.drawCircle(
        center.translate(-size.width * 0.12, size.height * 0.09),
        size.width * 0.13,
        Paint()..color = colors.accent.withValues(alpha: 0.86),
      );
    } else if (artIndex == 1) {
      final recordCenter = Offset(size.width * 0.59, size.height * 0.45);
      for (var index = 0; index < 6; index++) {
        final radius = size.width * (0.13 + index * 0.083);
        canvas.drawCircle(
          recordCenter,
          radius,
          foreground
            ..color = colors.accent.withValues(alpha: 0.2 + index * 0.07),
        );
      }
      canvas.drawCircle(
        recordCenter,
        size.width * 0.075,
        Paint()..color = colors.accent,
      );
      final slash = Path()
        ..moveTo(-size.width * 0.1, size.height * 0.82)
        ..quadraticBezierTo(
          size.width * 0.42,
          size.height * 0.48,
          size.width * 1.1,
          size.height * 0.68,
        );
      canvas.drawPath(
        slash,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.12)
          ..strokeWidth = size.width * 0.11
          ..style = PaintingStyle.stroke,
      );
    } else if (artIndex == 2) {
      final orbit = Rect.fromCircle(center: center, radius: size.width * 0.35);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-0.46);
      canvas.translate(-center.dx, -center.dy);
      canvas.drawOval(
        orbit,
        foreground
          ..color = Colors.white.withValues(alpha: 0.42)
          ..strokeWidth = size.width * 0.025,
      );
      canvas.restore();
      final planet = Paint()
        ..shader = LinearGradient(
          colors: [colors.accent, colors.glow, const Color(0xFF353068)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(
          Rect.fromCircle(center: center, radius: size.width * 0.27),
        );
      canvas.drawCircle(center, size.width * 0.27, planet);
      canvas.drawArc(
        Rect.fromCircle(
          center: center.translate(0, size.width * 0.09),
          radius: size.width * 0.35,
        ),
        0.2,
        math.pi * 0.8,
        false,
        foreground
          ..color = Colors.white.withValues(alpha: 0.65)
          ..strokeWidth = size.width * 0.023,
      );
    } else {
      final hills = Path()
        ..moveTo(0, size.height * 0.72)
        ..cubicTo(
          size.width * 0.18,
          size.height * 0.48,
          size.width * 0.36,
          size.height * 0.78,
          size.width * 0.53,
          size.height * 0.56,
        )
        ..cubicTo(
          size.width * 0.71,
          size.height * 0.34,
          size.width * 0.84,
          size.height * 0.57,
          size.width,
          size.height * 0.36,
        )
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        hills,
        Paint()..color = colors.accent.withValues(alpha: 0.75),
      );
      for (var index = 0; index < 4; index++) {
        canvas.drawArc(
          Rect.fromLTWH(
            size.width * 0.18,
            size.height * (0.18 + index * 0.065),
            size.width * 0.64,
            size.height * 0.36,
          ),
          math.pi * 0.12,
          math.pi * 0.76,
          false,
          foreground
            ..color = Colors.white.withValues(alpha: 0.18)
            ..strokeWidth = size.width * 0.012,
        );
      }
      canvas.drawCircle(
        Offset(size.width * 0.72, size.height * 0.27),
        size.width * 0.085,
        Paint()..color = colors.accent,
      );
    }

    final label = TextPainter(
      text: TextSpan(
        text: ['NOCTURNE', 'SOLSTICE', 'ORBITAL', 'ELSEWHERE'][artIndex],
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.83),
          fontSize: math.max(7, size.width * 0.052),
          fontWeight: FontWeight.w700,
          letterSpacing: math.max(1, size.width * 0.014),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.85);
    label.paint(canvas, Offset(size.width * 0.08, size.height * 0.86));
  }

  @override
  bool shouldRepaint(covariant _ArtworkPainter oldDelegate) =>
      artwork != oldDelegate.artwork;
}
