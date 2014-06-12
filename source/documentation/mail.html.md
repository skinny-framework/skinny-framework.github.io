---
title: Mail - Skinny Framework
---

## Mail

<hr/>
### Out-of-the-box SkinnyMailer
<hr/>

`SkinnyMailer` is the out-of-the-box email module for Skinny applications.

It's also available as a standalone library, so you can use skinny-mailer for any other use cases.

<hr/>
### Sending emails via GMail STMP servers
<hr/>

To understand how to use SkinnyMailer, try the following code on the Scala REPL (`./skinny console`)

```scala
// https://support.google.com/accounts/answer/185833
val yourGmail = "*****@gmail.com"
val yourPassword = "*****"

import skinny.mailer._

// Prepare configuration for GMail SMTP
val config = SkinnyMailerConfig.default.copy(
  debug = true,
  defaultFrom = Some(yourGmail),
  transportProtocol = "smtps",
  smtp = SkinnyMailerSmtpConfig.default.copy(
    host = "smtp.gmail.com",
    port = 465,
    authEnabled = true,
    user = Some(yourGmail),
    password = Some(yourPassword)
  )
)

// create a SkinnyMailer
val GMail = SkinnyMailer(config)

// Simply sending a text mail
GMail.
  to(yourGmail).
  cc(yourGmail).
  subject("SkinnyMailer GMail Test").
  body {
    """You succeeded sending email via GMail SMTP server!
    |
    |Blah-blah-blah...
    |
  """.stripMargin
  }.deliver()

// Sending HTML email with attachments
GMail.
  to(yourGmail).
  cc(yourGmail).
  subject("SkinnyMailer GMail Test 2").
  htmlBody("<hr/><b>HTML</b> sample!<br/><hr/>").
  attchment("memo.txt", "memomemo", "text/plain; charset=utf-8").
  deliver()
```

<hr/>
### Configuration in application.conf
<hr/>

Configuration should be defined in src/main/resources/application.conf.

```
development {
  db {
    default {
      driver="org.h2.Driver"
      url="jdbc:h2:file:db/example-development"
      user="sa"
      password="sa"
      poolInitialSize=2
      poolMaxSize=10
    }
  }
  mailer {
    default {
      debug=true
      mimeVersion="1.0"
      charset="UTF-8"
      contentType="text/html"
      from="xxxxx+from@gmail.com"
      smtp {
        host="smtp.gmail.com"
        port=465
        connectTimeoutMillis=3000
        readTimeoutMillis=6000
        starttls {
          enabled:true
        }
        auth {
          //enabled=true
          enabled=false
          user="xxxxx@gmail.com"
          password=${?GMAIL_PASSWORD}
        }
      }
      transport {
        //protocol="smtps"
        protocol="logging"
      }
    }
  }
}
```

<hr/>
### How to use it in controllers
<hr/>

MailController.scala:

https://github.com/skinny-framework/skinny-framework/blob/1.1.x/example/src/main/scala/controller/MailController.scala

Configuration:

https://github.com/skinny-framework/skinny-framework/blob/1.1.x/example/src/main/resources/application.conf
