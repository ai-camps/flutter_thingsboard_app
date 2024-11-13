import 'package:flutter/foundation.dart';
import 'package:thingsboard_app/constants/app_constants.dart';
import 'package:thingsboard_app/core/auth/login/region.dart';
import 'package:thingsboard_app/utils/services/endpoint/i_endpoint_service.dart';
import 'package:thingsboard_app/utils/services/local_database/i_local_database_service.dart';

class EndpointService implements IEndpointService {
  EndpointService({required this.databaseService});

  static const northAmericaHost = 'https://thingsboard.cloud';
  static const europeHost = 'https://eu.thingsboard.cloud';

  final ILocalDatabaseService databaseService;
  String? _cachedEndpoint;
  final _notifierValue = ValueNotifier<String?>(UniqueKey().toString());
  final _defaultEndpoints = <String>{
    ThingsboardAppConstants.thingsBoardApiEndpoint,
  };

  @override
  ValueListenable<String?> get listenEndpointChanges => _notifierValue;

  @override
  Future<void> setEndpoint(String endpoint) async {
    _cachedEndpoint = endpoint;
    _notifierValue.value = UniqueKey().toString();

    if (endpoint == northAmericaHost) {
      databaseService.saveSelectedRegion(Region.northAmerica);
    } else if (endpoint == europeHost) {
      databaseService.saveSelectedRegion(Region.europe);
    } else {
      databaseService.saveSelectedRegion(Region.custom);
    }

    await databaseService.setSelectedEndpoint(endpoint);
  }

  @override
  Future<String> getEndpoint() async {
    _cachedEndpoint ??= _ensureHttpScheme(
        databaseService.getSelectedEndpoint() ??
            ThingsboardAppConstants.thingsBoardApiEndpoint);
    return _cachedEndpoint!;
  }

  // Helper method to ensure URL has http scheme
  String _ensureHttpScheme(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'http://$url';
    }
    return url;
  }

  @override
  Future<bool> isCustomEndpoint() async {
    _cachedEndpoint ??= await getEndpoint();
    return !_defaultEndpoints.contains(_cachedEndpoint);
  }

  @override
  String getCachedEndpoint() {
    return _cachedEndpoint ?? ThingsboardAppConstants.thingsBoardApiEndpoint;
  }

  @override
  Region? getSelectedRegion() {
    return databaseService.getSelectedRegion();
  }

  @override
  Future<void> setRegion(Region region) async {
    if (region == Region.northAmerica) {
      await setEndpoint(northAmericaHost);
    } else if (region == Region.europe) {
      await setEndpoint(europeHost);
    }

    return databaseService.saveSelectedRegion(region);
  }
}
