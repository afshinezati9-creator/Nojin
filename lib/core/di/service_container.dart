import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/app_logger.dart';

class ServiceContainer {
  ServiceContainer({required this.logger});

  final AppLogger logger;

  static ServiceContainer create() {
    return ServiceContainer(logger: AppLogger.instance);
  }
}

final serviceContainerProvider = Provider<ServiceContainer>(
  (ref) => ServiceContainer.create(),
);
