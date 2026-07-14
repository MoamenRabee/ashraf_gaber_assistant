import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samy_mossad_assistant/core/injection_container.dart' as di;
import 'package:samy_mossad_assistant/modules/center_exams/presentation/cubit/center_exams_cubit.dart';
import 'package:samy_mossad_assistant/modules/center_exams/presentation/cubit/center_exams_state.dart';
import 'package:samy_mossad_assistant/modules/center_exams/presentation/exam_results_screen.dart';

class CenterExamsScreen extends StatelessWidget {
  const CenterExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<CenterExamsCubit>()..loadCenterExams(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اختبارات السناتر'),
          centerTitle: true,
          actions: [
            BlocBuilder<CenterExamsCubit, CenterExamsState>(
              builder: (context, state) {
                if (state is CenterExamsLoaded &&
                    (state.selectedClassroomId != null ||
                        state.selectedCenterId != null ||
                        state.searchQuery.isNotEmpty)) {
                  return IconButton(
                    onPressed: () {
                      context.read<CenterExamsCubit>().clearFilters();
                    },
                    icon: const Icon(Icons.clear_all),
                    tooltip: 'مسح الفلاتر',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<CenterExamsCubit, CenterExamsState>(
          builder: (context, state) {
            if (state is CenterExamsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CenterExamsNoInternet) {
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
                      'يجب توفر الاتصال بالإنترنت لعرض الامتحانات',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<CenterExamsCubit>().loadCenterExams();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (state is CenterExamsError) {
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
                        context.read<CenterExamsCubit>().loadCenterExams();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (state is CenterExamsLoaded) {
              return Column(
                children: [
                  // Search & Filter Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[100],
                    child: Column(
                      children: [
                        // Search Bar
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'ابحث عن امتحان...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) {
                            context.read<CenterExamsCubit>().searchExams(value);
                          },
                        ),
                        const SizedBox(height: 12),
                        // Filter Chips
                        Row(
                          children: [
                            Expanded(
                              child: _buildFilterChip(
                                context,
                                icon: Icons.class_,
                                label: state.selectedClassroomId == null
                                    ? 'الصف الدراسي'
                                    : context
                                          .read<CenterExamsCubit>()
                                          .getClassrooms()
                                          .firstWhere(
                                            (c) =>
                                                c['id'] ==
                                                state.selectedClassroomId,
                                          )['name'],
                                onTap: () => _showClassroomFilter(context),
                                isSelected: state.selectedClassroomId != null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildFilterChip(
                                context,
                                icon: Icons.location_on,
                                label: state.selectedCenterId == null
                                    ? 'السنتر'
                                    : context
                                          .read<CenterExamsCubit>()
                                          .getCenters()
                                          .firstWhere(
                                            (c) =>
                                                c['id'] ==
                                                state.selectedCenterId,
                                          )['name'],
                                onTap: () => _showCenterFilter(context),
                                isSelected: state.selectedCenterId != null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Exams List
                  Expanded(
                    child: state.filteredExams.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'لا توجد امتحانات',
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
                            itemCount: state.filteredExams.length,
                            itemBuilder: (context, index) {
                              final exam = state.filteredExams[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ExamResultsScreen(exam: exam),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.assignment,
                                                color: Colors.orange,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    exam.name,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'الدرجة الكلية: ${exam.totalMarks}',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            _buildInfoChip(
                                              Icons.class_,
                                              exam.classroomName,
                                              Colors.blue,
                                            ),
                                            const SizedBox(width: 8),
                                            _buildInfoChip(
                                              Icons.location_on,
                                              exam.centerName,
                                              Colors.green,
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
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showClassroomFilter(BuildContext context) {
    final cubit = context.read<CenterExamsCubit>();
    final classrooms = cubit.getClassrooms();
    final state = cubit.state as CenterExamsLoaded;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'اختر الصف الدراسي',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: classrooms
                      .map(
                        (classroom) => ListTile(
                          leading: const Icon(Icons.class_, color: Colors.blue),
                          title: Text(classroom['name']),
                          trailing: state.selectedClassroomId == classroom['id']
                              ? const Icon(Icons.check, color: Colors.blue)
                              : null,
                          onTap: () {
                            cubit.filterExams(
                              classroomId: classroom['id'],
                              centerId: state.selectedCenterId,
                            );
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCenterFilter(BuildContext context) {
    final cubit = context.read<CenterExamsCubit>();
    final centers = cubit.getCenters();
    final state = cubit.state as CenterExamsLoaded;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'اختر السنتر',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: centers
                      .map(
                        (center) => ListTile(
                          leading: const Icon(
                            Icons.location_on,
                            color: Colors.green,
                          ),
                          title: Text(center['name']),
                          trailing: state.selectedCenterId == center['id']
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () {
                            cubit.filterExams(
                              classroomId: state.selectedClassroomId,
                              centerId: center['id'],
                            );
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
