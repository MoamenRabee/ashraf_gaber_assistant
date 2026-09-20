import 'package:flutter/material.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/student_absence_entity.dart';
import 'package:samy_mossad_assistant/modules/students/domain/entities/student_entity.dart';

Future<void> showStudentAbsenceDialog(
  BuildContext context,
  StudentEntity student,
  StudentAbsenceEntity absence,
) {
  return showDialog(
    context: context,
    builder: (_) => _StudentAbsenceDialog(student: student, absence: absence),
  );
}

class _StudentAbsenceDialog extends StatelessWidget {
  final StudentEntity student;
  final StudentAbsenceEntity absence;

  const _StudentAbsenceDialog({required this.student, required this.absence});

  @override
  Widget build(BuildContext context) {
    final summary = absence.historySummary;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
          const SizedBox(width: 8),
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
                Text(
                  'كود: ${student.studentId}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StudentInfo(student: student),
              if (absence.message != null && absence.message!.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    absence.message!,
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (absence.absentDates.isNotEmpty)
                _Section(
                  title: 'تواريخ الغياب',
                  child: _DateChips(
                    dates: absence.absentDates,
                    color: Colors.red,
                  ),
                ),
              if (absence.datesWithoutLecture.isNotEmpty)
                _Section(
                  title: 'تواريخ ليس بها محاضرة لهذا الصف والسنتر',
                  child: _DateChips(
                    dates: absence.datesWithoutLecture,
                    color: Colors.grey,
                  ),
                ),
              if (absence.checkedLectures.isNotEmpty)
                _Section(
                  title: 'المحاضرات المطلوبة',
                  child: Column(
                    children: absence.checkedLectures
                        .map((lecture) => _LectureTile(lecture: lecture))
                        .toList(),
                  ),
                ),
              if (absence.history.isNotEmpty)
                _Section(
                  title: 'سجل الطالب',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (summary != null) _SummaryRow(summary: summary),
                      ...absence.history.map(
                        (lecture) => _LectureTile(lecture: lecture),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}

class _StudentInfo extends StatelessWidget {
  final StudentEntity student;

  const _StudentInfo({required this.student});

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.grey[600])),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _row(Icons.phone, 'الهاتف', student.phone),
          _row(Icons.family_restroom, 'هاتف ولي الأمر', student.parentPhone),
          _row(Icons.class_, 'الصف', student.classroom.name),
          _row(Icons.location_on, 'السنتر', student.center.name),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _DateChips extends StatelessWidget {
  final List<String> dates;
  final MaterialColor color;

  const _DateChips({required this.dates, required this.color});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: dates
          .map(
            (date) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.shade50,
                border: Border.all(color: color.shade200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                date,
                style: TextStyle(
                  color: color.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final HistorySummaryEntity summary;

  const _SummaryRow({required this.summary});

  Widget _item(String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _item('الإجمالي', summary.total, Colors.blue),
          _item('حضر', summary.attended, Colors.green),
          _item('غاب', summary.notAttended, Colors.red),
          _item('بدون سجل', summary.notRecorded, Colors.grey),
        ],
      ),
    );
  }
}

class _LectureTile extends StatelessWidget {
  final AbsenceLectureEntity lecture;

  const _LectureTile({required this.lecture});

  String _hourMinute(String value) {
    // "10:00:00" -> "10:00"
    return value.length >= 5 ? value.substring(0, 5) : value;
  }

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;
    final String statusText;
    if (lecture.isAttended) {
      color = Colors.green;
      icon = Icons.check_circle;
      statusText = 'حضر';
    } else if (lecture.isAbsent) {
      color = Colors.red;
      icon = Icons.cancel;
      statusText = 'غاب';
    } else {
      color = Colors.grey;
      icon = Icons.help_outline;
      statusText = 'بدون سجل';
    }

    final attendedAt = lecture.attendedAt;
    final attendedTime = lecture.isAttended && attendedAt != null
        ? _hourMinute(attendedAt.split(' ').last)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lecture.description,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  '${lecture.date} • ${_hourMinute(lecture.time)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (attendedTime != null)
                  Text(
                    'وقت الحضور: $attendedTime',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                if (lecture.notes != null && lecture.notes!.isNotEmpty)
                  Text(
                    lecture.notes!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Badge(text: statusText, color: color),
              if (lecture.isMakeUp) ...[
                const SizedBox(height: 4),
                const _Badge(text: 'تعويض', color: Colors.orange),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
