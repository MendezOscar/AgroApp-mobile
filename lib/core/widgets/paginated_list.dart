import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PaginatedList<T> extends StatefulWidget {
  final List<T> items;
  final bool hasNextPage;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget? emptyWidget;
  final EdgeInsets padding;
  final Future<void> Function() onRefresh;

  const PaginatedList({
    super.key,
    required this.items,
    required this.hasNextPage,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.itemBuilder,
    required this.onRefresh,
    this.emptyWidget,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  State<PaginatedList<T>> createState() => _PaginatedListState<T>();
}

class _PaginatedListState<T> extends State<PaginatedList<T>> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (widget.hasNextPage && !widget.isLoadingMore) {
        widget.onLoadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoadingMore) {
      return widget.emptyWidget ?? const Center(child: Text('No hay datos'));
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: widget.padding,
        itemCount: widget.items.length + (widget.hasNextPage ? 1 : 0),
        itemBuilder: (context, index) {
          // Loader al final de la lista
          if (index == widget.items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            );
          }
          return widget.itemBuilder(context, widget.items[index], index);
        },
      ),
    );
  }
}
