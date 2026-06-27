import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/services/crop_image_cache_manager.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../data/models/ai_diagnosis_model.dart';
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

  void _showAnalysis(BuildContext context, String cropId, dynamic image) {
    if (image.aiDiagnosis != null) {
      try {
        final diagnosis =
            AiDiagnosisModel.fromJson(jsonDecode(image.aiDiagnosis as String));
        _showDiagnosisSheet(context, diagnosis);
      } catch (_) {
        _confirmAnalysis(context, cropId, image.id);
      }
    } else {
      _confirmAnalysis(context, cropId, image.id);
    }
  }

  void _confirmAnalysis(BuildContext context, String cropId, String imageId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Text('🤖', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Analizar con IA'),
          ],
        ),
        content: const Text(
          '¿Deseas analizar esta imagen para detectar '
          'enfermedades y obtener recomendaciones '
          'de tratamiento?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CropDetailCubit>().analyzeImage(cropId, imageId);
            },
            child: const Text('Analizar'),
          ),
        ],
      ),
    );
  }

  void _showDiagnosisSheet(BuildContext context, AiDiagnosisModel diagnosis) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),

              // Estado general
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: diagnosis.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: diagnosis.statusColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      diagnosis.statusIcon,
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      diagnosis.statusLabel,
                      style: TextStyle(
                        color: diagnosis.statusColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${diagnosis.condition} — '
                      '${diagnosis.confidence.toStringAsFixed(1)}% confianza',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Descripción
              const Text(
                'Descripción',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                diagnosis.description,
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Recomendaciones
              const Text(
                'Recomendaciones',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              ...diagnosis.recommendations.map(
                (rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4, right: 8),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          rec,
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CropDetailCubit, CropDetailState>(
      listenWhen: (previous, current) =>
          current.aiDiagnosis != null &&
          previous.aiDiagnosis == null &&
          !current.isAnalyzing,
      listener: (context, state) {
        if (state.aiDiagnosis != null) {
          _showDiagnosisSheet(context, state.aiDiagnosis!);
        }
      },
      builder: (context, state) {
        if (state.isAnalyzing) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.primary),
                SizedBox(height: 16),
                Text(
                  '🤖 Analizando imagen con IA...',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: AppTheme.primary),
                ),
                SizedBox(height: 8),
                Text(
                  'Esto puede tardar hasta 30 segundos',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        }
        if (state.isLoadingImages) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.primary),
                SizedBox(height: 16),
                Text('Analizando imagen con IA...',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
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

            // Banner offline
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
                            ? 'Sin conexión — las fotos se '
                                'subirán cuando tengas internet'
                            : '${state.images.where((i) => i.isPending).length} '
                                'foto(s) pendiente(s) de subir',
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
                            'Toma una foto para registrar '
                            'el estado del cultivo',
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
                        final hasAi = image.aiDiagnosis != null;

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
                                  : CachedNetworkImage(
                                      imageUrl: image.url,
                                      cacheManager:
                                          CropImageCacheManager.instance,
                                      cacheKey: image.storageKey,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: AppTheme.primary,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (_, __, ___) =>
                                          _errorPlaceholder(),
                                    ),
                            ),

                            // Agrega esto en el Stack, después de la imagen y antes de los badges:
                            BlocBuilder<CropDetailCubit, CropDetailState>(
                              builder: (context, state) {
                                if (!state.isAnalyzing) return const SizedBox();
                                return Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      color:
                                          Colors.black.withValues(alpha: 0.5),
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            '🤖 Analizando...',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
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

                            // Badge diagnóstico IA
                            if (hasAi && !isLocal)
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade700,
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
                                      Text('🤖',
                                          style: TextStyle(fontSize: 10)),
                                      SizedBox(width: 3),
                                      Text(
                                        'Analizada',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Botón eliminar / pendiente
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

                            // Botón análisis IA
                            if (!isLocal)
                              // Reemplaza el botón de análisis IA en el Stack:
                              if (!isLocal)
                                Positioned(
                                  bottom: 6,
                                  right: 6,
                                  child: BlocBuilder<CropDetailCubit,
                                      CropDetailState>(
                                    builder: (context, state) {
                                      // Verificar si esta imagen específica está siendo analizada
                                      final isThisAnalyzing = state.isAnalyzing;

                                      return GestureDetector(
                                        onTap: isThisAnalyzing
                                            ? null
                                            : () => _showAnalysis(
                                                context, cropId, image),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: isThisAnalyzing
                                                ? Colors.orange
                                                : hasAi
                                                    ? Colors.green
                                                    : AppTheme.primary,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 4),
                                            ],
                                          ),
                                          child: isThisAnalyzing
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : Icon(
                                                  hasAi
                                                      ? Icons.psychology
                                                      : Icons.search,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                        ),
                                      );
                                    },
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
}
