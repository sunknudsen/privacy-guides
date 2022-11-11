<!--
Title: How to disable CUPS printer job history on macOS
Description: Learn how to disable CUPS printer job history on macOS.
Author: Sun Knudsen <https://github.com/sunknudsen>
Contributors: Sun Knudsen <https://github.com/sunknudsen>
Reviewers:
Publication date: 2022-10-29T13:05:18.112Z
Listed: true
-->

# How to disable CUPS printer job history on macOS

[![macOS stores a copy of everything one prints forever](macos-stores-a-copy-of-everything-one-prints-forever.jpeg)](https://www.youtube.com/watch?v=eAgfeVNKdoo "macOS stores a copy of everything one prints forever")

## Requirements

- Computer running macOS Monterey or Ventura

## Setup guide

### Step 1: Reconfigure CUPS:

```shell
$  cupsctl MaxJobTime=5m PreserveJobFiles=no PreserveJobHistory=no
```

From [`cupsd.conf`](https://www.cups.org/doc/man-cupsd.conf.html) documentation:
<dl><dt><a name="MaxJobs"></a><b>MaxJobs </b><i>number</i></dt><dd style="margin-left: 5.0em">Specifies the maximum number of simultaneous jobs that are allowed. Set to "0" to allow an unlimited number of jobs; the default is "500".</dd><dt><a name="MaxJobTime"></a><b>MaxJobTime </b><i>seconds</i></dt><dd style="margin-left: 5.0em">Specifies the maximum time a job may take to print before it is canceled.
	Set to "0" to disable cancellation of "stuck" jobs.
	The default is "10800" (3 hours).</dd><dt><a name="PreserveJobFiles"></a><b>PreserveJobFiles</b> Yes | No | <i>seconds</i></dt><dd style="margin-left: 5.0em">Specifies whether job files (documents) are preserved after a job is printed.
	If a numeric value is specified, job files are preserved for the indicated number of seconds after printing.
	The default is "86400" (preserve 1 day).</dd><dt><a name="PreserveJobHistory"></a><b>PreserveJobHistory</b> Yes | No | <i>seconds</i></dt><dd style="margin-left: 5.0em">Specifies whether the job history is preserved after a job is printed.
	If a numeric value is specified, the job history is preserved for the indicated number of seconds after printing.
	If "Yes", the job history is preserved until the MaxJobs limit is reached.
	The default is "Yes".</dd></dl>

### Step 2: clear job history

Clear out any completed jobs using the new settings from Step 1 (note: this does not affect any active jobs in the queue)

```shell
$ lpstat -W completed -o
```

### Step 3: Setup cronjob to clear out jobs

> Note: Jobs *should* automatically be purged upon completion if you're using the settings above, but *may* persist in some specific cases (e.g., if cups is restarted in the middle of a job, [see this](https://access.redhat.com/solutions/5914031)). This cron job will ensure that any jobs that persist are cleaned out using the `PreserveJobFiles` and `PreserveJobHistory` settings you defined in Step 1:

```shell
if ! crontab -l 2>/dev/null | grep -q CUPS-QUEUE-PURGE; then
	crontab <(crontab -l 2>/dev/null; echo -en "\n# CUPS-QUEUE-PURGE: ensure that print jobs are cleaned out after they're expired\n* * * * * /usr/bin/lpstat -W completed -o")
fi
```

👍

---

## Want things back the way they were before following this guide? No problem!

### Step 1:  Reset config parameters to defaults

```shell
$  cupsctl MaxJobTime= PreserveJobFiles= PreserveJobHistory=
```

👍
