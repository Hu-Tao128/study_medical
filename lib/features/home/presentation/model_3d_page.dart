import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'widgets/model_3d_viewer.dart';

class Model3DPage extends StatelessWidget {
  final String modelName;
  final String modelUrl;

  const Model3DPage({
    super.key,
    required this.modelName,
    required this.modelUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(modelName)),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Model3DViewer(src: modelUrl, alt: modelName),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Model Description",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      "This is a detailed 3D model for anatomical study. "
                      "You can rotate, zoom, and use augmented reality (AR) on compatible devices.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.menu_book),
                      label: Text(l10n.studyRelatedAnatomy),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
