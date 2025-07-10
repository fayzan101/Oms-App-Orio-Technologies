import 'package:get/get.dart';
import '../models/help_video_model.dart';
import '../services/help_video_service.dart';

class HelpVideoController extends GetxController {
  final HelpVideoService _helpVideoService = HelpVideoService();

  // Observable variables
  final RxList<HelpVideoModel> videos = <HelpVideoModel>[].obs;
  final RxList<HelpVideoModel> filteredVideos = <HelpVideoModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedType = 'All'.obs;
  final RxString selectedStatus = 'All'.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;

  // Filter options
  final List<String> videoTypes = ['All', 'Tutorial', 'Guide', 'FAQ', 'Setup'];
  final List<String> statusOptions = ['All', 'active', 'inactive'];

  @override
  void onInit() {
    super.onInit();
    loadVideos();
  }

  Future<void> loadVideos({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
    }

    if (!hasMoreData.value && !refresh) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final newVideos = await _helpVideoService.getHelpVideos(
        searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
        type: selectedType.value == 'All' ? null : selectedType.value,
        status: selectedStatus.value == 'All' ? null : selectedStatus.value,
        page: currentPage.value,
        limit: 20,
      );

      if (refresh) {
        videos.clear();
        filteredVideos.clear();
      }

      videos.addAll(newVideos);
      filteredVideos.addAll(newVideos);

      // Check if we have more data
      hasMoreData.value = newVideos.length >= 20;

      if (hasMoreData.value) {
        currentPage.value++;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void searchVideos(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    hasMoreData.value = true;
    loadVideos(refresh: true);
  }

  void filterByType(String type) {
    selectedType.value = type;
    currentPage.value = 1;
    hasMoreData.value = true;
    loadVideos(refresh: true);
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    currentPage.value = 1;
    hasMoreData.value = true;
    loadVideos(refresh: true);
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedType.value = 'All';
    selectedStatus.value = 'All';
    currentPage.value = 1;
    hasMoreData.value = true;
    loadVideos(refresh: true);
  }

  Future<void> refreshVideos() async {
    await loadVideos(refresh: true);
  }

  Future<HelpVideoModel?> getVideoById(String id) async {
    try {
      return await _helpVideoService.getHelpVideoById(id);
    } catch (e) {
      errorMessage.value = e.toString();
      return null;
    }
  }

  List<HelpVideoModel> getVideosByType(String type) {
    return videos.where((video) => video.type.toLowerCase() == type.toLowerCase()).toList();
  }

  List<HelpVideoModel> getActiveVideos() {
    return videos.where((video) => video.status == 'active').toList();
  }

  void clearError() {
    errorMessage.value = '';
  }
} 