abstract interface class NojinUseCase<Output, Input> {
  Future<Output> execute(Input input);
}

abstract interface class NojinSyncUseCase<Output, Input> {
  Output execute(Input input);
}
