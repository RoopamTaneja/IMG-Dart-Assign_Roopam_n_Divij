// ignore_for_file: non_constant_identifier_names

class DuplicacyError {
  static final String _s = "DuplicacyError : ";
  static void UserExists(username) {
    print("$_s$username Already Exists");
  }

  static void UserLoggedIn(username) {
    print('$_s$username Logged In');
  }

  static void ServerExists(server) {
    print('$_s$server Exists');
  }

  static void ChannelExists(channel) {
    print('$_s$channel Exists');
  }

  static void UserInServer(username) {
    print('$_s$username Is Already In Server');
  }
}

class PermissionDeniedError {
  static final String _s = "PermissionDenied : ";
  static void ModCreatorRight(server) {
    print('${_s}You Are Not Moderator or Creator of $server');
  }
}

class LoginError {
  static final String _s = "LoginError : ";
  static void NotLoggedIn() {
    print('${_s}No User Logged In');
  }
}

class SyntaxError {
  static final String _s = "SyntaxError : ";
  static void ChannelWithoutServer() {
    print('${_s}Channel without Server Cannot Be Created');
  }

  static void noServerName() {
    print('${_s}Server Name is Needed');
  }

  static void noCommand() {
    print("${_s}SyntaxError : No such command exists");
  }
}

class ProcessError {
  static final String _s = "ProcessError : ";
  static void UnsuccessfulProcess() {
    print('${_s}Unsuccessful Process');
  }

  static void PasswordMismatch() {
    print('${_s}Password Do Not Match');
  }

  static void UserDoesNotExist(username) {
    print('$_s$username Does Not Exist');
  }

  static void ChannelDoesNotExist(channel) {
    print('$_s$channel Does Not Exist in This Server');
  }

  static void ServerDoesNotExist(server) {
    print('$_s$server Does Not Exist');
  }

  static void UserNotInChannel(username) {
    print('$_s$username Not In Channel');
  }

  static void UserNotInServer(username) {
    print('$_s$username Not In Server');
  }
}
