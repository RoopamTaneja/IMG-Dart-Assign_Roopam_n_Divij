// ignore_for_file: non_constant_identifier_names
class DuplicacyError {
  //private constructor
  DuplicacyError._();

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

  static void CategoryExists(category, server) {
    print('$_s$category Already Exists in $server');
  }

  static void ChannelExists(channel, server) {
    print('$_s$channel Already Exists in $server');
  }

  static void UserInServer(username) {
    print('$_s$username Is Already In Server');
  }
}

class PermissionDeniedError {
  //private constructor
  PermissionDeniedError._();

  static final String _s = "PermissionDenied : ";
  static void ModCreatorRight(server) {
    print('${_s}You Are Not Moderator or Creator of $server');
  }
}

class LoginError {
  //private constructor
  LoginError._();

  static final String _s = "LoginError : ";
  static void NotLoggedIn() {
    print('${_s}No User Logged In');
  }
}

class SyntaxError {
  //private constructor
  SyntaxError._();

  static final String _s = "SyntaxError : ";
  static void ChannelWithoutServer() {
    print('${_s}Channel without Server Cannot Be Created');
  }

  static void noServerName() {
    print('${_s}Server Name is Needed');
  }

  static void noChannelName() {
    print('${_s}Channel Name is Needed');
  }

  static void noCommand() {
    print("${_s}No such command exists");
  }

  static void noMessage() {
    print("${_s}No Message to Send");
  }

  static void noRecipient() {
    print("${_s}Recipient Needs To Be Entered");
  }

  static void MultipleRecipients() {
    print("${_s}Two Receivers Not Possible");
  }

  static void MultipleInbox() {
    print("${_s}Two Modes of Inbox Not Possible");
  }

  static void noInbox() {
    print("${_s}Mode of Inbox Needs To Be Entered");
  }
}

class ProcessError {
  //private constructor
  ProcessError._();

  static final String _s = "ProcessError : ";
  static void UnsuccessfulProcess() {
    print('${_s}Unsuccessful Process');
  }

  static void PasswordMismatch() {
    print('${_s}Password Do Not Match');
  }

  static void PasswordMismatchCriteraia() {
    print('${_s}Password Does Not Match Criteria');
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

  static void CategoryDoesNotExist(category) {
    print('$_s$category Does Not Exist');
  }

  static void UserNotInChannel(username) {
    print('$_s$username Not In Channel');
  }

  static void UserNotInServer(username) {
    print('$_s$username Not In Server');
  }

  static void RecipientError() {
    print("$_s Sender Cannot Be Recipient");
  }

  static void ChannelRightsError() {
    print('$_s You Do Not Have Channel Rights');
  }

  static void ChannelExistsInCategory(category, channel) {
    print('$_s $channel Exists in $category');
  }

  static void InvalidType(type) {
    print('$_s $type Is Not A Valid Type.');
  }
}
