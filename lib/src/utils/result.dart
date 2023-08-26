class Result<TOk, TError> {
  late final bool _successFlag;
  late TOk _successPayload;
  late TError _errorPayload;

  TOk get successPayload {
    if (isSuccessful) {
      return _successPayload;
    }

    throw StateError("Used successPayload on error Result");
  }

  TError get errorPayload {
    if (!isSuccessful) {
      return _errorPayload;
    }

    throw StateError("Used errorPayload on successful Result");
  }

  bool get isSuccessful => _successFlag;
  bool get isError => !_successFlag;

  Result.ok(this._successPayload) : _successFlag = true;
  Result.error(this._errorPayload) : _successFlag = false;
}
