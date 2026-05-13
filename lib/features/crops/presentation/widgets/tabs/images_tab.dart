import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../bloc/crop_detail_cubit.dart';
import '../../bloc/crop_detail_state.dart';

class ImagesTab extends StatelessWidget {
  final String cropId;
  const ImagesTab({super.key, required this.cropId});

  Future<void> _pickAndUpload(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (picked != null && context.mounted) {
      await context
          .read<CropDetailCubit>()
          .uploadImage(cropId, picked.path, 'general');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CropDetailCubit, CropDetailState>(
      builder: (context, state) {
        if (state.isLoadingImages) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        return Column(
          children: [
            // Botones de cámara y galería
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Tomar foto'),
                      onPressed: () =>
                          _pickAndUpload(context, ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galería'),
                      onPressed: () =>
                          _pickAndUpload(context, ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ),

            // Indicador offline con pendientes
            if (state.isOffline)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.orange, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        state.images.isEmpty
                            ? 'Sin conexión — las fotos se subirán cuando tengas internet'
                            : '${state.images.where((i) => i.isPending).length} foto(s) pendiente(s) de subir',
                        style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

            // Grid de imágenes
            Expanded(
              child: state.images.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library_outlined,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            state.isOffline
                                ? 'Sin fotos guardadas localmente'
                                : 'No hay fotos del cultivo',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Toma una foto para registrar el estado del cultivo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: state.images.length,
                      itemBuilder: (_, i) {
                        final image = state.images[i];
                        final isLocal = image.isPending;

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            // Imagen
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: isLocal
                                  ? Image.file(
                                      File(image.url),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _errorPlaceholder(),
                                    )
                                  : Image.network(
                                      image.url,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (_, child, progress) =>
                                          progress == null
                                              ? child
                                              : Container(
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: AppTheme.primary,
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                ),
                                      errorBuilder: (_, __, ___) =>
                                          _errorPlaceholder(),
                                    ),
                            ),

                            // Badge pendiente
                            if (isLocal)
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade700,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.cloud_upload_outlined,
                                          color: Colors.white, size: 12),
                                      SizedBox(width: 3),
                                      Text(
                                        'Pendiente',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Botón acción (eliminar o esperar)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: isLocal
                                    ? null
                                    : () => _confirmDelete(
                                        context, cropId, image.id),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isLocal
                                        ? Colors.grey.withValues(alpha: 0.8)
                                        : Colors.red.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isLocal ? Icons.hourglass_top : Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),

                            // Categoría
                            if (image.category != null)
                              Positioned(
                                bottom: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    image.category!,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ),

                            // Diagnóstico IA
                            if (image.aiDiagnosis != null && !isLocal)
                              Positioned(
                                bottom: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.primary.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.psychology,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 32),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String cropId, String imageId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar foto'),
        content: const Text('¿Estás seguro de eliminar esta foto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<CropDetailCubit>().deleteImage(cropId, imageId);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
