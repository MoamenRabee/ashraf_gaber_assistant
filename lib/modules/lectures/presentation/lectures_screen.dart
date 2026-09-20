import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samy_mossad_assistant/core/injection_container.dart' as di;
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/cubit/lectures_cubit.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/cubit/lectures_state.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/take_attendance_screen.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/attendance_details_screen.dart';

class LecturesScreen extends StatelessWidget {
  const LecturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => di.sl<LecturesCubit>()..loadLectures(), child: const _LecturesView());
  }
}

class _LecturesView extends StatelessWidget {
  const _LecturesView();

  String _title(LecturesLoaded? state) {
    final center = state?.selectedCenterName;
    final classroom = state?.selectedClassroomName;
    if (center == null) return 'المحاضرات';
    if (classroom == null) return center;
    return '$center - $classroom';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LecturesCubit, LecturesState>(
      builder: (context, state) {
        final loaded = state is LecturesLoaded ? state : null;
        final canGoBack = loaded?.selectedCenterId != null;

        return PopScope(
          canPop: !canGoBack,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) context.read<LecturesCubit>().goBack();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(_title(loaded)),
              centerTitle: true,
              leading: canGoBack ? BackButton(onPressed: () => context.read<LecturesCubit>().goBack()) : null,
              actions: [
                // فلتر الحالة والتاريخ متاح فقط داخل قائمة المحاضرات
                if (loaded != null && loaded.selectedClassroomId != null)
                  IconButton(
                    icon: Icon(Icons.filter_list, color: loaded.hasActiveFilters ? Colors.blue : null),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (dialogContext) => BlocProvider.value(
                          value: BlocProvider.of<LecturesCubit>(context),
                          child: FilterBottomSheet(state: loaded),
                        ),
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: state is LecturesLoading ? null : () => context.read<LecturesCubit>().loadLectures(),
                ),
              ],
            ),
            body: _buildBody(context, state),
            floatingActionButton: loaded == null
                ? null
                : FloatingActionButton.extended(
                    onPressed: () => _showAddLectureSheet(context, loaded),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة محاضرة'),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _showAddLectureSheet(BuildContext context, LecturesLoaded state) async {
    final cubit = context.read<LecturesCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: AddLectureSheet(initialCenterId: state.selectedCenterId, initialClassroomId: state.selectedClassroomId),
      ),
    );

    if (created == true) {
      messenger.showSnackBar(const SnackBar(content: Text('تمت إضافة المحاضرة'), backgroundColor: Colors.green));
    }
  }

  Widget _buildBody(BuildContext context, LecturesState state) {
    if (state is LecturesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is LecturesNoInternet) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('لا يوجد اتصال بالإنترنت', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('يرجى التحقق من اتصالك والمحاولة مرة أخرى', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<LecturesCubit>().loadLectures();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state is LecturesError) {
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
                context.read<LecturesCubit>().loadLectures();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state is LecturesLoaded) {
      if (state.lectures.isEmpty) {
        return const _EmptyView(message: 'لا توجد محاضرات');
      }

      // المستوى الأول: السناتر
      if (state.selectedCenterId == null) {
        return _SelectionList(
          items: state.centers,
          icon: Icons.location_on,
          color: Colors.green,
          onSelected: (id) => context.read<LecturesCubit>().selectCenter(id),
        );
      }

      // المستوى الثاني: صفوف السنتر المختار
      if (state.selectedClassroomId == null) {
        return _SelectionList(
          items: state.classrooms,
          icon: Icons.class_,
          color: Colors.blue,
          onSelected: (id) => context.read<LecturesCubit>().selectClassroom(id),
        );
      }

      // المستوى الثالث: محاضرات السنتر والصف
      if (state.filteredLectures.isEmpty) {
        return const _EmptyView(message: 'لا توجد محاضرات');
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
        itemCount: state.filteredLectures.length,
        itemBuilder: (context, index) {
          final lecture = state.filteredLectures[index];
          return _LectureCard(
            lecture: lecture,
            onTap: () {
              if (lecture.status == LectureStatus.pending) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TakeAttendanceScreen(lecture: lecture)),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AttendanceDetailsScreen(lecture: lecture)),
                );
              }
            },
          );
        },
      );
    }

    return const SizedBox();
  }
}

class _EmptyView extends StatelessWidget {
  final String message;

  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}

/// قائمة اختيار (سناتر أو صفوف) مع عدد المحاضرات لكل عنصر.
class _SelectionList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final IconData icon;
  final Color color;
  final ValueChanged<int> onSelected;

  const _SelectionList({required this.items, required this.icon, required this.color, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color),
            ),
            title: Text(item['name'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Text('${item['count']} محاضرة'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => onSelected(item['id'] as int),
          ),
        );
      },
    );
  }
}

class _LectureCard extends StatelessWidget {
  final LectureEntity lecture;
  final VoidCallback onTap;

  const _LectureCard({required this.lecture, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPending = lecture.status == LectureStatus.pending;
    final statusColor = isPending ? Colors.orange : Colors.green;
    final statusIcon = isPending ? Icons.pending : Icons.check_circle;
    final statusText = isPending ? 'جاري' : 'منتهية';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lecture.description, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            statusText,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'end') {
                        _showEndLectureDialog(context, lecture);
                      } else if (value == 'reopen') {
                        _showReopenLectureDialog(context, lecture);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      if (isPending) {
                        return [
                          const PopupMenuItem<String>(
                            value: 'end',
                            child: Row(
                              children: [
                                Icon(Icons.stop_circle, color: Colors.red),
                                SizedBox(width: 8),
                                Text('إنهاء المحاضرة'),
                              ],
                            ),
                          ),
                        ];
                      } else {
                        return [
                          const PopupMenuItem<String>(
                            value: 'reopen',
                            child: Row(
                              children: [
                                Icon(Icons.restart_alt, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('إعادة فتح المحاضرة'),
                              ],
                            ),
                          ),
                        ];
                      }
                    },
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _InfoRow(icon: Icons.class_, text: lecture.classroom.name, color: Colors.blue),
                  ),
                  Expanded(
                    child: _InfoRow(icon: Icons.location_on, text: lecture.center.name, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _InfoRow(icon: Icons.calendar_today, text: lecture.date, color: Colors.purple),
                  ),
                  Expanded(
                    child: _InfoRow(icon: Icons.access_time, text: lecture.time, color: Colors.orange),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEndLectureDialog(BuildContext context, LectureEntity lecture) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('إنهاء المحاضرة'),
          content: Text(
            'هل أنت متأكد من إنهاء محاضرة "${lecture.description}"؟\n\nسيتم تفعيل الفيديوهات وتسجيل الغياب للطلاب الذين لم يحضروا.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<LecturesCubit>().endLecture(lecture.id);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري إنهاء المحاضرة...')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('إنهاء'),
            ),
          ],
        );
      },
    );
  }

  void _showReopenLectureDialog(BuildContext context, LectureEntity lecture) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('إعادة فتح المحاضرة'),
          content: Text(
            'هل أنت متأكد من إعادة فتح محاضرة "${lecture.description}"؟\n\nسيتم تعطيل الفيديوهات ويمكنك تعديل الحضور مرة أخرى.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<LecturesCubit>().reopenLecture(lecture.id);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري إعادة فتح المحاضرة...')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              child: const Text('إعادة الفتح'),
            ),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoRow({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final LecturesLoaded state;

  const FilterBottomSheet({super.key, required this.state});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  LectureStatus? selectedStatus;
  String? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.state.selectedStatus;
    selectedDate = widget.state.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('تصفية المحاضرات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedStatus = null;
                    selectedDate = null;
                  });
                },
                child: const Text('مسح الكل'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Status Filter
          DropdownButtonFormField<LectureStatus>(
            decoration: const InputDecoration(
              labelText: 'الحالة',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.info),
            ),
            initialValue: selectedStatus,
            items: const [
              DropdownMenuItem<LectureStatus>(value: null, child: Text('الكل')),
              DropdownMenuItem<LectureStatus>(value: LectureStatus.pending, child: Text('جاري')),
              DropdownMenuItem<LectureStatus>(value: LectureStatus.ended, child: Text('منتهية')),
            ],
            onChanged: (value) {
              setState(() {
                selectedStatus = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Date Filter
          TextFormField(
            decoration: InputDecoration(
              labelText: 'التاريخ',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.calendar_today),
              suffixIcon: selectedDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          selectedDate = null;
                        });
                      },
                    )
                  : null,
            ),
            readOnly: true,
            controller: TextEditingController(text: selectedDate ?? ''),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate != null ? DateTime.parse(selectedDate!) : DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                setState(() {
                  selectedDate =
                      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                });
              }
            },
          ),
          const SizedBox(height: 24),

          // Apply Button
          ElevatedButton(
            onPressed: () {
              context.read<LecturesCubit>().applyFilters(status: selectedStatus, date: selectedDate);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('تطبيق الفلتر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class AddLectureSheet extends StatefulWidget {
  final int? initialCenterId;
  final int? initialClassroomId;

  const AddLectureSheet({super.key, this.initialCenterId, this.initialClassroomId});

  @override
  State<AddLectureSheet> createState() => _AddLectureSheetState();
}

class _AddLectureSheetState extends State<AddLectureSheet> {
  final TextEditingController descriptionController = TextEditingController();
  late final Future<({List<Map<String, dynamic>> centers, List<Map<String, dynamic>> classrooms})> optionsFuture;

  int? selectedCenterId;
  int? selectedClassroomId;
  DateTime? selectedDate = DateTime.now();
  TimeOfDay? selectedTime;
  bool isSubmitting = false;
  String? error;

  @override
  void initState() {
    super.initState();
    optionsFuture = context.read<LecturesCubit>().getLectureFormOptions();
    selectedCenterId = widget.initialCenterId;
    selectedClassroomId = widget.initialClassroomId;
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(context: context, initialTime: selectedTime ?? TimeOfDay.now());
    if (time != null) setState(() => selectedTime = time);
  }

  Future<void> _submit() async {
    final description = descriptionController.text.trim();
    if (description.isEmpty ||
        selectedCenterId == null ||
        selectedClassroomId == null ||
        selectedDate == null ||
        selectedTime == null) {
      setState(() => error = 'من فضلك املأ كل البيانات');
      return;
    }

    setState(() {
      isSubmitting = true;
      error = null;
    });

    final message = await context.read<LecturesCubit>().createLecture(
      description: description,
      classroomId: selectedClassroomId!,
      centerId: selectedCenterId!,
      date: _formatDate(selectedDate!),
      time: _formatTime(selectedTime!),
    );

    if (!mounted) return;
    if (message == null) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        isSubmitting = false;
        error = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isSubmitting,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: FutureBuilder(
          future: optionsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()));
            }
            final options = snapshot.data!;

            // ما نحطش قيمة مبدئية مش موجودة في القائمة
            final centerId = options.centers.any((c) => c['id'] == selectedCenterId) ? selectedCenterId : null;
            final classroomId = options.classrooms.any((c) => c['id'] == selectedClassroomId)
                ? selectedClassroomId
                : null;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('إضافة محاضرة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: descriptionController,
                    enabled: !isSubmitting,
                    decoration: const InputDecoration(
                      labelText: 'وصف المحاضرة',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'المركز',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    initialValue: centerId,
                    items: options.centers
                        .map((c) => DropdownMenuItem<int>(value: c['id'] as int, child: Text(c['name'] as String)))
                        .toList(),
                    onChanged: isSubmitting ? null : (value) => setState(() => selectedCenterId = value),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'الصف الدراسي',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.class_),
                    ),
                    initialValue: classroomId,
                    items: options.classrooms
                        .map((c) => DropdownMenuItem<int>(value: c['id'] as int, child: Text(c['name'] as String)))
                        .toList(),
                    onChanged: isSubmitting ? null : (value) => setState(() => selectedClassroomId = value),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isSubmitting ? null : _pickDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(selectedDate == null ? 'التاريخ' : _formatDate(selectedDate!)),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isSubmitting ? null : _pickTime,
                          icon: const Icon(Icons.access_time),
                          label: Text(selectedTime == null ? 'الوقت' : _formatTime(selectedTime!)),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        ),
                      ),
                    ],
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('إضافة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
