import 'package:flutter/material.dart';
import '../../../../shared/widgets/placeholder_page.dart';

class KnowledgeHubPage extends StatelessWidget {
  const KnowledgeHubPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Knowledge Hub',
      description: 'Learn financial concepts and improve your money management skills',
      icon: Icons.school,
    );
  }
}
