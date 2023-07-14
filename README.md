# IMG-Dart-Assign_Roopam_n_Divij

# CLI application for Discord

**A Command Line Interface Application project to stimulate discord features built solely on Dart.**

*A learning project developed by Divij and Roopam for enhancing understanding of Dart, its packages and OOPs concepts as part of IMG assignment.*<br>
External Dart packages used : mongo_dart, args, crypto

## Prerequisites
- Dart SDK 3.0.5
- MongoDB 6.0.7

## Installation

1. Clone the repository :
```
$ git clone git@github.com:RoopamTaneja/IMG-Dart-Assign_Roopam_n_Divij.git
```
2.  Enter project directory and run the project :
```
$ cd disco
$ dart run
```

*The application is ready to use. Try various commands prefixed by : `dart .\bin\disco.dart` and enjoy.*<br>
*For example : `dart .\bin\disco.dart register -u <username>`*

## Commands

- `register [OPTION]`<br>
**Usage**: Register a new user<br>
&emsp;-u, --username : specify username<br>
&emsp;e.g. `register -u user1`<br><br>

- `login [OPTION]`<br>
**Usage**: Login existing user<br>
&emsp;-u, --username : specify username<br>
&emsp;e.g. `login -u user1`<br><br>

- `logout`<br>
**Usage**: Logout logged in user<br><br>

- `create [OPTION]`<br>
**Usage**: Create server/ channel within server<br>
&emsp;-s, --server : specify name of server to create new server <br>
&emsp;-c, --channel : specify name of channel to create new channel within new/existing server (OPTIONAL). <br>
&emsp;New channel in existing server can be added only by a moderator or creater.<br>
&emsp;-t, --type : specify type of channel (OPTIONAL)<br>
&emsp;e.g. `create -s server1 -c ch1 -t text`<br><br>

- `join [OPTION]`<br>
**Usage**: Join server/ channel within server<br>
&emsp;-s, --server : specify name of server to be joined <br>
&emsp;User is added to queue for approval of moderator for joining the server.<br>
&emsp;-c, --channel : specify name of channel to be joined (OPTIONAL)<br>
&emsp;A channel can be joined only if user is already a member of the server else he/she is added to queue for approval.<br>
&emsp;e.g. `join -s server1 -c ch1`<br><br>

- `showMods [OPTION]`<br>
**Usage**: Show list of moderators of a server<br>
&emsp;-s, --server : specify name of server<br>
&emsp;e.g. `showMods -s server1`<br><br>

**_Commands only accessible to moderators and creator_**

- `admit [OPTION]`<br>
**Usage**: Admit a user in a server<br>
&emsp;-u, --username : specify username<br>
&emsp;-s, --server : specify name of server<br>
&emsp;e.g. `admit -u user1 -s server1`<br><br>

- `remove [OPTION]`<br>
**Usage**: Remove a user from a server<br>
&emsp;-u, --username : specify username<br>
&emsp;-s, --server : specify name of server<br>
&emsp;e.g. `remove -u user1 -s server1`<br><br>

- `showEntrants [OPTION]`<br>
**Usage**: Show list of users waiting for approval to join<br>
&emsp;-s, --server : specify name of server<br>
&emsp;e.g. `showEntrants -s server1`<br><br>

**_Commands only accessible to creator_**<br><br>
_Such commands are prefixed by sudo (signifying creator)._<br>
_Other commands are added under -o, --owner option._<br>
_Like : sudo -o <command> [OPTIONS]_<br>

- `addMod [OPTION]`<br>
**Usage**: Promote a member of a server to moderator<br>
&emsp;-u, --username : specify username of member<br>
&emsp;-s, --server : specify name of server<br>
&emsp;e.g. `sudo -o addMod -u user1 -s server1`<br><br>

- `removeMod [OPTION]`<br>
**Usage**: Demote a moderator of a server to member<br>
&emsp;-u, --username : specify username of moderator<br>
&emsp;-s, --server : specify name of server<br>
&emsp;e.g. `sudo -o removeMod -u user1 -s server1`<br><br>