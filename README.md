# Log Injection - See and Understand the Vulnerability

The goal of this page is to raise awareness and understanding of the log injection vulnerability. Watch the following one-minute videos to see different log injection scenarios and exploits. Details and explanations are below.

The demonstrations are built with Java, Spring Boot, and log4j, but the vulnerability is not tied to these specific technologies.

## See Log Injection in Action

* Ep.1 "Newlines" (0:53)
* Ep.2 "ANSI Sequences" (0:58)
* Ep.3 "JavaScript" (1:11)

### Ep.1 "Newlines" (0:53)

https://github.com/vlkl-sap/log-injection-demo/assets/71723302/70437d75-19a8-481b-843e-1a7ded3af92c

### Ep.2 "ANSI Sequences" (0:58)

https://github.com/vlkl-sap/log-injection-demo/assets/71723302/985c4156-0ad1-46cc-b36f-c43e7dc58aa7

### Ep.3 "JavaScript" (1:11)

https://github.com/vlkl-sap/log-injection-demo/assets/71723302/243cb444-fbad-4c54-af0b-b88ed6fc107c


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

## Mitigations (work in progress)

## Mitigations

Unfortunately, there is currently no "push-button" mitigation for log injection. I will explain different approaches and trade-offs below. The explanation will feature Java, but the concepts apply to other technologies as well.

### How to Neutralize Dangerous Inputs

I strongly advise **against** trying to sanitize the input (i.e., trying to **delete** potentially dangerous characters from it - `s.replace("\\n","")` and the like). There are several reasons but the main one is that such sanitization is not reversible. Yet, for forensical purposes, we always want to preserve the original input (while still neutralizing the danger it may exude). 

The best mitigation is thus **encoding**. Various encodings are possible - URL-encoding (also known as percent-encoding) is a good choice. It is reversible, easy to imoplement, and protects against a very wide range of dangerous inputs.

### Where to Neutralize

#### Variant 1: At the point of logging

This variant is conceptually simple and flexible. It also protects against any vulnerabilities in the logging library iteself (famous example: CVE-2021-44228 Log4Shell).

Define a helper method as follows:
```
    public static String encode(String s) {
        return java.net.URLEncoder.encode(s,
            java.nio.charset.StandardCharsets.UTF_8);
    }
```
and utilize this encoder when logging untrusted data, e.g.:
```
    @GetMapping("/endpoint")
    public String endpoint(@RequestParam("data") String s) {
        Logger logger = LoggerFactory.getLogger(Controller.class);
        logger.info("Received data item {}", encode(s));
        return "OK";
    }
```
Note that untrusted data has to be encoded when storing it in a ThreadContext or MDC (these are examples of a user-constructed key-value map that a logger library will include in the log entry). The same recommendation applies when constructing exceptions.

Don't: `throw new IllegalArgumentException(s);`

Do: `throw new IllegalArgumentException(encode(s));`

Consistent usage of encoding can be enforced by static analysis (or even grep).


#### Variant 2: Logger configuration - structured layout

Configuring a structured log layout (e.g., a JSON layout) already protects against some log injection scenarios, as the logging library will typically encode the characters that have a special meaning in JSON. An attacker will thus not be able to change the structure of the log record and thus create fake log entries. Injection of JavaScript and misdirection with homographs is typially still possible, though. With some logging libraries, users can supply additional encoders, which would help to mitigate these attack scenarios as well.

#### Variant 3: Logger configuration - pattern layout

