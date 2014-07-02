---
title: HTTP Client - Skinny Framework
---

## Handy HTTP Client

Skinny Framework has a quite simple and handy HTTP client library. Of couse, you can use it with non-Skinny apps.

<hr/>
### Simple Usage
<hr/>

Basically, test code will help you to learn how to use.

[http-client/src/test/scala/skinny/http/HTTPSpec.scala](https://github.com/skinny-framework/skinny-framework/blob/1.1.x/http-client/src/test/scala/skinny/http/HTTPSpec.scala)

```scala
import skinny.http._
import scala.concurrent.Await
import scala.concurrent.duration._

// GET
val response: Response = HTTP.get("http://localhost:8077/api?foo=bar")

case class Response(
  status: Int,
  headers: mutable.Map[String, String],
  headerFields: mutable.Map[String, Seq[String]],
  rawCookies: mutable.Map[String, String],
  charset: Option[String],
  body: Array[Byte]) {

  def header(name: String): Option[String] 
  def headerField(name: String): Seq[String]
  def asBytes: Array[Byte]
  def textBody: String
  def asString: String 
}

// GET with QueryParams

val response = HTTP.get("http://localhost:8177/", "foo" -> "bar")
val response = HTTP.get(Request("http://localhost:8277/").queryParams("foo" -> "bar"))
val response = HTTP.get(Request("http://localhost:8278/").queryParam("foo" -> "bar").queryParam("bar" -> "baz"))

// GET with charset
val response = HTTP.get("http://localhost:8377/?foo=bar", "UTF-8")

// Async GET

val response: Future[Response] = HTTP.asyncGet("http://localhost:8077/?foo=bar")
val response = HTTP.asyncGet("http://localhost:8177/", "foo" -> "bar")
val response = HTTP.asyncGet(Request("http://localhost:8278/").queryParams("foo" -> "bar"))
val response = HTTP.asyncGet("http://localhost:8377/?foo=bar", "UTF-8")

// POST

val response = HTTP.post("http://localhost:8187/", "foo=bar")
val response = HTTP.post("http://localhost:8287/", "foo" -> "bar")
val response = HTTP.postMultipart("http://localhost:8888/", FormData("toResponse", TextInput("bar")))

val file = new java.io.File("http-client/src/test/resources/sample.txt")
val response = HTTP.postMultipart("http://localhost:8888/", FormData("toResponse", FileInput(file, "text/plain")))

val response = HTTP.asyncPost("http://localhost:8187/", "foo=bar")
val response = HTTP.asyncPost("http://localhost:8287/", "foo" -> "bar")
val response = HTTP.asyncPostMultipart("http://localhost:8888/", FormData("toResponse", TextInput("bar")))

// PUT

val response = HTTP.put("http://localhost:8186/", "foo=bar")
val response = HTTP.put("http://localhost:8285/", "foo" -> "bar")
val response = HTTP.asyncPut("http://localhost:8186/", "foo=bar")
val response = HTTP.asyncPut("http://localhost:8286/", "foo" -> "bar")

// DELETE

val response = HTTP.delete("http://localhost:8485/resource")
val response = HTTP.asyncDelete("http://localhost:8486/resource")

// TRACE

val response = HTTP.trace("http://localhost:8585/resource")
val response = HTTP.asyncTrace("http://localhost:8586/resource")

// OPTIONS

val response = HTTP.options("http://localhost:8685/resource")
val response = HTTP.asyncOptions("http://localhost:8686/resource")
```

