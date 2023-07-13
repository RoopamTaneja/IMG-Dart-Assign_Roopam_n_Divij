import 'package:disco/create_user.dart' as create_user;
import 'package:disco/login_user.dart' as login;
import 'package:disco/logout_user.dart' as logout;
import 'package:disco/create.dart' as create;
import 'package:disco/join.dart' as join;
import 'package:disco/mod_rights.dart' as mod;
import 'package:disco/sudo_rights.dart' as sudo;
import 'package:disco/messages.dart' as messages;
import 'package:disco/inbox.dart' as inbox;

void main(List<String> arguments) {
  if (arguments[0] == "register") {
    create_user.main(arguments);
  } else if (arguments[0] == "login") {
    login.main(arguments);
  } else if (arguments[0] == "logout") {
    logout.main(arguments);
  } else if (arguments[0] == "create") {
    create.main(arguments);
  } else if (arguments[0] == "join") {
    join.main(arguments);
  } else if (arguments[0] == "admit") {
    mod.main(arguments);
  } else if (arguments[0] == "showEntrants") {
    mod.main(arguments);
  } else if (arguments[0] == "showMods") {
    mod.main(arguments);
  } else if (arguments[0] == "remove") {
    mod.main(arguments);
  } else if (arguments[0] == "sudo") {
    sudo.main(arguments);
  } else if (arguments[0] == "message") {
    messages.main(arguments);
  } else if (arguments[0] == "inbox") {
    inbox.main(arguments);
  } else {
    print("SyntaxError : No such command exists");
  }
}
