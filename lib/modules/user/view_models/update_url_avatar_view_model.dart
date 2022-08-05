import 'package:ProjetoAPICuidaPet/application/helpers/request_mapping..dart';

class UpdateUrlAvatarViewModel extends RequestMapping {
  int userId;
  late String urlAvatar;
  UpdateUrlAvatarViewModel({
    required this.userId,
    required String dataRequest,
  }) : super(dataRequest);

  @override
  void map() {
    urlAvatar = data['url_avatar'];
  }
}
