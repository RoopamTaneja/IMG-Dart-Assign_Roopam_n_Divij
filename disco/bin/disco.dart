import 'package:disco/create_user.dart' as create_user;
import 'package:disco/login_user.dart' as login;
import 'package:disco/logout_user.dart' as logout;
import 'package:disco/create.dart' as create;

void main(List<String> arguments) {
  if (arguments[0] == "register") {
    create_user.main(arguments);
  }
  if (arguments[0] == "login") {
    login.main(arguments);
  }
  if (arguments[0] == "logout") {
    logout.main(arguments);
  }
  if (arguments[0] == "create") {
    create.main(arguments);
  }
}
