dns-any-monitor
===============

Monitoring script for DNS ANY queries
These run, ideally, from cron on your system.
  - collect_any.sh - does collection to a defined
    log stash.

  - cleanup_caps.sh - cleans the log stash so disk space
    won't forever disappear.

Example crontab entries:
# Restart/start the dns any collection infrastructure.
*/2 * * * * /usr/local/scripts/collect_any.sh eth0 > /dev/null 2>&1
# Each 10 mins, rotate the dns-any collection to viewable space
*/6 * * * * /usr/local/scripts/cleanup_caps.sh > /tmp/dns-cleanup.log 2>&1

