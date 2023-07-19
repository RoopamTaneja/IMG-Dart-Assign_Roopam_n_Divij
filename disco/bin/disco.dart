import 'package:disco/create_user.dart' as create_user;
import 'package:disco/login_user.dart' as login;
import 'package:disco/logout_user.dart' as logout;
import 'package:disco/create.dart' as create;
import 'package:disco/join.dart' as join;
import 'package:disco/show.dart' as show;
import 'package:disco/mod_rights.dart' as mod;
import 'package:disco/sudo_rights.dart' as sudo;
import 'package:disco/messages.dart' as messages;
import 'package:disco/inbox.dart' as inbox;
import 'package:disco/leave.dart' as leave;
import 'package:disco/bye.dart' as bye;
import 'package:disco/permit.dart' as permit;

void main(List<String> arguments) {
  if (arguments.isNotEmpty) {
    switch (arguments[0]) {
      case "register":
        create_user.main(arguments);
        break;
      case "login":
        login.main(arguments);
        break;
      case "logout":
        logout.main(arguments);
        break;
      case "create":
        create.main(arguments);
        break;
      case "join":
        join.main(arguments);
        break;
      case "showUser":
      case "showMods":
      case "showChannels":
      case "showServers":
        show.main(arguments);
        break;
      case "admit":
      case "showEntrants":
      case "remove":
        mod.main(arguments);
        break;
      case "sudo":
        sudo.main(arguments);
        break;
      case "message":
        messages.main(arguments);
        break;
      case "inbox":
        inbox.main(arguments);
        break;
      case "leave":
        leave.main(arguments);
        break;
      case "bye":
        bye.main(arguments);
        break;
      case "permit":
        permit.main(arguments);
        break;
      default:
        print("SyntaxError : No such command exists");
    }
  }
}
