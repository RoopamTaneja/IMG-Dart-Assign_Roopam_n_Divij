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
  print(username);

  final db = await Db.create('mongodb://127.0.0.1:27017/testDB');
  await db.open();
  final userAuth = db.collection('userAuth');

  final user = await userAuth.findOne(where.match('username', username));
  if (user == null) {
    stdout.write("Enter password : ");
    var pass = stdin.readLineSync().toString();
    var hashedPass = hashPass(pass);

    final document = {'username': username, 'hash': hashedPass};
    final result =
        await userAuth.insertOne(document..['_id'] = ObjectId().toHexString());
    if (result.isAcknowledged) {
      print('success');
    } else {
      print('failure');
    }
  } else {
    print('User already present : failure');
  }

  await db.close();
}

String hashPass(String pass) {
  var bytes = utf8.encode(pass);
  var digest = sha256.convert(bytes);

  return digest.toString();
}
