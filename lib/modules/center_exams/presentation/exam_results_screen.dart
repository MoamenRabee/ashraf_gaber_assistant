import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samy_mossad_assistant/core/injection_container.dart' as di;
import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/center_exam_entity.dart';
import 'package:samy_mossad_assistant/modules/center_exams/presentation/add_exam_results_screen.dart';
import 'package:samy_mossad_assistant/modules/center_exams/presentation/cubit/exam_results_cubit.dart';
import 'package:samy_mossad_assistant/modules/center_exams/presentation/cubit/exam_results_state.dart';
import 'package:url_launcher/url_launcher.dart';

class ExamResultsScreen extends StatelessWidget {
  final CenterExamEntity exam;

  const ExamResultsScreen({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ExamResultsCubit(di.sl(), di.sl(), di.sl(), di.sl(), exam.id)
            ..loadExamResults(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(exam.name),
          centerTitle: true,
          actions: [
            BlocBuilder<ExamResultsCubit, ExamResultsState>(
              builder: (context, state) {
                if (state is ExamResultsLoaded) {
                  return PopupMenuButton<SortType>(
                    icon: const Icon(Icons.sort),
                    tooltip: 'ترتيب',
                    onSelected: (sortType) {
                      context.read<ExamResultsCubit>().sortResults(sortType);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: SortType.highToLow,
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_downward,
                              size: 20,
                              color: state.sortType == SortType.highToLow
                                  ? Colors.orange
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            const Text('من الأعلى للأقل'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: SortType.lowToHigh,
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_upward,
                              size: 20,
                              color: state.sortType == SortType.lowToHigh
                                  ? Colors.orange
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            const Text('من الأقل للأعلى'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: SortType.alphabetical,
                        child: Row(
                          children: [
                            Icon(
                              Icons.sort_by_alpha,
                              size: 20,
                              color: state.sortType == SortType.alphabetical
                                  ? Colors.orange
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            const Text('ترتيب أبجدي'),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Builder(
              builder: (context) => IconButton(
                onPressed: () {
                  context.read<ExamResultsCubit>().loadExamResults();
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'تحديث',
              ),
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () async {
              final cubit = context.read<ExamResultsCubit>();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddExamResultsScreen(exam: exam, cubit: cubit),
                ),
              );
              // Refresh results when returning from add screen
              if (context.mounted) {
                cubit.loadExamResults();
              }
            },
            child: const Icon(Icons.add),
          ),
        ),
        body: BlocListener<ExamResultsCubit, ExamResultsState>(
          listener: (context, state) {
            if (state is ExamResultsAddError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<ExamResultsCubit, ExamResultsState>(
            builder: (context, state) {
              if (state is ExamResultsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ExamResultsError) {
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
                          context.read<ExamResultsCubit>().loadExamResults();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }

              if (state is ExamResultsLoaded) {
                return Column(
                  children: [
                    // Exam Info Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            'الدرجة الكلية',
                            exam.totalMarks.toString(),
                            Colors.orange,
                          ),
                          _buildStatColumn(
                            'عدد الطلاب',
                            state.allResults.length.toString(),
                            Colors.blue,
                          ),
                          _buildStatColumn(
                            'المتوسط',
                            state.allResults.isEmpty
                                ? '0'
                                : (state.allResults
                                              .map((r) => r.mark)
                                              .reduce((a, b) => a + b) /
                                          state.allResults.length)
                                      .toStringAsFixed(1),
                            Colors.green,
                          ),
                        ],
                      ),
                    ),

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'ابحث بالاسم أو الكود أو الهاتف',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          context.read<ExamResultsCubit>().searchResults(value);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Results List
                    Expanded(
                      child: state.filteredResults.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_off_outlined,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'لا توجد نتائج',
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
                              itemCount: state.filteredResults.length,
                              itemBuilder: (context, index) {
                                final result = state.filteredResults[index];
                                final percentage =
                                    (result.mark / exam.totalMarks * 100);

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      _showResultDetails(
                                        context,
                                        result,
                                        exam.totalMarks,
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          // Rank Badge
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: _getRankColor(percentage),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),

                                          // Student Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  result.studentName,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'كود: ${result.studentCode}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Mark
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${result.mark.toStringAsFixed(1)}',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: _getRankColor(
                                                    percentage,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'من ${exam.totalMarks}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getRankColor(double percentage) {
    if (percentage >= 85) return Colors.green;
    if (percentage >= 65) return Colors.blue;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  void _showResultDetails(BuildContext context, result, int totalMarks) {
    final percentage = (result.mark / totalMarks * 100);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getRankColor(percentage),
                  radius: 30,
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.studentName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'كود: ${result.studentCode}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow(
              Icons.grade,
              'الدرجة',
              '${result.mark.toStringAsFixed(1)} من $totalMarks',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.phone, 'رقم الطالب', result.studentPhone),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.phone_android,
              'رقم ولي الأمر',
              result.parentPhone,
            ),
            if (result.notes != null && result.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRow(Icons.note, 'ملاحظات', result.notes!),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _makePhoneCall(context, result.studentPhone),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('اتصال بالطالب'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _makePhoneCall(context, result.parentPhone),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('اتصال بولي الأمر'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: 20),
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

  void _makePhoneCall(BuildContext context, String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن فتح تطبيق الهاتف')),
        );
      }
    }
  }
}
