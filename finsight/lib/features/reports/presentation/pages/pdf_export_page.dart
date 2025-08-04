import 'package:flutter/material.dart';
import '../../../../shared/widgets/placeholder_page.dart';

class PDFExportPage extends StatelessWidget {
  const PDFExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Export Reports',
      description: 'Generate and share your financial reports',
      icon: Icons.file_download,
    );
  }
}
