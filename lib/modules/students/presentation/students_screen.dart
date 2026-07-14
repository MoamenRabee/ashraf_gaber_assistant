import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samy_mossad_assistant/core/injection_container.dart' as di;
import 'package:samy_mossad_assistant/modules/students/presentation/cubit/students_cubit.dart';
import 'package:samy_mossad_assistant/modules/students/presentation/cubit/students_state.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _searchController = TextEditingController();
  int? _selectedClassroomId;
  int? _selectedCenterId;
  Timer? _debounce;

  Future<bool> _checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );
  }

  Future<void> _syncStudents(BuildContext context) async {
    final hasInternet = await _checkInternetConnection();

    if (!hasInternet) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }

      return;
    }

    if (context.mounted) {
      context.read<StudentsCubit>().syncStudents();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<StudentsCubit>()..getLocalStudents(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الطلاب'),
          centerTitle: true,
          actions: [
            BlocBuilder<StudentsCubit, StudentsState>(
              builder: (context, state) {
                return TextButton.icon(
                  label: const Text(
                    'تحديث الطلاب',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  icon: const Icon(Icons.refresh),
                  onPressed: state is StudentsSyncing
                      ? null
                      : () {
                          _syncStudents(context);
                        },
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<StudentsCubit, StudentsState>(
          listener: (context, state) {
            if (state is StudentsSyncSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is StudentsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is StudentsSyncing) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('جاري مزامنة الطلاب...'),
                  ],
                ),
              );
            }

            if (state is StudentsLoaded) {
              return Column(
                children: [
                  // Header مع عدد الطلاب
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue.shade50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'إجمالي الطلاب: ${state.totalCount}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'المعروض: ${state.students.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'بحث بالاسم، رقم الهاتف أو الكود...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<StudentsCubit>().searchStudents(
                                    classroomId: _selectedClassroomId,
                                    centerId: _selectedCenterId,
                                  );
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(
                          const Duration(milliseconds: 500),
                          () {
                            context.read<StudentsCubit>().searchStudents(
                              searchQuery: value,
                              classroomId: _selectedClassroomId,
                              centerId: _selectedCenterId,
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Filters
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'الصف الدراسي',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            initialValue: _selectedClassroomId,
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('الكل'),
                              ),
                              ...state.classrooms.map((classroom) {
                                return DropdownMenuItem<int>(
                                  value: classroom['id'],
                                  child: Text(classroom['name']),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedClassroomId = value;
                              });
                              context.read<StudentsCubit>().searchStudents(
                                searchQuery: _searchController.text,
                                classroomId: value,
                                centerId: _selectedCenterId,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'المركز',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            initialValue: _selectedCenterId,
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('الكل'),
                              ),
                              ...state.centers.map((center) {
                                return DropdownMenuItem<int>(
                                  value: center['id'],
                                  child: Text(center['name']),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCenterId = value;
                              });
                              context.read<StudentsCubit>().searchStudents(
                                searchQuery: _searchController.text,
                                classroomId: _selectedClassroomId,
                                centerId: value,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Students List
                  Expanded(
                    child: state.students.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'لا يوجد طلاب',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'اضغط على زر التحديث لمزامنة الطلاب',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: state.students.length,
                            itemBuilder: (context, index) {
                              final student = state.students[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Text(
                                      student.name[0],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
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
                                      const SizedBox(height: 4),
                                      Text('كود: ${student.studentId}'),
                                      Text('هاتف: ${student.phone}'),
                                      Text(
                                        'هاتف ولي الأمر: ${student.parentPhone}',
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              student.classroom.name,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              student.center.name,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            }

            // Initial or Loading state
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
