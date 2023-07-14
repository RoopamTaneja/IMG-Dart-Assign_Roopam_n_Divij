import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/user.dart';

void main(List<String> arguments) async {
  //creating instance of database server
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();

  final users = db.collection('userAuth');
  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();

  //checking if any user is logged in
  if (currentSession != null) {
    String username = currentSession['username'];

    User userObj = User();
    await userObj.logout(username, users, userSessions);
  } else {
    print('LogoutError : No User Logged in!');
  }
  await db.close();
}
