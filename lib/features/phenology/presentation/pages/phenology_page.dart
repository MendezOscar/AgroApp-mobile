import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/role_helper.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../crops/presentation/bloc/crop_prediction_cubit.dart';
import '../../domain/entities/phenology_stage_entity.dart';
import '../bloc/phenology_cubit.dart';
import '../bloc/phenology_state.dart';
import '../widgets/add_stage_sheet.dart';
import '../widgets/phenology_stage_card.dart';
import '../widgets/phenology_timeline.dart';

class PhenologyPage extends StatefulWidget {
  final String plotId;
  final String cropId;
  final String cropType;
  final bool embedded; // ← nuevo

  const PhenologyPage({
    super.key,
    required this.plotId,
    required this.cropId,
    required this.cropType,
    this.embedded = false,
  });

  @override
  State<PhenologyPage> createState() => _PhenologyPageState();
}

class _PhenologyPageState extends State<PhenologyPage> {
  late final PhenologyCubit _cubit;
  late final CropPredictionCubit _predictionCubit;
  late final bool _canEdit;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    _canEdit = authState is AuthAuthenticated
        ? RoleHelper.isFarmer(authState.user.role)
        : false;

    _cubit = sl<PhenologyCubit>()..loadStages(widget.cropId);
    _predictionCubit = sl<CropPredictionCubit>()
      ..loadPrediction(widget.plotId, widget.cropId);
  }

  @override
  void dispose() {
    _cubit.close();
    _predictionCubit.close();
    super.dispose();
  }

  void _showAddStage() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: AddStageSheet(
          cropId: widget.cropId,
          cropType: widget.cropType,
        ),
      ),
    );
  }

  void _showStageDetail(PhenologyStageEntity stage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: _StageDetailSheet(
          stage: stage,
          cropId: widget.cropId,
          canEdit: _canEdit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _cubit),
          BlocProvider.value(value: _predictionCubit),
        ],
        child: BlocConsumer<PhenologyCubit, PhenologyState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.error!),
                    backgroundColor: AppTheme.error),
              );
            }
            if (state.success != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.success!),
                    backgroundColor: AppTheme.primary),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) return const LoadingWidget();
            return Column(
              children: [
                const _PredictionCard(),
                Expanded(
                  child: state.stages.isEmpty
                      ? _buildEmpty()
                      : _buildContent(state),
                ),
              ],
            );
          },
        ),
      );
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _predictionCubit),
      ],
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Fenología'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _cubit.loadStages(widget.cropId),
            ),
          ],
        ),
        body: BlocConsumer<PhenologyCubit, PhenologyState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.error!),
                    backgroundColor: AppTheme.error),
              );
            }
            if (state.success != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.success!),
                    backgroundColor: AppTheme.primary),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) return const LoadingWidget();

            return Column(
              children: [
                const _PredictionCard(),
                Expanded(
                  child: state.stages.isEmpty
                      ? _buildEmpty()
                      : _buildContent(state),
                ),
              ],
            );
          },
        ),
        floatingActionButton: _canEdit
            ? FloatingActionButton.extended(
                backgroundColor: AppTheme.primary,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Nueva etapa',
                    style: TextStyle(color: Colors.white)),
                onPressed: _showAddStage,
              )
            : null,
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text('Sin etapas registradas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            'Registra la etapa fenológica actual del cultivo',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          if (_canEdit) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Registrar primera etapa'),
              onPressed: _showAddStage,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(PhenologyState state) {
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () async => _cubit.loadStages(widget.cropId),
      child: ListView(
        children: [
          // Etapa actual
          if (state.activeStage != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryLight, AppTheme.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    state.activeStage!.icon ?? '🌱',
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Etapa actual',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          state.activeStage!.stageName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Día ${state.activeStage!.daysInStage} en esta etapa',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Progreso general
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Progreso del cultivo',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                      '${(state.progressPercent * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                          color: AppTheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: state.progressPercent,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                    color: AppTheme.primary,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Timeline horizontal
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8),
            child: Text('Timeline',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          PhenologyTimeline(
            stages: state.stages,
            onStageTap: _showStageDetail,
          ),

          const SizedBox(height: 16),

          // Lista detallada
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Historial de etapas',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(height: 8),
          ...state.stages.map((stage) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PhenologyStageCard(
                  stage: stage,
                  onTap: () => _showStageDetail(stage),
                ),
              )),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  const _PredictionCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CropPredictionCubit, CropPredictionState>(
      builder: (context, state) {
        if (state.isLoading) return const SizedBox();

        final prediction = state.prediction;
        final hasYield = prediction?.predictedYieldKg != null;
        final hasHarvest = prediction?.predictedHarvestDate != null;

        if (!hasYield && !hasHarvest) {
          return Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.insights_outlined, color: Colors.grey[500]),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sin datos suficientes para predecir — registra cosechas '
                    'anteriores o el ciclo fenológico de este cultivo.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }

        final fmt = DateFormat('dd/MM/yyyy');
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.secondary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.insights, color: AppTheme.primary),
                  SizedBox(width: 8),
                  Text('Predicción de cosecha',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 12),
              if (hasYield) ...[
                Text(
                  '≈ ${prediction!.predictedYieldKg!.toStringAsFixed(1)} kg estimados',
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                Text(prediction.yieldBasis!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                const SizedBox(height: 8),
              ],
              if (hasHarvest) ...[
                Builder(builder: (_) {
                  final date = prediction!.predictedHarvestDate!;
                  final daysLeft = date.difference(DateTime.now()).inDays;
                  return Text(
                    daysLeft >= 0
                        ? 'Cosecha estimada: ${fmt.format(date)} (en $daysLeft días)'
                        : 'Cosecha estimada: ${fmt.format(date)}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  );
                }),
                Text(prediction!.harvestBasis!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              ],
            ],
          ),
        );
      },
    );
  }
}

// Sheet de detalle de etapa
class _StageDetailSheet extends StatefulWidget {
  final PhenologyStageEntity stage;
  final String cropId;
  final bool canEdit;

  const _StageDetailSheet({
    required this.stage,
    required this.cropId,
    required this.canEdit,
  });

  @override
  State<_StageDetailSheet> createState() => _StageDetailSheetState();
}

class _StageDetailSheetState extends State<_StageDetailSheet> {
  final _observationsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _observationsCtrl.text = widget.stage.observations ?? '';
  }

  @override
  void dispose() {
    _observationsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhenologyCubit, PhenologyState>(
      listener: (context, state) {
        if (state.success != null) Navigator.pop(context);
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              // Header
              Row(
                children: [
                  Text(widget.stage.icon ?? '🌱',
                      style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.stage.stageName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${widget.stage.daysInStage} días en esta etapa',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  if (widget.stage.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Activa',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Observaciones editables
              if (widget.canEdit) ...[
                TextFormField(
                  controller: _observationsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones',
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                BlocBuilder<PhenologyCubit, PhenologyState>(
                  builder: (context, state) => ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            context.read<PhenologyCubit>().updateStage(
                              widget.cropId,
                              widget.stage.id,
                              {
                                'observations': _observationsCtrl.text.isEmpty
                                    ? null
                                    : _observationsCtrl.text,
                              },
                            );
                          },
                    child: const Text('Guardar observaciones'),
                  ),
                ),
              ] else if (widget.stage.observations != null) ...[
                const Text('Observaciones',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(widget.stage.observations!,
                    style: TextStyle(color: Colors.grey[700])),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
