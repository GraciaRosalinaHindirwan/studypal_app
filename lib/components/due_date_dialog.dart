import 'package:flutter/material.dart';
import 'package:studypal/components/app_button.dart';
import 'package:studypal/components/app_button_secondary.dart';
import 'package:studypal/theme/app_colors.dart';

class DueDateDialog extends StatefulWidget {
  // kalau lagi edit task, kirim tanggal lama biar dialognya langsung kebuka di situ
  final DateTime? initial;

  const DueDateDialog({super.key, this.initial});

  @override
  State<DueDateDialog> createState() => _DueDateDialogState();
}

class _DueDateDialogState extends State<DueDateDialog> {
  // tanggal, jam, sama menit dipisah, nanti digabung pas klik OK
  late DateTime selectedDate;
  late int hour;
  late int minute;

  @override
  void initState() {
    super.initState();
    // kalau belum ada tanggal sebelumnya, pakai waktu sekarang
    final base = widget.initial ?? DateTime.now();
    // jam menitnya dibuang dulu, soalnya kalender cuma butuh tanggalnya
    selectedDate = DateTime(base.year, base.month, base.day);
    hour = base.hour;
    minute = base.minute;
  }

  // dropdown angka, dipakai dua kali (jam & menit) biar ga nulis dobel
  Widget timeDropdown({
    required int value,
    required int count, // 24 buat jam, 60 buat menit
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondary, width: 1.5),
      ),
      child: DropdownButton<int>(
        value: value,
        underline: const SizedBox(), // hilangin garis bawaan dropdown
        menuMaxHeight: 240, // biar list menit ga kepanjangan
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 16,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
        items: [
          // bikin item 0 sampai count-1, ditampilin 2 digit (5 jadi 05)
          for (int i = 0; i < count; i++)
            DropdownMenuItem(
              value: i,
              child: Text(i.toString().padLeft(2, '0')),
            ),
        ],
        onChanged: (v) => onChanged(v!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // hari ini jam 00:00, dipakai sebagai batas awal kalender
    final today = DateTime(now.year, now.month, now.day);

    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.accent, width: 3),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 0, // jarak antar bagian diatur manual, biar ga dobel
          children: [
            CalendarDatePicker(
              // jaga-jaga kalau tanggal lama udah lewat, mulai dari sekarang
              // (kalau ga, kalender error karena initialDate < firstDate)
              initialDate: selectedDate.isBefore(today) ? now : selectedDate,
              firstDate: today, // ga bisa pilih tanggal yang udah lewat
              lastDate: DateTime(now.year + 5), // maksimal 5 tahun ke depan
              // ga pakai setState karena kalender ngurus tampilannya sendiri
              onDateChanged: (d) => selectedDate = d,
            ),
            // geser seluruh baris jam naik ke area kosong di bawah kalender
            // (translate cuma geser tampilan, ruang aslinya tetap ada)
            Transform.translate(
              offset: const Offset(0, -40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  const Text(
                    'Jam',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  timeDropdown(
                    value: hour,
                    count: 24,
                    // pakai setState biar dropdown nampilin angka yang baru
                    onChanged: (v) => setState(() => hour = v),
                  ),
                  const Text(
                    ':',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  timeDropdown(
                    value: minute,
                    count: 60,
                    onChanged: (v) => setState(() => minute = v),
                  ),
                  const Text(
                    'Menit',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4), // jarak jam ke tombol
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: AppButtonSecondary(
                    label: 'Batal',
                    // pop tanpa nilai, jadi hasilnya null
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: AppButton(
                    label: 'OK',
                    onTap: () {
                      // gabungin tanggal + jam + menit jadi satu DateTime,
                      // terus dikirim balik ke halaman yang manggil dialog ini
                      Navigator.pop(
                        context,
                        DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          hour,
                          minute,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}