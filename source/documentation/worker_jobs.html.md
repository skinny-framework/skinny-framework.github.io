---
title: Worker Jobs - Skinny Framework
---

## Worker Jobs

<hr/>
### How to use SkinnyWorkerService
<hr/>

Skinny's WorkerService is a simple wrapper of Java built-in `ExecutorService` and prepared in Skinny apps by default. 

You can access it as `skinnyWorkerService` in `ScalatraBootstrap.scala` and just call scheduling methods.

```scala
import skinny._
import skinny.worker._
import skinny.controller._
import _root_.controller._

class ScalatraBootstrap extends SkinnyLifeCycle {

  override def initSkinnyApp(ctx: ServletContext) { 

    val worker = new SkinnyWorker {
      def execute = {
        println("Hello World!")
      }
    }

    // will be invoked every 300 milliseconds
    skinnyWorkerService.everyFixedMilliseconds(worker, 300)
    // will be invoked every 10 seconds
    skinnyWorkerService.everyFixedSeconds(worker, 10)
    // will be invoked every 4 minutes
    skinnyWorkerService.everyFixedMinutes(worker, 4)
    // will be invoked at 01:30, 02:30, ....
    skinnyWorkerService.hourly(worker, 30)
    // will be invoked at 09:20 AM everyday
    skinnyWorkerService.daily(worker, 9, 20)

    // Routes
    ...
    Controllers.root.mount(ctx)

  }

}
```

`SkinnyWorker`'s rule is very simple. `SkinnyWorker` object is a `java.lang.Runnable` one.

And developers just implement the abstract `def execute(): Unit` method.

```scala
import skinny.worker._
import model._

class SampleWorker extends SkinnyWorker {

  override def execute = {
    // If an exception is thrwon from this method, 
    ImportantOperation.run()
  }

  override def handle(t: Throwable) = {
    // handles exceptions from execute method
    ErrorMailer.send(t)
  }

}
