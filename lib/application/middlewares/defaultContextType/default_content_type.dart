import 'package:ProjetoAPICuidaPet/application/middlewares/middlewares.dart';
import 'package:shelf/src/response.dart';
import 'package:shelf/src/request.dart';

class DefaultContentType extends Middlewares {
  @override
  Future<Response> execute(Request request) async {
    final response = await innerHandler(request);
    return response.change(
      headers: {
        'content-type': 'application/json;charset=utf-8',
      },
    );
  }
}
