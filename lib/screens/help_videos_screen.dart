import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/help_video_model.dart';
import '../services/help_video_service.dart';
import '../widgets/custom_nav_bar.dart';

class HelpVideosScreen extends StatelessWidget {
  HelpVideosScreen({Key? key}) : super(key: key);

  final HelpVideoService _helpVideoService = HelpVideoService();

  String _getYoutubeThumbnail(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';
    final videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments.last.split('?').first : '';
    if (videoId.isEmpty) return '';
    return 'https://img.youtube.com/vi/$videoId/0.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Helps'),
      ),
      body: FutureBuilder<List<HelpVideoModel>>(
        future: _helpVideoService.getHelpVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No help videos found.'));
          }
          final videos = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 20),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                _getYoutubeThumbnail(video.postLink),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (c, e, s) => Container(color: Colors.grey[200]),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                color: Colors.black.withOpacity(0.2),
                                height: 36,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                                    const Spacer(),
                                    Image.asset('assets/youtube_logo.png', height: 20),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              video.title,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            video.duration,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Post Date: ${video.postDate}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A2A3A),
        onPressed: () {},
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomNavBar(
        selectedIndex: 4,
        onTabSelected: (index) {
          if (index == 0) Get.offAllNamed('/dashboard');
          if (index == 1) Get.offAllNamed('/order-list');
          if (index == 2) Get.offAllNamed('/reports');
          if (index == 3) Get.offAllNamed('/menu');
        },
      ),
    );
  }
} 