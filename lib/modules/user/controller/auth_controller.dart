import 'dart:async';
import 'dart:convert';

import 'package:ProjetoAPICuidaPet/application/exceptions/user_exists_exception.dart';
import 'package:ProjetoAPICuidaPet/application/exceptions/user_not_found_exception.dart';
import 'package:ProjetoAPICuidaPet/application/helpers/jwt_helper.dart';
import 'package:ProjetoAPICuidaPet/application/logger/i_logger.dart';
import 'package:ProjetoAPICuidaPet/entities/user.dart';
import 'package:ProjetoAPICuidaPet/modules/user/view_models/login_view_model.dart';
import 'package:ProjetoAPICuidaPet/modules/user/view_models/user_confirm_input_model.dart';
import 'package:ProjetoAPICuidaPet/modules/user/view_models/user_refresh_token_input_model.dart';
import 'package:ProjetoAPICuidaPet/modules/user/view_models/user_save_input_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:ProjetoAPICuidaPet/modules/user/service/i_user_service.dart';

part 'auth_controller.g.dart';

@Injectable()
class AuthController {
  IUserService userService;
  ILogger log;

  AuthController({
    required this.userService,
    required this.log,
  });

  @Route.post('/')
  Future<Response> login(Request request) async {
    User user;
    try {
      final loginViewModel = LoginViewModel(await request.readAsString());
      if (!loginViewModel.socialLogin) {
        user = await userService.loginWithEmailPassword(
          loginViewModel.login,
          loginViewModel.password,
          loginViewModel.supplierUser,
        );
      } else {
        user = await userService.loginWithSocial(
          loginViewModel.login,
          loginViewModel.avatar!,
          loginViewModel.socialType!,
          loginViewModel.socialKey!,
        );
      }
      return Response.ok(
        jsonEncode(
            {'access_token': JwtHelper.generateJWT(user.id!, user.supplierId)}),
      );
    } on UserNotfoundException {
      return Response.forbidden({'message': 'Usuário ou senha inválidos'});
    } catch (e, s) {
      log.error('erro ao realizar login', e, s);
      return Response.internalServerError(
        body: jsonEncode(
          {'message': 'Erro ao realizar Login'},
        ),
      );
    }
  }

  @Route.post('/register')
  Future<Response> saveUser(Request request) async {
    try {
      final userModel = UserSaveInputModel(
        await request.readAsString(),
      );

      await userService.createUser(userModel);
      return Response.ok(
        jsonEncode(
          {'message': 'cadastro realizado com sucesso'},
        ),
      );
    } on UserExistsException {
      return Response(400,
          body: jsonEncode(
              {'message': 'Usuario ja cadastrado na base de dados'}));
    } catch (e) {
      log.error('Erro ao cadastrar usuario', e);
      return Response.internalServerError();
    }
  }

  @Route('PATCH', '/confirm')
  Future<Response> confirmLogin(Request request) async {
    final user = int.parse(request.headers['user']!);
    final supplier = int.tryParse(request.headers['supplier'] ?? '');
    final token =
        JwtHelper.generateJWT(user, supplier).replaceAll('Bearer ', '');

    final inputModel = UserConfirmInputModel(
      userId: user,
      accessToken: token,
      data: await request.readAsString(),
    );

    final refreshToken = await userService.confirmLogin(inputModel);

    return Response.ok(jsonEncode({
      'access_token': 'Bearer $token',
      'refresh_token': refreshToken,
    }));
  }

  @Route.put('/refresh')
  Future<Response> refreshToken(Request request) async {
    try {
      final user = int.parse(request.headers['user']!);
      final supplier = int.tryParse(request.headers['supplier'] ?? '');
      final accessToken = request.headers['access_token']!;
      final model = UserRefreshTokenInputModel(
        user: user,
        supplier: supplier,
        accessToken: accessToken,
        dataRequest: await request.readAsString(),
      );

      final userRefreshToken = await userService.refreshToken(model);
      return Response.ok(jsonEncode({
        'access_token': userRefreshToken.accessToken,
        'refresh_token': userRefreshToken.refreshToken,
      }));
    } catch (e) {
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro ao atualzar o access token'}));
    }
  }

  Router get router => _$AuthControllerRouter(this);
}
