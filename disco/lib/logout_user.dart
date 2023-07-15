import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/user.dart';
import 'package:disco/models/errors.dart';

void main(List<String> arguments) async {
  //creating instance of database server
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();

  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();

  //checking if any user is logged in
  if (currentSession != null) {
    String username = currentSession['username'];

    User userObj = User();
    await userObj.logout(username, db);
  } else {
    LoginError.NotLoggedIn();
  }
  await db.close();
}
