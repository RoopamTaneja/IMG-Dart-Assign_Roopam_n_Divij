// #!/usr/bin/env dart

import 'package:disco/create_user.dart' as create_user;
import 'package:disco/login_user.dart' as login;

void main(List<String> arguments) {
  if (arguments[0] == "register") {
    create_user.main(arguments);
  }
  if (arguments[0] == "login") {
    login.main(arguments);
  }
}
