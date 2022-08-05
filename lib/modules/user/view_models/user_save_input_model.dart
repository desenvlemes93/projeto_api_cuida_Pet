import 'package:ProjetoAPICuidaPet/application/helpers/request_mapping..dart';
import 'package:ProjetoAPICuidaPet/entities/user.dart';

class UserSaveInputModel extends RequestMapping {
  late String email;
  late String password;
  int? supplierId;

  UserSaveInputModel(String dataRequest) : super(dataRequest);

  @override
  void map() {
    email = data['email'];
    password = data['password'];
  }
}
