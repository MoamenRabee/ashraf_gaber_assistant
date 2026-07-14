import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samy_mossad_assistant/core/cache_helper.dart';
import 'package:samy_mossad_assistant/core/injection_container.dart' as di;
import 'package:samy_mossad_assistant/modules/auth/data_source/models/user_model.dart';
import 'package:samy_mossad_assistant/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:samy_mossad_assistant/modules/auth/presentation/cubit/auth_state.dart';
import 'package:samy_mossad_assistant/modules/auth/presentation/login_screen.dart';
import 'package:samy_mossad_assistant/modules/students/presentation/students_screen.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/lectures_screen.dart';
import 'package:samy_mossad_assistant/modules/center_exams/presentation/center_exams_screen.dart';
import 'package:samy_mossad_assistant/modules/comments/presentation/comments_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userDataString = CacheHelper.getData(key: 'user_data');
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      setState(() {
        currentUser = UserModel.fromCache(userData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuthCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('تطبيق الاسيستنت'), centerTitle: true),
        body: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthLogoutSuccess) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // User Info Card
                if (currentUser != null) _buildUserInfoCard(context),
                const SizedBox(height: 16),
                // Students Card - Always visible
                SettingsCard(
                  icon: Icons.people,
                  iconColor: Colors.blue,
                  title: 'الطلاب',
                  features: const [
                    'مزامنة الطلاب من الخادم',
                    'عرض وبحث عن الطلاب',
                    'تصفية حسب الصف والمركز',
                  ],
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const StudentsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Lectures Card - Only if can_manage_lectures
                if (currentUser?.canManageLectures ?? false) ...[
                  SettingsCard(
                    icon: Icons.school,
                    iconColor: Colors.green,
                    title: 'المحاضرات',
                    features: const [
                      'عرض جميع المحاضرات',
                      'أخذ الحضور للمحاضرات الجارية',
                      'عرض تفاصيل الحضور للمحاضرات المنتهية',
                    ],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LecturesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                // Local Exams Card - Only if can_manage_local_exams
                if (currentUser?.canManageLocalExams ?? false) ...[
                  SettingsCard(
                    icon: Icons.assignment,
                    iconColor: Colors.orange,
                    title: 'اختبارات السناتر',
                    features: const [
                      'إضافة درجات السناتر',
                      'مراجعة درجات السناتر',
                      'متابعة أداء الطلاب',
                    ],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CenterExamsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                // Comments Card - Only if can_manage_comments
                if (currentUser?.canManageComments ?? false) ...[
                  SettingsCard(
                    icon: Icons.comment,
                    iconColor: Colors.purple,
                    title: 'التعليقات والأسئلة',
                    features: const [
                      'متابعة تعليقات الطلاب',
                      'الرد على أسئلة الطلاب',
                      'إدارة التفاعلات',
                    ],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CommentsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 24,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser!.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentUser!.email,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentUser!.type == 'admin' ? 'مسؤول' : 'مساعد',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                            context.read<AuthCubit>().logout();
                          },
                    icon: state is AuthLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout, size: 18),
                    label: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> features;
  final VoidCallback onTap;

  const SettingsCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.features,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...features.map(
                      (feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: iconColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
