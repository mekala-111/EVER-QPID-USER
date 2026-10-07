import 'package:dio/dio.dart';
import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

/// Attaches [DioAdapter] to the shared [NetworkApiServiceV2] Dio client.
class DioTestHarness {
  DioTestHarness();

  late final DioAdapter adapter;
  Dio get dio => NetworkApiServiceV2.instance.adapter;

  void install() {
    adapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = adapter;
  }

  void onGet(String path, Map<String, dynamic> body, {int status = 200}) {
    adapter.onGet(path, (server) => server.reply(status, body));
  }

  void onPost(String path, Map<String, dynamic> body, {int status = 200}) {
    adapter.onPost(
      path,
      (server) => server.reply(status, body),
      data: Matchers.any,
    );
  }

  void onPut(String path, Map<String, dynamic> body, {int status = 200}) {
    adapter.onPut(
      path,
      (server) => server.reply(status, body),
      data: Matchers.any,
    );
  }

  void onDelete(String path, Map<String, dynamic> body, {int status = 200}) {
    adapter.onDelete(
      path,
      (server) => server.reply(status, body),
      data: Matchers.any,
    );
  }

  void onPutAbsolute(String url, {int status = 200}) {
    adapter.onPut(
      url,
      (server) => server.reply(status, ''),
      data: Matchers.any,
    );
  }
}
