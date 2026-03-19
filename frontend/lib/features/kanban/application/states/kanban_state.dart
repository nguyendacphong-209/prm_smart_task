import 'package:prm_smart_task/features/kanban/domain/entities/kanban_board.dart';

class KanbanState {
  const KanbanState({
    required this.isLoading,
    required this.isSubmitting,
    this.board,
    this.errorMessage,
    this.infoMessage,
  });

  final bool isLoading;
  final bool isSubmitting;
  final KanbanBoard? board;
  final String? errorMessage;
  final String? infoMessage;

  factory KanbanState.initial() {
    return const KanbanState(
      isLoading: false,
      isSubmitting: false,
    );
  }

  KanbanState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    KanbanBoard? board,
    String? errorMessage,
    String? infoMessage,
    bool clearBoard = false,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return KanbanState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      board: clearBoard ? null : (board ?? this.board),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }
}
