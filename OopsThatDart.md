# [Education Tour] Adventure 6: Throw that Dart!

### Post Lecture Assignment
**_Deadline 17 July, 11:59pm_**

Time to sharpen your Dart & OOPs skills! Any extra features will give you brownie points for an assignment in one of the next lectures (secret for now)!

Feel free to contact in case of any doubts :)

Q) By now you must have tried doing something on the terminal. Maybe it was a `cd` or `git commit -m "msg"`. Ever wondered how to create these wonderful applications (yes they're!)? Now the time is to act upon as the task for the assignment, you guessed it, is to create a Command Line Interface Application. Appication on what? You've used discord haven't you? What would be like if you have to type in something specific to send a message?

### Make a class based CLI application for Discord. 

This features are compulsory to have in your solution:

- **Register a User:**
Register(signup) a user with their username, If user is already registered, print `faliure`.
_Input example_: `register 2 user1 user2`
_Expected output_: `success`

- **Login users:**
Login user(s) , based on their username. Only registered users can login and only logged in users can do the following operations. On Exception (make a custom exception), print in the following format:
`Exception Type: User not found`
_Input Example_: `login 1 user1`
_Expected output_: `login success`

- **Logout users:** 
Logout a user given their username. Make an Exception class on faliure and print it in the "above operation" followed format.
_Input Example_: `logout 1 user1`
_Expected output_: `logout success`

- **Join server:**
Join a server, given the server name and username. If user is already joined, print `{username} already joined`
_Input example_: `join user1 server1`
_Expected output_: `join success`

-  **Add channel/category:**
Adds a channel with or without a category to a given server. Note that server should exist before adding a channel. Category can be null.
_Input Example:_ `createc server1 category1 text`
_Output Example:_ `text channel created`

<!-- Inspiration of the question: https://github.com/Rapptz/discord.py -->

- **Send message in channel:**
A channel belongs to a category in a server, it can be of 5 types, Text, Voice, Stage, Rules, Announcement. Message can only be sent without any permission in Text and Announcement Channels. Other channels require mod access to send a message (Note that mod is a role). Message can only be sent to a channel which exists. 

Example 1
_Input Example_: `send user1 server1 newbie category1 text Hello World!`
_Output Example:_ `message sent!`

Example 2
_Input Example:_ `send user1 server1 mod null stage Hello World!`
_Output Example:_ `message sent!`

- **Print mod users in a server:**
Print the list of users in a server that have the moderator role.

_Input Example:_ `print server1`
_Output Example:_ 
```
printing server1...
user1
user2
```
- **Print categories in a server:**
Print the list of categories in a server. The categories should be printed after a delay of 2 seconds.
_Input Example:_ `category server1`
_Output Example_:
```
printing categories in server1...
category1
category2
```

- **Lock channels for diiferent roles to send messages in channels**
- **Allow users to DM each other**
- **Have different channel & server types**

You should keep in mind the following:
- You can use a storage option of your choice. 
- Please note that the above examples are for illustrative purposes, you have to come up with your own commands.
- A modular approach to code the project is expected from y'all.
- This is a group project, kindly find the parings as below:
  - G1: Sasmit Aditya, Hardik Narang
  - G2: Roopam Taneja, Divij Rawal
  - G3: Radhika Maheshwari, Saurabh Rana
  - G4: Anshita Jain, Manav Agarwal
  - G5: Angel Sharma, Abishek Arun
  - G6: Vanni Prashar, Ayush Shankaram
  - G7: Saksham Jain, Shashwat Papne
  - G8: Aditya Chopra, Dhruv
  - G9: Pulkit Garg, Pranav
  - G10: Alice, Dhruv Goyal
  - G11: Utkarsh Sharma, Utsah, Jasleen Kaur

### Reference material
- Code snippet from lecture [here](https://gist.github.com/just-ary27/215b5a387ceef8e8d69273821f827c17).
- [Article](https://medium.com/flutter/flutter-dont-fear-the-garbage-collector-d69b3ff1ca30) on Garbage collection in Dart & Flutter.
- [Article](https://medium.com/flutter-community/mastering-flutter-modularization-in-several-ways-f5bced19101a) on a modular approach.
- Forgot the syntax here's a [quick guide.](https://dart.dev/guides/language/language-tour)