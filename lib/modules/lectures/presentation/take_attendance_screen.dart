import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:samy_mossad_assistant/core/injection_container.dart' as di;
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/local_attendance_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/absence_dates_sheet.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/student_absence_dialog.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/cubit/take_attendance_cubit.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/cubit/take_attendance_state.dart';
import 'package:samy_mossad_assistant/modules/students/domain/entities/student_entity.dart';

class TakeAttendanceScreen extends StatelessWidget {
  final LectureEntity lecture;

  const TakeAttendanceScreen({super.key, required this.lecture});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<TakeAttendanceCubit>()..loadAttendance(lecture.id),
      child: BlocListener<TakeAttendanceCubit, TakeAttendanceState>(
        listener: (context, state) {
          if (state is TakeAttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is TakeAttendanceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is TakeAttendanceStudentNotFound) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is TakeAttendanceStudentFound) {
            _showStudentConfirmDialog(context, state.student);
          } else if (state is TakeAttendanceAbsenceFound) {
            showStudentAbsenceDialog(context, state.student, state.absence);
          } else if (state is TakeAttendanceAbsenceCheckFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('أخذ الحضور'),
            centerTitle: true,
            actions: [
              BlocBuilder<TakeAttendanceCubit, TakeAttendanceState>(
                builder: (context, state) {
                  if (state is TakeAttendanceLoaded) {
                    final unsyncedCount = state.attendanceList
                        .where((a) => !a.isSynced)
                        .length;
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.sync),
                          onPressed: () {
                            context.read<TakeAttendanceCubit>().syncAttendance(
                              lecture.id,
                            );
                          },
                        ),
                        if (unsyncedCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$unsyncedCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: BlocBuilder<TakeAttendanceCubit, TakeAttendanceState>(
            builder: (context, state) {
              if (state is TakeAttendanceLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is TakeAttendanceError &&
                  state is! TakeAttendanceLoaded) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<TakeAttendanceCubit>().loadAttendance(
                            lecture.id,
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }

              if (state is TakeAttendanceLoaded ||
                  state is TakeAttendanceSuccess ||
                  state is TakeAttendanceError) {
                final loadedState = (state is TakeAttendanceLoaded)
                    ? state
                    : (state is TakeAttendanceSuccess)
                    ? null
                    : null;

                if (loadedState == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: [
                    if (loadedState.checkingAbsenceOf.isNotEmpty)
                      _AbsenceCheckBanner(names: loadedState.checkingAbsenceOf),

                    // Lecture Info Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.school, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  lecture.description,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatCard(
                                icon: Icons.people,
                                label: 'الحضور',
                                value: loadedState.attendanceList.length
                                    .toString(),
                                color: Colors.green,
                              ),
                              _StatCard(
                                icon: Icons.sync_disabled,
                                label: 'غير متزامن',
                                value: loadedState.attendanceList
                                    .where((a) => !a.isSynced)
                                    .length
                                    .toString(),
                                color: Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showQRScanner(context),
                              icon: const Icon(Icons.qr_code_scanner),
                              label: const Text('مسح QR'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showSearchDialog(context),
                              icon: const Icon(Icons.search),
                              label: const Text('بحث يدوي'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showMakeUpSearchDialog(context),
                              icon: const Icon(Icons.swap_horiz),
                              label: const Text('تعويض طالب'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showAbsenceDatesSheet(context),
                              icon: const Icon(Icons.event_busy),
                              label: Text(
                                loadedState.checkDates.isEmpty
                                    ? 'فحص الغياب'
                                    : 'فحص الغياب (${loadedState.checkDates.length})',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: loadedState.checkDates.isEmpty
                                    ? Colors.blueGrey
                                    : Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Attendance List
                    Expanded(
                      child: loadedState.attendanceList.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.list_alt,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'لم يتم تسجيل أي حضور بعد',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: loadedState.attendanceList.length,
                              itemBuilder: (context, index) {
                                final attendance =
                                    loadedState.attendanceList[index];
                                return _AttendanceCard(
                                  attendance: attendance,
                                  onDelete: () {
                                    _showDeleteConfirmDialog(
                                      context,
                                      attendance,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _showQRScanner(BuildContext context) {
    final cubit = context.read<TakeAttendanceCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (newContext) => BlocProvider.value(
          value: cubit,
          child: QRScannerScreen(lecture: lecture),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final cubit = context.read<TakeAttendanceCubit>();
    _showSearchSheet(
      context,
      StudentSearchBottomSheet(
        lecture: lecture,
        onStudentSelected: (student) => cubit.addAttendance(student, lecture),
      ),
    );
  }

  void _showMakeUpSearchDialog(BuildContext context) {
    final cubit = context.read<TakeAttendanceCubit>();
    _showSearchSheet(
      context,
      StudentSearchBottomSheet(
        lecture: lecture,
        title: 'تعويض طالب',
        isMakeUp: true,
        onStudentSelected: (student) async {
          final notes = await showDialog<String>(
            context: context,
            builder: (_) => _MakeUpConfirmDialog(student: student),
          );
          if (notes == null) return;
          cubit.addMakeUpStudent(student, lecture, notes: notes);
        },
      ),
    );
  }

  void _showAbsenceDatesSheet(BuildContext context) {
    final cubit = context.read<TakeAttendanceCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          BlocProvider.value(value: cubit, child: const AbsenceDatesSheet()),
    );
  }

  void _showSearchSheet(BuildContext context, Widget sheet) {
    final cubit = context.read<TakeAttendanceCubit>();
    // مسح نتائج البحث القديمة عشان مايظهرش نتائج من بحث تاني
    cubit.clearSearch();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (dialogContext) =>
          BlocProvider.value(value: cubit, child: sheet),
    );
  }

  void _showStudentConfirmDialog(BuildContext context, StudentEntity student) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحضور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الاسم: ${student.name}'),
            Text('الكود: ${student.studentId}'),
            Text('الهاتف: ${student.phone}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TakeAttendanceCubit>().addAttendance(
                student,
                lecture,
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('تسجيل الحضور'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    LocalAttendanceEntity attendance,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الحضور'),
        content: Text(
          'هل تريد حذف حضور ${attendance.studentName}؟'
          '${attendance.isMakeUp ? '\n\nهذا تعويض متسجل على السيرفر، الحذف هنا من الجهاز فقط.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TakeAttendanceCubit>().deleteAttendance(
                attendance.id!,
                lecture.id,
              );
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

/// مؤشر تحميل أثناء فحص غياب الطالب في الخلفية
class _AbsenceCheckBanner extends StatelessWidget {
  final List<String> names;

  const _AbsenceCheckBanner({required this.names});

  @override
  Widget build(BuildContext context) {
    final text = names.length == 1
        ? 'جاري فحص غياب ${names.first}...'
        : 'جاري فحص غياب ${names.length} طلاب...';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final LocalAttendanceEntity attendance;
  final VoidCallback onDelete;

  const _AttendanceCard({required this.attendance, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: attendance.isSynced
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                attendance.isSynced ? Icons.check_circle : Icons.sync_disabled,
                color: attendance.isSynced ? Colors.green : Colors.orange,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          attendance.studentName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (attendance.isMakeUp) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'تعويض',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.badge, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'كود: ${attendance.studentCode}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        attendance.attendedAt,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  final LectureEntity lecture;

  const QRScannerScreen({super.key, required this.lecture});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isProcessing = false;
  bool isTorchOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مسح QR Code'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isTorchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              controller.toggleTorch();
              setState(() {
                isTorchOn = !isTorchOn;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              if (isProcessing) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;

              final String? code = barcodes.first.rawValue;
              if (code == null) return;

              setState(() => isProcessing = true);

              await context.read<TakeAttendanceCubit>().scanQRCode(
                code,
                widget.lecture,
              );

              if (!mounted) return;
              Navigator.pop(context);
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'وجّه الكاميرا نحو QR Code',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _MakeUpConfirmDialog extends StatefulWidget {
  final StudentEntity student;

  const _MakeUpConfirmDialog({required this.student});

  @override
  State<_MakeUpConfirmDialog> createState() => _MakeUpConfirmDialogState();
}

class _MakeUpConfirmDialogState extends State<_MakeUpConfirmDialog> {
  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // اقتراح ملاحظة بسنتر الطالب الأصلي
    notesController.text = 'بيعوض من سنتر ${widget.student.center.name}';
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    return AlertDialog(
      title: const Text('تأكيد التعويض'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الاسم: ${student.name}'),
            Text('الكود: ${student.studentId}'),
            Text('السنتر: ${student.center.name}'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, notesController.text.trim()),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('تسجيل التعويض'),
        ),
      ],
    );
  }
}

class StudentSearchBottomSheet extends StatelessWidget {
  final LectureEntity lecture;
  final String title;

  /// التعويض: بيبحث في كل السناتر (بنفس صف المحاضرة) وبيعرض سنتر الطالب.
  final bool isMakeUp;
  final void Function(StudentEntity student) onStudentSelected;

  const StudentSearchBottomSheet({
    super.key,
    required this.lecture,
    required this.onStudentSelected,
    this.title = 'بحث عن طالب',
    this.isMakeUp = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TakeAttendanceCubit, TakeAttendanceState>(
      builder: (context, state) {
        if (state is! TakeAttendanceLoaded) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'ابحث بالاسم أو رقم الهاتف أو الكود',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  context.read<TakeAttendanceCubit>().searchStudents(
                    value,
                    lecture,
                    anyCenter: isMakeUp,
                  );
                },
              ),
              const SizedBox(height: 16),
              if (state.searchResults.isEmpty && state.searchQuery.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'لا توجد نتائج',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              if (state.searchResults.isNotEmpty)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.searchResults.length,
                    itemBuilder: (context, index) {
                      final student = state.searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            student.name[0],
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(student.name),
                        subtitle: Text(
                          'كود: ${student.studentId} | ${student.phone}'
                          '${isMakeUp ? '\nسنتر: ${student.center.name}' : ''}',
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          onStudentSelected(student);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
