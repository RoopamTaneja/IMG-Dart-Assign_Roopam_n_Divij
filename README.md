# IMG-Dart-Assign_Roopam_n_Divij

# CLI application for Discord

**A Command Line Interface Application project to simulate discord features built solely on Dart.**

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

- `create [OPTION(s), FLAG(s)]`<br>
**Usage**: Create server/ channel within server<br>
&emsp;-s, --server : specify name of server to create new server <br>
&emsp;-c, --channel : specify name of channel to create new channel within new/existing server (OPTIONAL). <br>
&emsp;New channel in existing server can be added only by a moderator or creater.<br>
&emsp;-t, --type : specify type of channel (OPTIONAL)<br>
_Flags_:
&emsp;-C, --
&emsp;e.g. `create -s server1 -c ch1 -t text`<br><br>

- `join [OPTION(s)]`<br>
**Usage**: Join server/ channel within server<br>
&emsp;-s, --server : specify name of server to be joined <br>
&emsp;User is added to queue for approval of moderator for joining the server.<br>
&emsp;-c, --channel : specify name of channel to be joined (OPTIONAL)<br>
&emsp;A channel can be joined only if user is already a member of the server else he/she is added to queue for approval.<br>
&emsp;e.g. `join -s server1 -c ch1`<br><br>

- `showUser`<br>
**Usage**: Shows logged in user's details<br><br>

- `showServers`<br>
**Usage**: Show list of all servers<br>
&emsp;Can be used even if user not logged in<br><br>

- `showChannels [OPTION]`<br>
**Usage**: Show list of all channels of a server<br>
&emsp;-s, --server : specify name of server<br>
&emsp;Can be used even if user is not server member<br>
&emsp;e.g. `showChannels -s server1`<br><br>

- `showMods [OPTION]`<br>
**Usage**: Show list of all moderators of a server<br>
&emsp;-s, --server : specify name of server<br>
&emsp;Can be used even if user is not server member<br>
&emsp;e.g. `showMods -s server1`<br><br>

- `message [OPTIONS]`<br>
1. **Usage**: Send personal message to another user (even if not on same server)<br>
&emsp;-p, --personal : specify name of receiver<br>
&emsp;-w, --write : specify your message(enclosed in "")<br>
&emsp;e.g. `message -p user2 -w "Hello, World!"`<br>

2. **Usage**: Send message on a particular channel of a server<br>
&emsp;-s, --server : specify name of server<br>
&emsp;-c, --channel : specify name of channel<br>
&emsp;-w, --write : specify your message(enclosed in "")<br>
&emsp;e.g. `message -s server1 -c ch1 -w "Hello, World!"`<br><br>

- `inbox [OPTION(s)]`<br>
1. **Usage**: See personal messages received from all users or a particular user<br>
&emsp;-u, --user : specify name of user<br>
&emsp;Enter `-u ALL` to see messages from all users.<br>
&emsp;-l, --limit : set limit on number of messages shown (OPTIONAL)<br>
&emsp;Default value of limit is 10.<br>
&emsp;e.g. `inbox -u user2 -l 3`<br>

2. **Usage**: See messages received on a particular channel of a server<br>
&emsp;-s, --server : specify name of server<br>
&emsp;-c, --channel : specify name of channel<br>
&emsp;-l, --limit : set limit on number of messages shown (OPTIONAL)<br>
&emsp;Default value of limit is 10.<br>
&emsp;e.g. `inbox -s server1 -c ch1 -l 3`<br><br>

- `leave [OPTION(s)]`<br>
**Usage**: Leave a server/ channel within a server<br>
&emsp;-s, --server : specify name of server to be left<br>
&emsp;User is removed from that server.<br>
&emsp;-c, --channel : specify name of channel to be left (OPTIONAL)<br>
&emsp;User is removed from only that channel in the particular server.<br>
&emsp;e.g. `leave -s server1 -c ch1`<br><br>

- `bye`<br>
**Usage**: Delete account<br><br>

**_Commands only accessible to moderators and creator_**

- `admit [OPTIONS]`<br>
**Usage**: Admit a user in a server<br>
&emsp;-u, --username : specify username<br>
&emsp;-s, --server : specify name of server<br>
&emsp;e.g. `admit -u user1 -s server1`<br><br>

- `remove [OPTIONS]`<br>
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

- `addMod [OPTIONS]`<br>
**Usage**: Promote a member of a server to moderator<br>
&emsp;-u, --username : specify username of member<br>
&emsp;-s, --server : specify name of server<br>
&emsp;e.g. `sudo -o addMod -u user1 -s server1`<br><br>

- `removeMod [OPTIONS]`<br>
**Usage**: Demote a moderator of a server to member<br>
&emsp;-u, --username : specify username of moderator<br>
&emsp;-s, --server : specify name of server<br>
&emsp;e.g. `sudo -o removeMod -u user1 -s server1`<br><br>
