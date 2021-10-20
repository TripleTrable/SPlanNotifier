StarPlaner Parser
=================


Description
-----------

A simple parser and notifier for starplaner timetables.


Usage:
------

Currently only supports:

```
splanNotify -v url
```

Dependencies:
-------------

 - curl
 - awk
 - notify-send


TODO:
-----

 - [X] -v push notifications for all lectures
 - [ ] -q show no notifications
 - [ ] -c push only changed notifications
 - [ ] -n push only next lectures

 - [X] Automaticly convert URL
 - [ ] Add stdout support

 - [ ] Optimise
 - [ ] Convert shell script to c program
 - [ ] Add `make install`
 - [ ] Add packman package support



Author:
-------
Lars Niesen <Lars.Niesen@gmx.de>
