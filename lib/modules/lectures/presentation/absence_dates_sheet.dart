import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/cubit/take_attendance_cubit.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/cubit/take_attendance_state.dart';

/// إدارة تواريخ فحص الغياب: إضافة، حذف تاريخ، أو reset لكل التواريخ.
class AbsenceDatesSheet extends StatelessWidget {
  const AbsenceDatesSheet({super.key});

  Future<void> _pickDate(BuildContext context) async {
    final cubit = context.read<TakeAttendanceCubit>();
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date != null) cubit.addCheckDate(date);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TakeAttendanceCubit, TakeAttendanceState>(
      buildWhen: (_, state) => state is TakeAttendanceLoaded,
      builder: (context, state) {
        final dates = context.read<TakeAttendanceCubit>().checkDates;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'تواريخ فحص الغياب',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: dates.isEmpty
                          ? null
                          : () => context
                                .read<TakeAttendanceCubit>()
                                .resetCheckDates(),
                      child: const Text('مسح الكل'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'عند تسجيل حضور أي طالب (بالمسح أو يدوي) والإنترنت شغال، '
                  'هيتم فحص غيابه في التواريخ دي.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                if (dates.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'لم تتم إضافة تواريخ',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: dates
                        .map(
                          (date) => Chip(
                            label: Text(date),
                            onDeleted: () => context
                                .read<TakeAttendanceCubit>()
                                .removeCheckDate(date),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _pickDate(context),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة تاريخ'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('تم'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
