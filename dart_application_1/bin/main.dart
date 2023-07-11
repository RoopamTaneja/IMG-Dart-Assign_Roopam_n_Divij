import 'dart:io';
// import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main() {
  //Connect to database
  // Db db = Db('mongodb://localhost:27017')

  stdout.write("Enter username : ");
  var username = stdin.readLineSync();
  print(username);
  stdout.write("Enter password : ");
  var pass = stdin.readLineSync().toString();
  var hashedPass = hashPass(pass);
  print(hashedPass);
}

String hashPass(String pass) {
  var bytes = utf8.encode(pass);
  var digest = sha256.convert(bytes);

  return digest.toString();
}
