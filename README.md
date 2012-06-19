Synopsis
========

These scripts allow for post-mortem analysis of an Apache access\_log file to
determine the number of requests per second. Normally this is graphed with
something like mod\_status and Munin. If you run into a situation where all you
have is the access\_log file, this will allow a reasonable approximation of what
mod\_status would have returned.

A sample graph showing a loaded server and the request spikes:

<figure>
  ![Sample graph](http://deviantintegral.github.com/apache_rps/images/rps-graph-sample.png)
  <figcaption class="center">_A sample graph showing a loaded server subjec to request spikes_</figcaption>
</figure>

Usage
=====

Note that apache\_rps.sh requires bash 4.0+ due to the use of associative
arrays.

    $ ./apache_rps.sh <day> <access_log> <destination csv>

Day should be in the format of a date in your access\_log, such as:

    $ ./apache_rps.sh 01/Jun/2012 access_log 20120601.csv

Graphs are generated using R, where '100' is the maximum simultaneous
connections your server is expected to support:

    $ R --no-save --args 20120601.csv 100 < rps_daygraph.r

Caveats
=======
 * Apache logs requests when they complete, not when they start. There's no way
   to reconstruct when requests start from the access\_log.
 * apache\_rps.sh currently assumes that all of the logs from a given day are
   in a single uncompressed file. If they aren't, use grep and zgrep to create
   a single file to pass in.
 * The bulk of the CSV generation is a simple line count. It should work with
   other similar log files from other web servers such as Varnish. It's only
   been tested with Apache in one specific configuration. Pull requests welcome!

