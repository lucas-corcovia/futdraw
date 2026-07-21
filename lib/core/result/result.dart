sealed class AppResult<T> {
  const AppResult();

  bool get isSuccess => this is AppSuccess<T>;
  bool get isError => this is AppError<T>;

  T? get data => switch (this) {
    AppSuccess(:final data) => data,
    _ => null,
  };

  String? get errorMessage => switch (this) {
    AppError(:final message) => message,
    _ => null,
  };

  factory AppResult.success(T data) = AppSuccess<T>;
  factory AppResult.error(String message) = AppError<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(String message) error,
  }) =>
      switch (this) {
        AppSuccess(:final data) => success(data),
        AppError(:final message) => error(message),
      };
}

final class AppSuccess<T> extends AppResult<T> {
  final T data;
  const AppSuccess(this.data);
}

final class AppError<T> extends AppResult<T> {
  final String message;
  const AppError(this.message);
}
