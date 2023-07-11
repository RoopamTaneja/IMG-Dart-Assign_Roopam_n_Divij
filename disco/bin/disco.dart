// #!/usr/bin/env dart

import 'package:disco/create_user.dart' as create_user;

void main(List<String> arguments) {
  if (arguments[0] == "register") {
    create_user.main(arguments);
  }
}
