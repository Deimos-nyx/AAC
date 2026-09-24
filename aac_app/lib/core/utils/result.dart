/// A minimal success/failure wrapper. Repositories and services return this
/// instead of throwing, so the UI layer can always show a calm, plain-
/// language message (per spec: never surface technical errors) instead of
/// letting an exception bubble up and crash a screen.
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.error(String message, [Object? cause]) = Err<T>;

  bool get isOk => this is Ok<T>;
  bool get isError => this is Err<T>;

  T? get valueOrNull => switch (this) {
        Ok<T>(value: final v) => v,
        Err<T>() => null,
      };

  String? get errorOrNull => switch (this) {
        Ok<T>() => null,
        Err<T>(message: final m) => m,
      };

  R fold<R>(R Function(T value) onOk, R Function(String message) onError) {
    return switch (this) {
      Ok<T>(value: final v) => onOk(v),
      Err<T>(message: final m) => onError(m),
    };
  }
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

class Err<T> extends Result<T> {
  final String message;
  final Object? cause;
  const Err(this.message, [this.cause]);
}
