# Log Injection - See and Understand the Vulnerability

The goal of this page is to raise awareness and understanding of the log injection vulnerability. Watch the following one-minute videos to see different log injection scenarios and exploits. Details and explanations are below.

The demonstrations are built with Java, Spring Boot, and log4j, but the vulnerability is not tied to these specific technologies.

## See Log Injection in Action

* Ep1
* Ep2
* Ep3

## What Is a Log Injection?

A log injection is a generic vulnerability that occurs when an application receives untrusted data (often that would be data in an http request) and writes this data to a log without making sure that the data is in some sense safe. The sequence of events is typically as follows:

* an attacker submits malicious input to an application
* the application writes that input to a log
* the log is (later) processed by one or more log-processing system (which may have vulnerabilities)
* and/or the log is reviewed by a human

The malicious log content can mislead the human reviewer and/or compromise log processing. The goals of the attack are to undermine forensics and to bypass logging-related security mechanisms. Furthermore, exploiting a vulnerability in a log processor can be used to further escalate damage.


## Examples of Malicious Inputs

A log injection is a generic vulnerability that can be used to inject various kinds of malicious inputs into the logs.  Here is an incomplete list of popular examples of unsafe log content and its impact.

<table><tbody>
<tr><th>character class </th><th> potential impact </th><th> example (plain text)</th></tr>
<tr><td>newlines   </td><td>     create fake log entries</td></tr>
<tr><td>ANSI sequences </td><td>  hide log entries in a terminal </td><td> <code>^[[2K^[[1A</code></td></tr>
<tr><td>JavaScript  </td><td>    exploit potential XSS in log dashboards </td><td> <code>&lt;img src=1 onerror="javascript:alert('pwned')"&gt;</code></td></tr>
<tr><td>Unicode homographs     </td><td>   undermine forensics (via strings that differ but look the same) </td><td> <code>admin</code> vs <code>аdmin</code></td></tr>
<tr><td>lookup expressions </td><td>     exploit potential vulnerabilities in the logging library </td><td> <code>${jndi:ldap:...}</code></td></tr>
</tbody></table>

Each of these scenarios may or may not apply to you. For example, if your application writes logs in a JSON format. then you typically already have protection against newline injection and creation of fake log entries. At the same time, you are typically still not protected against JavaScript or Unicode homograph injection.

In general, there is no ultimate definition of what is safe or unsafe to log - that depends on how your logs are processed and your risk appetite. Unfortunately, experience shows that in practice logs are often "promiscuous" - they can move around and be processed in a variety of systems, sometimes in surprising ways and a long time after their creation. It is thus better to implement more protections than less. Luckily, it is possible to do so.

## Mitigations

Coming soon.

