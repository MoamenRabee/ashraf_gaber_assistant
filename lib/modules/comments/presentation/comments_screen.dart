import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:samy_mossad_assistant/core/constants.dart';
import 'package:samy_mossad_assistant/core/injection_container.dart' as di;
import 'package:samy_mossad_assistant/modules/comments/presentation/cubit/comments_cubit.dart';
import 'package:samy_mossad_assistant/modules/comments/presentation/cubit/comments_state.dart';

class CommentsScreen extends StatelessWidget {
  const CommentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<CommentsCubit>()..loadComments(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التعليقات'),
          centerTitle: true,
          actions: [
            Builder(
              builder: (context) => IconButton(
                onPressed: () {
                  context.read<CommentsCubit>().refreshComments();
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'تحديث',
              ),
            ),
          ],
        ),
        body: BlocBuilder<CommentsCubit, CommentsState>(
          builder: (context, state) {
            if (state is CommentsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CommentsNoInternet) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('لا يوجد اتصال بالإنترنت', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<CommentsCubit>().loadComments();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (state is CommentsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 80, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<CommentsCubit>().loadComments();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (state is CommentsLoaded) {
              return Column(
                children: [
                  // Stats & Filters Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[100],
                    child: Column(
                      children: [
                        // Stats Row
                        Row(
                          children: [
                            Expanded(child: _buildStatCard('الكل', state.total.toString(), Colors.blue, Icons.comment)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'غير مقروء',
                                state.total.toString(), // Will be calculated from all comments
                                Colors.orange,
                                Icons.mark_email_unread,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'مقروء',
                                (state.total - state.comments.where((c) => !c.isRead).length).toString(),
                                Colors.green,
                                Icons.mark_email_read,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Filter Chips
                        Row(
                          children: [
                            Expanded(
                              child: _buildFilterChip(
                                context,
                                label: 'الكل',
                                isSelected: state.filter == CommentFilter.all,
                                onTap: () => context.read<CommentsCubit>().changeFilter(CommentFilter.all),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildFilterChip(
                                context,
                                label: 'غير مقروء',
                                isSelected: state.filter == CommentFilter.unread,
                                onTap: () => context.read<CommentsCubit>().changeFilter(CommentFilter.unread),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildFilterChip(
                                context,
                                label: 'مقروء',
                                isSelected: state.filter == CommentFilter.read,
                                onTap: () => context.read<CommentsCubit>().changeFilter(CommentFilter.read),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Comments List
                  Expanded(
                    child: state.comments.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.comment_outlined, size: 80, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('لا توجد تعليقات', style: TextStyle(fontSize: 18, color: Colors.grey)),
                              ],
                            ),
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (scrollInfo) {
                              if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.9) {
                                context.read<CommentsCubit>().loadMoreComments();
                              }
                              return false;
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.comments.length + (state.currentPage < state.lastPage ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == state.comments.length) {
                                  return const Center(
                                    child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                                  );
                                }

                                final comment = state.comments[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: InkWell(
                                    onTap: () {
                                      _showCommentDetails(context, comment);
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Header
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: Colors.blue,
                                                child: Text(
                                                  comment.student.name[0].toUpperCase(),
                                                  style: const TextStyle(color: Colors.white),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      comment.student.name,
                                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                                                    Text(
                                                      DateFormat('dd/MM/yyyy').format(DateTime.parse(comment.createdAt)),
                                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (!comment.isRead)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: const Text(
                                                    'جديد',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          // Comment Content
                                          Text(
                                            comment.content,
                                            style: const TextStyle(fontSize: 15),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          // Reply Status
                                          if (comment.replyText != null) ...[
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'تم الرد',
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, {required String label, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _showCommentDetails(BuildContext context, comment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (bottomSheetContext) => _CommentDetailsSheet(comment: comment, cubit: context.read<CommentsCubit>()),
    );
  }
}

class _CommentDetailsSheet extends StatefulWidget {
  final dynamic comment;
  final CommentsCubit cubit;

  const _CommentDetailsSheet({required this.comment, required this.cubit});

  @override
  State<_CommentDetailsSheet> createState() => _CommentDetailsSheetState();
}

class _CommentDetailsSheetState extends State<_CommentDetailsSheet> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _playPosition = Duration.zero;
  Duration _playDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Listen to player state
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Listen to position
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _playPosition = position;
        });
      }
    });

    // Listen to duration
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _playDuration = duration;
        });
      }
    });

    // Listen to completion
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _playPosition = Duration.zero;
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPauseAudio(String voiceUrl) async {
    final url = '${Constants.storage}/$voiceUrl';
    log('Full audio URL: $url');
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        // Stop any previous playback first
        await _audioPlayer.stop();
        // Play from URL
        await _audioPlayer.play(UrlSource(url));
      }
    } catch (e) {
      log('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تشغيل الصوت: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _playPosition = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'الآن';
          }
          return 'منذ ${difference.inMinutes} دقيقة';
        }
        return 'منذ ${difference.inHours} ساعة';
      } else if (difference.inDays == 1) {
        return 'أمس';
      } else if (difference.inDays < 7) {
        return 'منذ ${difference.inDays} أيام';
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 30,
                child: Text(
                  widget.comment.student.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.comment.student.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(_formatDate(widget.comment.createdAt), style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          const Text('التعليق:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(widget.comment.content, style: const TextStyle(fontSize: 16)),
          if (widget.comment.image != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                '${Constants.storage}/${widget.comment.image}',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 200, color: Colors.grey[300], child: const Icon(Icons.broken_image, size: 50)),
              ),
            ),
          ],
          if (widget.comment.replyText != null || widget.comment.replyImage != null || widget.comment.replyVoice != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.reply, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      const Text('الرد:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (widget.comment.replyText != null) ...[
                    const SizedBox(height: 8),
                    Text(widget.comment.replyText!, style: const TextStyle(fontSize: 15)),
                  ],
                  if (widget.comment.replyImage != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '${Constants.storage}/${widget.comment.replyImage}',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  if (widget.comment.replyVoice != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('رسالة صوتية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  log('Play/Pause audio button pressed ${widget.comment.replyVoice}');
                                  _playPauseAudio(widget.comment.replyVoice!);
                                },
                                icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                                iconSize: 40,
                                color: Colors.green,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    SliderTheme(
                                      data: SliderThemeData(
                                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                                        trackHeight: 2,
                                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                                      ),
                                      child: Slider(
                                        value: _playPosition.inSeconds.toDouble(),
                                        max: _playDuration.inSeconds > 0 ? _playDuration.inSeconds.toDouble() : 1.0,
                                        onChanged: (value) async {
                                          await _audioPlayer.seek(Duration(seconds: value.toInt()));
                                        },
                                        activeColor: Colors.green,
                                        inactiveColor: Colors.green.shade200,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDuration(_playPosition),
                                            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                                          ),
                                          Text(
                                            _formatDuration(_playDuration),
                                            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isPlaying)
                                IconButton(
                                  onPressed: _stopAudio,
                                  icon: const Icon(Icons.stop_circle),
                                  iconSize: 32,
                                  color: Colors.red,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (sheetContext) => _ReplyBottomSheet(comment: widget.comment, cubit: widget.cubit),
                    );
                  },
                  icon: const Icon(Icons.reply),
                  label: const Text('رد'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (!widget.comment.isRead) {
                      widget.cubit.replyToComment(
                        commentId: widget.comment.commentId,
                        replyText: null,
                        replyImagePath: null,
                        replyVoicePath: null,
                        liked: widget.comment.liked,
                        isRead: true,
                      );
                    }
                    Navigator.pop(context);
                  },
                  icon: Icon(widget.comment.isRead ? Icons.check_circle : Icons.check_circle_outline),
                  label: Text(widget.comment.isRead ? 'مقروء' : 'تعليم مقروء'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.comment.isRead ? Colors.green : Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReplyBottomSheet extends StatefulWidget {
  final dynamic comment;
  final CommentsCubit cubit;

  const _ReplyBottomSheet({required this.comment, required this.cubit});

  @override
  State<_ReplyBottomSheet> createState() => _ReplyBottomSheetState();
}

class _ReplyBottomSheetState extends State<_ReplyBottomSheet> {
  final _replyController = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _selectedImagePath;
  String? _selectedVoicePath;
  bool _liked = false;
  bool _isRead = true;
  bool _isRecording = false;
  bool _isPlaying = false;
  Duration _recordDuration = Duration.zero;
  Duration _playPosition = Duration.zero;
  Duration _playDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _liked = widget.comment.liked ?? false;
    _isRead = widget.comment.isRead ?? false;

    // Listen to player state
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Listen to position
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _playPosition = position;
        });
      }
    });

    // Listen to duration
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _playDuration = duration;
        });
      }
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Show options dialog
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('اختر مصدر الصورة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('الكاميرا'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('المعرض'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final XFile? image = await picker.pickImage(source: source, maxWidth: 1920, maxHeight: 1080, imageQuality: 85);

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم اختيار الصورة'), backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في اختيار الصورة: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _showVoiceOptions() async {
    final option = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر طريقة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mic, color: Colors.red),
              title: const Text('تسجيل صوت'),
              onTap: () => Navigator.pop(context, 'record'),
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('اختيار من الملفات'),
              onTap: () => Navigator.pop(context, 'pick'),
            ),
          ],
        ),
      ),
    );

    if (option == 'record') {
      _startRecording();
    } else if (option == 'pick') {
      _pickVoiceFile();
    }
  }

  Future<void> _pickVoiceFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio, allowMultiple: false);

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedVoicePath = result.files.single.path;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم اختيار الملف الصوتي'), backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في اختيار الملف الصوتي: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath = '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(const RecordConfig(), path: filePath);

        setState(() {
          _isRecording = true;
          _recordDuration = Duration.zero;
        });

        // Update duration while recording
        _updateRecordDuration();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('جاري التسجيل...'), backgroundColor: Colors.red, duration: Duration(seconds: 1)),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('يرجى السماح بالوصول إلى الميكروفون'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في بدء التسجيل: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _updateRecordDuration() {
    if (_isRecording) {
      Future.delayed(const Duration(seconds: 1), () {
        if (_isRecording && mounted) {
          setState(() {
            _recordDuration = _recordDuration + const Duration(seconds: 1);
          });
          _updateRecordDuration();
        }
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      final String? path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
        if (path != null) {
          _selectedVoicePath = path;
        }
      });

      if (mounted && path != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم التسجيل بنجاح'), backgroundColor: Colors.green));
      }
    } catch (e) {
      setState(() => _isRecording = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في إيقاف التسجيل: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _cancelRecording() async {
    try {
      await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordDuration = Duration.zero;
      });
    } catch (e) {
      setState(() => _isRecording = false);
    }
  }

  Future<void> _playPauseAudio() async {
    try {
      if (_selectedVoicePath == null) return;

      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(DeviceFileSource(_selectedVoicePath!));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تشغيل الصوت: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _playPosition = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _sendReply() {
    if (_replyController.text.trim().isEmpty && _selectedImagePath == null && _selectedVoicePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى كتابة رد أو اختيار صورة أو صوت')));
      return;
    }

    widget.cubit.replyToComment(
      commentId: widget.comment.id,
      replyText: _replyController.text.trim().isNotEmpty ? _replyController.text.trim() : null,
      replyImagePath: _selectedImagePath,
      replyVoicePath: _selectedVoicePath,
      liked: _liked,
      isRead: _isRead,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: BlocListener<CommentsCubit, CommentsState>(
        listener: (context, state) {
          if (state is CommentReplySuccess) {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('تم الرد بنجاح'), backgroundColor: Colors.green));
          } else if (state is CommentReplyError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        child: Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Text('الرد على تعليق', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),

                // Reply Text Field
                TextField(
                  controller: _replyController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'نص الرد',
                    hintText: 'اكتب ردك هنا...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.message),
                  ),
                ),
                const SizedBox(height: 16),

                // Image & Voice Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('إضافة صورة'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isRecording ? null : _showVoiceOptions,
                        icon: const Icon(Icons.mic),
                        label: const Text('إضافة صوت'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Recording UI
                if (_isRecording) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 12),
                            const Text('جاري التسجيل...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Spacer(),
                            Text(
                              '${_recordDuration.inMinutes}:${(_recordDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _cancelRecording,
                                icon: const Icon(Icons.close),
                                label: const Text('إلغاء'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _stopRecording,
                                icon: const Icon(Icons.stop),
                                label: const Text('إيقاف'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Show selected image preview
                if (_selectedImagePath != null) ...[
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(_selectedImagePath!), height: 200, width: double.infinity, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: () {
                            setState(() => _selectedImagePath = null);
                          },
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Show selected voice file with player
                if (_selectedVoicePath != null && !_isRecording) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                              child: const Icon(Icons.mic, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('رسالة صوتية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            IconButton(
                              onPressed: () async {
                                await _stopAudio();
                                setState(() {
                                  _selectedVoicePath = null;
                                  _recordDuration = Duration.zero;
                                });
                              },
                              icon: const Icon(Icons.close),
                              color: Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Audio player controls
                        Row(
                          children: [
                            IconButton(
                              onPressed: _playPauseAudio,
                              icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                              iconSize: 48,
                              color: Colors.green,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SliderTheme(
                                    data: SliderThemeData(
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                      trackHeight: 3,
                                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                    ),
                                    child: Slider(
                                      value: _playPosition.inSeconds.toDouble(),
                                      max: (_playDuration.inSeconds > 0 ? _playDuration : _recordDuration).inSeconds.toDouble(),
                                      onChanged: (value) async {
                                        await _audioPlayer.seek(Duration(seconds: value.toInt()));
                                      },
                                      activeColor: Colors.green,
                                      inactiveColor: Colors.green.shade200,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDuration(_playPosition),
                                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                        ),
                                        Text(
                                          _formatDuration(_playDuration.inSeconds > 0 ? _playDuration : _recordDuration),
                                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_isPlaying)
                              IconButton(
                                onPressed: _stopAudio,
                                icon: const Icon(Icons.stop_circle),
                                iconSize: 36,
                                color: Colors.red,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Like & Read Switches
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('إعجاب'),
                          secondary: Icon(Icons.favorite, color: _liked ? Colors.red : Colors.grey),
                          value: _liked,
                          onChanged: (value) {
                            setState(() => _liked = value);
                          },
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('تعليم كمقروء'),
                          secondary: Icon(Icons.check_circle, color: _isRead ? Colors.green : Colors.grey),
                          value: _isRead,
                          onChanged: (value) {
                            setState(() => _isRead = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Send Button
                BlocBuilder<CommentsCubit, CommentsState>(
                  builder: (context, state) {
                    final isLoading = state is CommentReplyLoading;
                    return ElevatedButton.icon(
                      onPressed: isLoading ? null : _sendReply,
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send),
                      label: Text(isLoading ? 'جاري الإرسال...' : 'إرسال الرد'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
