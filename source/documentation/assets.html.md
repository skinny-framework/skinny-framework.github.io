---
title: Assets Support - Skinny Framework
---

## Assets Support

![CoffeeScript Logo](images/coffeescript.png)
![LESS Logo](images/less.png)
![Sass Logo](images/sass.png)

First, add `skinny-assets` to libraryDependencies.

```
libraryDependencies ++= Seq(
  "org.skinny-framework" %% "skinny-framework" % "[0.9,)",
  "org.skinny-framework" %% "skinny-assets"    % "[0.9,)",
  "org.skinny-framework" %% "skinny-test"      % "[0.9,)" % "test"
)
```

And then, add `AssetsController` to routes. Now you can easily use CoffeeScript, LESS and Sass.

```java
// src/main/scala/ScalatraBootstrap.scala
class ScalatraBootstrap exntends SkinnyLifeCycle {
  override def initSkinnyApp(ctx: ServletContext) {
    AssetsController.mount(ctx)
  }
}
```

AssetsController supports Last-Modified header and returns status 304 correctly if the requested file isn't changed.

However, precompiling them is highly recommended in production (./skinny package does that).

<hr/>
### CoffeeScript

If you use CoffeeScript, just put *.coffee files under `WEB-INF/assets/coffee`:

```coffeescript
# src/main/webapp/WEB-INF/assets/coffee/echo.coffee
echo = (v) -> console.log v
echo "foo"
```

You can access the latest compiled JavaScript code at `http://localhost:8080/assets/js/echo.js`.

<hr/>
### LESS

If you use LESS, just put *.less files under `WEB-INF/assets/less`:

```less
// src/main/webapp/WEB-INF/assets/less/box.less
@base: #f938ab;
.box {
  color: saturate(@base, 5%);
  border-color: lighten(@base, 30%);
}
```

You can access the latest compiled CSS file at `http://localhost:8080/assets/css/box.css`

<hr/>
### Sass

If you use Sassy CSS, put *.scss files under `WEB-INF/assets/scss` or `WEB-INF/assets/sass`. If you use Sass Indented Syntax, put *.sass files under `WEB-INF/assets/sass`.

```scss
// src/main/webapp/WEB-INF/assets/scss/main.scss
$font-stack:    Helvetica, sans-serif;
$primary-color: #333;
body {
  font: 100% $font-stack;
  color: $primary-color;
}
```

You can access the latest compiled CSS file at `http://localhost:8080/assets/css/main.css`


<hr/>
### Adding compilers

If you need other script support, you can add compiler to AssetsController.

AssetsController: [assets/src/main/scala/skinny/controller/AssetsController.scala](https://github.com/skinny-framework/skinny-framework/blob/master/assets/src/main/scala/skinny/controller/AssetsController.scala)

```java
object TypeScriptAssetCompiler extends AssetCompiler {
  private[this] val compiler = TypeScriptCompiler()
  def dir(basePath: String) = s"${basePath}/ts"
  def extension = "ts"
  def compile(source: String) = compiler.compile(source)
}

class MyAssetsController extends AssetsController {
  registerJsCompiler(TypeScriptAssetCompiler)
}
object MyAssetsController extends MyAssetsController with Routes {
  get(s"${jsRootPath}/*")(js).as('js)
  get(s"${cssRootPath}/*")(css).as('css)
}

// src/main/scala/ScalatraBootstrap.scala
class ScalatraBootstrap exntends SkinnyLifeCycle {
  override def initSkinnyApp(ctx: ServletContext) {
    MyAssetsController.mount(ctx)
  }
}
```


