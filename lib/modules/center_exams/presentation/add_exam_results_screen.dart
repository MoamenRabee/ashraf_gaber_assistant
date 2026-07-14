import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/center_exam_entity.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/exam_student_entity.dart';
import 'package:samy_mossad_assistant/modules/center_exams/presentation/cubit/exam_results_cubit.dart';
import 'package:samy_mossad_assistant/modules/center_exams/presentation/cubit/exam_results_state.dart';

class AddExamResultsScreen extends StatefulWidget {
  final CenterExamEntity exam;
  final ExamResultsCubit cubit;

  const AddExamResultsScreen({
    super.key,
    required this.exam,
    required this.cubit,
  });

  @override
  State<AddExamResultsScreen> createState() => _AddExamResultsScreenState();
}

class _AddExamResultsScreenState extends State<AddExamResultsScreen> {
  ExamStudentEntity? selectedStudent;
  final markController = TextEditingController();
  final notesController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    await widget.cubit.loadExamStudents(
      widget.exam.classroomId,
      widget.exam.centerId,
    );
  }

  void _clearForm() {
    setState(() {
      selectedStudent = null;
      markController.clear();
      notesController.clear();
    });
  }

  @override
  void dispose() {
    markController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text('إضافة درجات - ${widget.exam.name}'),
          centerTitle: true,
        ),
        body: BlocListener<ExamResultsCubit, ExamResultsState>(
          listener: (context, state) async {
            if (state is ExamResultsAddSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              _clearForm();
              // Then reload students to exclude the one we just added
              await _loadStudents();
            } else if (state is ExamResultsAddError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Exam Info Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.assignment,
                                color: Colors.orange,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.exam.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'الدرجة الكلية: ${widget.exam.totalMarks}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoChip(
                                  Icons.class_,
                                  widget.exam.classroomName,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildInfoChip(
                                  Icons.location_on,
                                  widget.exam.centerName,
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Select Student Button
                  ElevatedButton.icon(
                    onPressed: () => _showSelectStudentBottomSheet(context),
                    icon: const Icon(Icons.person_search, size: 24),
                    label: Text(
                      selectedStudent == null ? 'اختر الطالب' : 'تغيير الطالب',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Selected Student Card
                  if (selectedStudent != null) ...[
                    Card(
                      elevation: 2,
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue,
                              radius: 30,
                              child: Text(
                                selectedStudent!.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
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
                                    selectedStudent!.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'كود: ${selectedStudent!.code}',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (selectedStudent!.phone != null)
                                    Text(
                                      'هاتف: ${selectedStudent!.phone}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Mark Input
                    TextFormField(
                      controller: markController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'الدرجة *',
                        hintText: 'أدخل الدرجة من ${widget.exam.totalMarks}',
                        prefixIcon: const Icon(
                          Icons.grade,
                          color: Colors.orange,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'من فضلك أدخل الدرجة';
                        }
                        final mark = double.tryParse(value);
                        if (mark == null) {
                          return 'من فضلك أدخل رقم صحيح';
                        }
                        if (mark < 0 || mark > widget.exam.totalMarks) {
                          return 'الدرجة يجب أن تكون بين 0 و ${widget.exam.totalMarks}';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Notes Input
                    TextFormField(
                      controller: notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'ملاحظات (اختياري)',
                        hintText: 'أضف ملاحظات عن أداء الطالب...',
                        prefixIcon: const Icon(
                          Icons.note_alt,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Save Button
                    BlocBuilder<ExamResultsCubit, ExamResultsState>(
                      builder: (context, state) {
                        final isAdding = state is ExamResultsAddingResult;
                        return ElevatedButton.icon(
                          onPressed: isAdding
                              ? null
                              : () {
                                  if (formKey.currentState!.validate()) {
                                    widget.cubit.addResult(
                                      studentId: selectedStudent!.id,
                                      mark: double.parse(markController.text),
                                      notes: notesController.text.isEmpty
                                          ? null
                                          : notesController.text,
                                    );
                                  }
                                },
                          icon: isAdding
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.save, size: 24),
                          label: Text(
                            isAdding ? 'جاري الحفظ...' : 'حفظ الدرجة',
                            style: const TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showSelectStudentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => BlocProvider.value(
        value: widget.cubit,
        child: StatefulBuilder(
          builder: (builderContext, setModalState) {
            final students = widget.cubit.getFilteredStudents();

            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'اختر الطالب',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(bottomSheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Field
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'ابحث بالاسم، الكود أو رقم الهاتف...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        widget.cubit.searchStudents(value);
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Students Count
                  Text(
                    'عدد الطلاب: ${students.length}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),

                  const SizedBox(height: 8),

                  // Students List
                  Expanded(
                    child: students.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_off_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد طلاب متاحين',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'جميع الطلاب لديهم درجات بالفعل',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Text(
                                      student.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    student.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('كود: ${student.code}'),
                                      if (student.phone != null)
                                        Text('هاتف: ${student.phone}'),
                                    ],
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selectedStudent = student;
                                    });
                                    Navigator.pop(bottomSheetContext);
                                  },
                                ),
                              );
                            },
                          ),
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
