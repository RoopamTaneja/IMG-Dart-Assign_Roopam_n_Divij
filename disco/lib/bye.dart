import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/user.dart';

void main(List<String> arguments) async {
  //creating a new instance of the database server
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();

  //checking for any instance of login from the database
  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();

  if (currentSession == null) {
    //if no user logged in then no point in moving ahead
    print('LoginError : No User Logged In');
    await db.close();
    return;
  }

  //logged in so user must exist
  User userObj = User();
  await userObj.setUserData(currentSession['username'], db);
  await userObj.deleteAccount(db);

  await db.close();
}
