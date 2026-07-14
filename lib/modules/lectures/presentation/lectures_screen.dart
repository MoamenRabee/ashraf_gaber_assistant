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
    return BlocProvider(
      create: (context) => di.sl<LecturesCubit>()..loadLectures(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المحاضرات'),
          centerTitle: true,
          actions: [
            BlocBuilder<LecturesCubit, LecturesState>(
              builder: (context, state) {
                if (state is LecturesLoaded) {
                  return IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color:
                          (state.selectedClassroomId != null ||
                              state.selectedCenterId != null ||
                              state.selectedStatus != null ||
                              state.selectedDate != null)
                          ? Colors.blue
                          : null,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                        builder: (dialogContext) => BlocProvider.value(
                          value: BlocProvider.of<LecturesCubit>(context),
                          child: FilterBottomSheet(state: state),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            BlocBuilder<LecturesCubit, LecturesState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: state is LecturesLoading
                      ? null
                      : () {
                          context.read<LecturesCubit>().loadLectures();
                        },
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<LecturesCubit, LecturesState>(
          builder: (context, state) {
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
              if (state.filteredLectures.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('لا توجد محاضرات', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: state.filteredLectures.length,
                itemBuilder: (context, index) {
                  final lecture = state.filteredLectures[index];
                  return _LectureCard(
                    lecture: lecture,
                    onTap: () {
                      if (lecture.status == LectureStatus.pending) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TakeAttendanceScreen(lecture: lecture)));
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
          },
        ),
      ),
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
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
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
  int? selectedClassroomId;
  int? selectedCenterId;
  LectureStatus? selectedStatus;
  String? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedClassroomId = widget.state.selectedClassroomId;
    selectedCenterId = widget.state.selectedCenterId;
    selectedStatus = widget.state.selectedStatus;
    selectedDate = widget.state.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                    selectedClassroomId = null;
                    selectedCenterId = null;
                    selectedStatus = null;
                    selectedDate = null;
                  });
                },
                child: const Text('مسح الكل'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Classroom Filter
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'الصف الدراسي',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.class_),
            ),
            initialValue: selectedClassroomId,
            items: [
              const DropdownMenuItem<int>(value: null, child: Text('الكل')),
              ...widget.state.classrooms.map((classroom) {
                return DropdownMenuItem<int>(value: classroom['id'], child: Text(classroom['name']));
              }),
            ],
            onChanged: (value) {
              setState(() {
                selectedClassroomId = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Center Filter
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'المركز',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            initialValue: selectedCenterId,
            items: [
              const DropdownMenuItem<int>(value: null, child: Text('الكل')),
              ...widget.state.centers.map((center) {
                return DropdownMenuItem<int>(value: center['id'], child: Text(center['name']));
              }),
            ],
            onChanged: (value) {
              setState(() {
                selectedCenterId = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Status Filter
          DropdownButtonFormField<LectureStatus>(
            decoration: const InputDecoration(labelText: 'الحالة', border: OutlineInputBorder(), prefixIcon: Icon(Icons.info)),
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
                  selectedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                });
              }
            },
          ),
          const SizedBox(height: 24),

          // Apply Button
          ElevatedButton(
            onPressed: () {
              context.read<LecturesCubit>().applyFilters(
                classroomId: selectedClassroomId,
                centerId: selectedCenterId,
                status: selectedStatus,
                date: selectedDate,
              );
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
