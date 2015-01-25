# stall-monitor-swift
### OS X menubar app built in swift that reads status from a webservice

## What is this?
This is a [menubar app](http://en.wikipedia.org/wiki/Menu_bar#Macintosh) for Mac OS X.
It pings a restful webservice (you need to provide that url) and updates text and an icon based on the return of that call.

## Why?
This project (along with a node.js webservice and spark core) determine when our office bathroom is in use and update our employees without the need for them to get up and check the stall.

### Related Projects
There is a spark core sketch that updates the web service when the position of a reed switch changes. That is available at: [stall-monitor-spark](https://github.com/supersimple/stall-monitor-spark)
