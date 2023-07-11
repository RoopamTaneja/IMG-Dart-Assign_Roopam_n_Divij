import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:io';

void main(List<String> arguments) async {
  final db = await Db.create('mongodb://127.0.0.1:27017/testDB');
  await db.open();
  final collection = db.collection('users');

  final parser = ArgParser();
  parser.addOption('username', abbr: 'u', help: 'ADD USER');
  final parsed = parser.parse(arguments);
  String username = parsed['username'] as String;

  final user = await collection.findOne(where.match('username', username));
  if (user == null) {
    print('User not found : failure');
  } else {
    stdout.write("Enter password : ");
    var pass = stdin.readLineSync().toString();
    var hashedPass = hashPass(pass);

    while (user['hash'] != hashedPass) {
      print('Incorrect password : failure');
      stdout.write("Enter password : (enter q to exit) : ");
      pass = stdin.readLineSync().toString();
      if (pass == 'q') {
        await db.close();
        return;
      }
      hashedPass = hashPass(pass);
    }
    print("User logged in successfully!");
  }
  await db.close();
}

String hashPass(String pass) {
  var bytes = utf8.encode(pass);
  var digest = sha256.convert(bytes);

  return digest.toString();
}
