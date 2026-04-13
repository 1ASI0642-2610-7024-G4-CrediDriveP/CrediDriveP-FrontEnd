
abstract class UseCase<T, P> {
  Future<T> execute(P params);
}

/// Clase de utilidad cuando un UseCase no requiere parámetros.
class NoParams {}