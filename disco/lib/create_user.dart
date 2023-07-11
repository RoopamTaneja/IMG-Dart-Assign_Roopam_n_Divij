import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:io';

void main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addOption('username', abbr: 'u', help: 'ADD USER');
  final parsed = parser.parse(arguments);
  String username = parsed['username'] as String;
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();
  final userAuth = db.collection('userAuth');
  final user = await userAuth.findOne(where.eq('username', username));

  if (user == null) {
    stdout.write("Enter Password : ");
    stdin.echoMode = false;
    var pass = stdin.readLineSync().toString();
    stdin.echoMode = true;
    print('');
    stdout.write("Confirm Password : ");
    stdin.echoMode = false;
    var passCon = stdin.readLineSync().toString();
    stdin.echoMode = true;
    print('');
    if (pass == passCon) {
      var hashedPass = hashPass(pass);

      final document = {'username': username, 'hash': hashedPass};
      final result = await userAuth
          .insertOne(document..['_id'] = ObjectId().toHexString());
      if (result.isAcknowledged) {
        print('Succesfully Registered ');
      } else {
        print('LoginError : Unsuccessful Login');
      }
    } else {
      print('LoginError :  Password do not Match');
    }
  } else {
    print('DuplicacyError : User Already Exists');
  }
  await db.close();
}

String hashPass(String pass) {
  var bytes = utf8.encode(pass);
  var digest = sha256.convert(bytes);

  return digest.toString();
}
