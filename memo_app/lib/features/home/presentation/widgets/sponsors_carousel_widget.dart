import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/sponsor_entity.dart';

/// Modern Sponsors Slider Widget
/// هذا التطبيق برعاية - Full card slider with photo, name and subject
class SponsorsCarouselWidget extends StatefulWidget {
  final List<SponsorEntity> sponsors;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final double itemSize;
  final double spacing;
  final Function(int sponsorId, String platform)? onSponsorClick;

  const SponsorsCarouselWidget({
    super.key,
    required this.sponsors,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.itemSize = 80,
    this.spacing = 16,
    this.onSponsorClick,
  });

  @override
  State<SponsorsCarouselWidget> createState() => _SponsorsCarouselWidgetState();
}

class _SponsorsCarouselWidgetState extends State<SponsorsCarouselWidget> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: 0,
    );

    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
      }
    });

    if (widget.autoPlay && widget.sponsors.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    Future.delayed(widget.autoPlayInterval, () {
      if (mounted && widget.autoPlay) {
        final nextPage = (_currentPage + 1) % widget.sponsors.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
        _startAutoPlay();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url, int sponsorId, String platform) async {
    // Record click before launching URL
    widget.onSponsorClick?.call(sponsorId, platform);

    // Try to open in native app based on platform
    Uri? appUri;
    final webUri = Uri.parse(url);

    switch (platform) {
      case 'youtube':
        // Try YouTube app first
        if (url.contains('youtube.com/') || url.contains('youtu.be/')) {
          final videoId = _extractYouTubeId(url);
          if (videoId != null) {
            appUri = Uri.parse('youtube://www.youtube.com/watch?v=$videoId');
          } else if (url.contains('@') || url.contains('/channel/') || url.contains('/c/')) {
            // Channel URL
            appUri = Uri.parse('youtube://${webUri.host}${webUri.path}');
          }
        }
        break;
      case 'facebook':
        // Try Facebook app
        if (url.contains('facebook.com/')) {
          final path = webUri.path.replaceFirst('/', '');
          appUri = Uri.parse('fb://profile/$path');
        }
        break;
      case 'instagram':
        // Try Instagram app
        if (url.contains('instagram.com/')) {
          final username = webUri.path.replaceAll('/', '');
          if (username.isNotEmpty) {
            appUri = Uri.parse('instagram://user?username=$username');
          }
        }
        break;
      case 'telegram':
        // Try Telegram app
        if (url.contains('t.me/')) {
          final username = webUri.path.replaceAll('/', '');
          if (username.isNotEmpty) {
            appUri = Uri.parse('tg://resolve?domain=$username');
          }
        }
        break;
    }

    // Try native app first
    if (appUri != null) {
      try {
        final launched = await launchUrl(appUri);
        if (launched) return;
      } catch (_) {
        // Native app not available, continue to web fallback
      }
    }

    // Fallback to browser - use platformDefault mode for better compatibility
    try {
      await launchUrl(
        webUri,
        mode: LaunchMode.platformDefault,
      );
    } catch (_) {
      // Last resort: try external application
      await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  String? _extractYouTubeId(String url) {
    // Extract video ID from various YouTube URL formats
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sponsors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'هذا التطبيق برعاية',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'أساتذة متميزون في مختلف المواد',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Slider
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.sponsors.length,
            itemBuilder: (context, index) {
              final sponsor = widget.sponsors[index];
              final isActive = index == _currentPage;
              return AnimatedScale(
                scale: isActive ? 1.0 : 0.92,
                duration: const Duration(milliseconds: 300),
                child: AnimatedOpacity(
                  opacity: isActive ? 1.0 : 0.7,
                  duration: const Duration(milliseconds: 300),
                  child: _buildSponsorCard(sponsor),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Page Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.sponsors.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 28 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isActive
                    ? const Color(0xFF7C3AED)
                    : const Color(0xFFE2E8F0),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSponsorCard(SponsorEntity sponsor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF5F3FF),
            Color(0xFFEDE9FE),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFDDD6FE),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Photo Section
          Container(
            width: 140,
            height: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Stack(
              children: [
                // Photo
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(23),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: sponsor.photoUrl,
                    width: 140,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 60,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(23),
                        bottomRight: Radius.circular(23),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ),
                // Click count badge - commented out
                // if (sponsor.clickCount > 0)
                  // Positioned(
                  //   top: 8,
                  //   left: 8,
                  //   child: Container(
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 8,
                  //       vertical: 4,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: Colors.black.withValues(alpha: 0.6),
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     child: Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         const Icon(
                  //           Icons.visibility_rounded,
                  //           size: 12,
                  //           color: Colors.white,
                  //         ),
                  //         const SizedBox(width: 4),
                  //         Text(
                  //           sponsor.formattedClickCount,
                  //           style: const TextStyle(
                  //             fontFamily: 'Cairo',
                  //             fontSize: 10,
                  //             fontWeight: FontWeight.bold,
                  //             color: Colors.white,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
              ],
            ),
          ),

          // Info Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title badge
                  if (sponsor.title != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        sponsor.title!,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Name
                  Text(
                    sponsor.nameAr,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Subject/Specialty
                  if (sponsor.specialty != null)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            size: 16,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sponsor.specialty!,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  const Spacer(),

                  // Social Media Icons Row
                  _buildSocialLinksRow(sponsor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build row of social media icon buttons
  Widget _buildSocialLinksRow(SponsorEntity sponsor) {
    final links = <Widget>[];

    // YouTube
    if (sponsor.youtubeLink != null && sponsor.youtubeLink!.isNotEmpty) {
      links.add(_buildSocialIcon(
        icon: Icons.play_circle_fill_rounded,
        color: const Color(0xFFFF0000),
        url: sponsor.youtubeLink!,
        sponsorId: sponsor.id,
        platform: 'youtube',
      ));
    }

    // Facebook
    if (sponsor.facebookLink != null && sponsor.facebookLink!.isNotEmpty) {
      links.add(_buildSocialIcon(
        icon: Icons.facebook_rounded,
        color: const Color(0xFF1877F2),
        url: sponsor.facebookLink!,
        sponsorId: sponsor.id,
        platform: 'facebook',
      ));
    }

    // Instagram
    if (sponsor.instagramLink != null && sponsor.instagramLink!.isNotEmpty) {
      links.add(_buildSocialIcon(
        icon: Icons.camera_alt_rounded,
        color: const Color(0xFFE4405F),
        url: sponsor.instagramLink!,
        sponsorId: sponsor.id,
        platform: 'instagram',
        useGradient: true,
      ));
    }

    // Telegram
    if (sponsor.telegramLink != null && sponsor.telegramLink!.isNotEmpty) {
      links.add(_buildSocialIcon(
        icon: Icons.telegram_rounded,
        color: const Color(0xFF0088CC),
        url: sponsor.telegramLink!,
        sponsorId: sponsor.id,
        platform: 'telegram',
      ));
    }

    // Fallback to external_link if no social links
    if (links.isEmpty && sponsor.externalLink != null && sponsor.externalLink!.isNotEmpty) {
      return GestureDetector(
        onTap: () => _launchUrl(sponsor.externalLink!, sponsor.id, 'general'),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_circle_filled_rounded,
                size: 18,
                color: Colors.white,
              ),
              SizedBox(width: 6),
              Text(
                'زيارة القناة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: links,
    );
  }

  /// Build individual social media icon button
  Widget _buildSocialIcon({
    required IconData icon,
    required Color color,
    required String url,
    required int sponsorId,
    required String platform,
    bool useGradient = false,
  }) {
    return GestureDetector(
      onTap: () => _launchUrl(url, sponsorId, platform),
      child: Container(
        width: 26,
        height: 26,
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          gradient: useGradient
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF58529),
                    Color(0xFFDD2A7B),
                    Color(0xFF8134AF),
                    Color(0xFF515BD4),
                  ],
                )
              : null,
          color: useGradient ? null : color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 14,
        ),
      ),
    );
  }
}

/// Alternative: Compact horizontal list design
class SponsorsListWidget extends StatelessWidget {
  final List<SponsorEntity> sponsors;
  final double itemSize;
  final Function(int sponsorId, String platform)? onSponsorClick;

  const SponsorsListWidget({
    super.key,
    required this.sponsors,
    this.itemSize = 70,
    this.onSponsorClick,
  });

  Future<void> _launchUrl(String url, int sponsorId, String platform) async {
    // Record click before launching URL
    onSponsorClick?.call(sponsorId, platform);

    // Try to open in native app based on platform
    Uri? appUri;
    final webUri = Uri.parse(url);

    switch (platform) {
      case 'youtube':
        if (url.contains('youtube.com/') || url.contains('youtu.be/')) {
          final videoId = _extractYouTubeId(url);
          if (videoId != null) {
            appUri = Uri.parse('youtube://www.youtube.com/watch?v=$videoId');
          } else if (url.contains('@') || url.contains('/channel/') || url.contains('/c/')) {
            appUri = Uri.parse('youtube://${webUri.host}${webUri.path}');
          }
        }
        break;
      case 'facebook':
        if (url.contains('facebook.com/')) {
          final path = webUri.path.replaceFirst('/', '');
          appUri = Uri.parse('fb://profile/$path');
        }
        break;
      case 'instagram':
        if (url.contains('instagram.com/')) {
          final username = webUri.path.replaceAll('/', '');
          if (username.isNotEmpty) {
            appUri = Uri.parse('instagram://user?username=$username');
          }
        }
        break;
      case 'telegram':
        if (url.contains('t.me/')) {
          final username = webUri.path.replaceAll('/', '');
          if (username.isNotEmpty) {
            appUri = Uri.parse('tg://resolve?domain=$username');
          }
        }
        break;
    }

    // Try native app first
    if (appUri != null) {
      try {
        final launched = await launchUrl(appUri);
        if (launched) return;
      } catch (_) {
        // Native app not available, continue to web fallback
      }
    }

    // Fallback to browser
    try {
      await launchUrl(webUri, mode: LaunchMode.platformDefault);
    } catch (_) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  String? _extractYouTubeId(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    if (sponsors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.handshake_rounded,
                color: Color(0xFF7C3AED),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'شركاؤنا',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: itemSize + 30,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sponsors.length,
              itemBuilder: (context, index) {
                final sponsor = sponsors[index];
                return _buildCompactSponsorItem(sponsor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSponsorItem(SponsorEntity sponsor) {
    // Get first available link
    String? link = sponsor.youtubeLink ?? sponsor.facebookLink ??
                   sponsor.instagramLink ?? sponsor.telegramLink ??
                   sponsor.externalLink;
    String platform = sponsor.youtubeLink != null ? 'youtube' :
                      sponsor.facebookLink != null ? 'facebook' :
                      sponsor.instagramLink != null ? 'instagram' :
                      sponsor.telegramLink != null ? 'telegram' : 'general';

    return GestureDetector(
      onTap: link != null ? () => _launchUrl(link, sponsor.id, platform) : null,
      child: Container(
        width: itemSize + 20,
        margin: const EdgeInsets.only(left: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: itemSize,
              height: itemSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF7C3AED),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: sponsor.photoUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFFF1F5F9),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFFF1F5F9),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              sponsor.nameAr,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
