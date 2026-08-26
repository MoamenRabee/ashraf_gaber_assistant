import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:samy_mossad_assistant/core/injection_container.dart' as di;
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_student_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/cubit/lecture_students_cubit.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/cubit/lecture_students_state.dart';

class AttendanceDetailsScreen extends StatelessWidget {
  final LectureEntity lecture;

  const AttendanceDetailsScreen({super.key, required this.lecture});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<LectureStudentsCubit>()..loadLectureStudents(lecture.id),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('تفاصيل الحضور'),
            centerTitle: true,
            bottom: const TabBar(
              tabs: [
                Tab(text: 'الكل'),
                Tab(text: 'الحاضرين'),
                Tab(text: 'الغائبين'),
              ],
            ),
          ),
          body: BlocBuilder<LectureStudentsCubit, LectureStudentsState>(
            builder: (context, state) {
              if (state is LectureStudentsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is LectureStudentsNoInternet) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'لا يوجد اتصال بالإنترنت',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'يجب توفر الاتصال بالإنترنت لعرض التفاصيل',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context
                              .read<LectureStudentsCubit>()
                              .loadLectureStudents(lecture.id);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }

              if (state is LectureStudentsError) {
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
                          context
                              .read<LectureStudentsCubit>()
                              .loadLectureStudents(lecture.id);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }

              if (state is LectureStudentsLoaded) {
                return Column(
                  children: [
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
                                label: 'الإجمالي',
                                value: state.students.length.toString(),
                                color: Colors.blue,
                              ),
                              _StatCard(
                                icon: Icons.check_circle,
                                label: 'الحاضرين',
                                value: state.attendedStudents.length.toString(),
                                color: Colors.green,
                              ),
                              _StatCard(
                                icon: Icons.cancel,
                                label: 'الغائبين',
                                value: state.notAttendedStudents.length
                                    .toString(),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'ابحث بالاسم أو رقم الهاتف أو الكود',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          context.read<LectureStudentsCubit>().searchStudents(
                            value,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // TabBarView
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildStudentsList(context, state.filteredStudents),
                          _buildStudentsList(context, state.attendedStudents),
                          _buildStudentsList(
                            context,
                            state.notAttendedStudents,
                          ),
                        ],
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

  Widget _buildStudentsList(
    BuildContext context,
    List<LectureStudentEntity> students,
  ) {
    if (students.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return _StudentCard(
          student: student,
          lecture: lecture,
          onTap: () {
            _showStudentDetailsBottomSheet(context, student);
          },
        );
      },
    );
  }

  void _showStudentDetailsBottomSheet(
    BuildContext context,
    LectureStudentEntity student,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          StudentDetailsBottomSheet(student: student, lecture: lecture),
    );
  }
}

const _whatsappGreen = Color(0xFF25D366);

String _normalizePhoneForWhatsApp(String phone) {
  var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('0')) {
    digits = '20${digits.substring(1)}';
  } else if (!digits.startsWith('20')) {
    digits = '20$digits';
  }
  return digits;
}

String _buildAttendanceMessage(
  LectureEntity lecture,
  LectureStudentEntity student, {
  required bool toParent,
}) {
  final isAttended = student.attendance.isAttended;
  if (toParent) {
    return isAttended
        ? 'السلام عليكم، ولي أمر الطالب/ة ${student.name}\n'
              'نفيدكم بأنه تم تسجيل حضور الطالب/ة ${student.name} '
              'في محاضرة "${lecture.description}" بتاريخ ${lecture.date}.'
        : 'السلام عليكم، ولي أمر الطالب/ة ${student.name}\n'
              'نفيدكم بأنه تم تسجيل غياب الطالب/ة ${student.name} '
              'عن محاضرة "${lecture.description}" بتاريخ ${lecture.date}.\n'
              'برجاء المتابعة والتواصل معنا.';
  }
  return isAttended
      ? 'السلام عليكم ${student.name}\n'
            'نفيدك بأنه تم تسجيل حضورك في محاضرة "${lecture.description}" '
            'بتاريخ ${lecture.date}.'
      : 'السلام عليكم ${student.name}\n'
            'نفيدك بأنه تم تسجيل غيابك عن محاضرة "${lecture.description}" '
            'بتاريخ ${lecture.date}.\n'
            'برجاء التواصل لمعرفة السبب ومتابعة الشرح.';
}

Future<void> _sendWhatsAppReport(
  BuildContext context,
  LectureEntity lecture,
  LectureStudentEntity student, {
  required bool toParent,
}) async {
  final phone = toParent ? student.parentPhone : student.phone;
  final message = _buildAttendanceMessage(lecture, student, toParent: toParent);
  final uri = Uri.parse(
    'https://wa.me/${_normalizePhoneForWhatsApp(phone)}'
    '?text=${Uri.encodeComponent(message)}',
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن فتح تطبيق واتساب')),
      );
    }
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

class _StudentCard extends StatelessWidget {
  final LectureStudentEntity student;
  final LectureEntity lecture;
  final VoidCallback onTap;

  const _StudentCard({
    required this.student,
    required this.lecture,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAttended = student.attendance.isAttended;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isAttended ? Colors.green.shade50 : Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAttended ? Icons.check_circle : Icons.cancel,
                  color: isAttended ? Colors.green : Colors.red,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.badge, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'كود: ${student.studentId}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          student.phone,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (student.attendance.attendedAt != null) ...[
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
                            student.attendance.attendedAt!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (lecture.status == LectureStatus.ended)
                PopupMenuButton<bool>(
                  icon: const Icon(Icons.chat, color: _whatsappGreen),
                  tooltip: 'إرسال تقرير واتساب',
                  onSelected: (toParent) => _sendWhatsAppReport(
                    context,
                    lecture,
                    student,
                    toParent: toParent,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: false,
                      child: Text('إرسال للطالب'),
                    ),
                    const PopupMenuItem(
                      value: true,
                      child: Text('إرسال لولي الأمر'),
                    ),
                  ],
                )
              else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentDetailsBottomSheet extends StatelessWidget {
  final LectureStudentEntity student;
  final LectureEntity lecture;

  const StudentDetailsBottomSheet({
    super.key,
    required this.student,
    required this.lecture,
  });

  @override
  Widget build(BuildContext context) {
    final isAttended = student.attendance.isAttended;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isAttended ? Colors.green.shade50 : Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAttended ? Icons.check_circle : Icons.cancel,
                  color: isAttended ? Colors.green : Colors.red,
                  size: 35,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isAttended ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isAttended ? 'حاضر' : 'غائب',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _DetailRow(
            icon: Icons.badge,
            label: 'كود الطالب',
            value: student.studentId.toString(),
          ),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.phone,
            label: 'رقم الطالب',
            value: student.phone,
          ),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.phone_android,
            label: 'رقم ولي الأمر',
            value: student.parentPhone,
          ),
          if (student.attendance.attendedAt != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.access_time,
              label: 'وقت الحضور',
              value: student.attendance.attendedAt!,
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _makePhoneCall(context, student.phone),
                  icon: const Icon(Icons.phone),
                  label: const Text('اتصال بالطالب'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _makePhoneCall(context, student.parentPhone),
                  icon: const Icon(Icons.phone),
                  label: const Text('اتصال بولي الأمر'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          if (lecture.status == LectureStatus.ended) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendWhatsAppReport(
                      context,
                      lecture,
                      student,
                      toParent: false,
                    ),
                    icon: const Icon(Icons.chat),
                    label: Text(
                      isAttended ? 'إرسال حضور للطالب' : 'إرسال غياب للطالب',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _whatsappGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendWhatsAppReport(
                      context,
                      lecture,
                      student,
                      toParent: true,
                    ),
                    icon: const Icon(Icons.chat),
                    label: Text(
                      isAttended
                          ? 'إرسال حضور لولي الأمر'
                          : 'إرسال غياب لولي الأمر',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _whatsappGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _makePhoneCall(BuildContext context, String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // ignore: use_build_context_synchronously
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن فتح تطبيق الهاتف')),
        );
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
