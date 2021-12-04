abstract class DataState<T> {
  final T? data;
  final Error? error;

  bool hasData() => data != null;
  bool hasError() => error != null;

  const DataState({this.data, this.error});
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(Error error) : super(error: error);
}
