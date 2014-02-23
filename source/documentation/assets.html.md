---
title: Assets Support - Skinny Framework
---

# Assets Support
<hr/>

![CoffeeScript Logo](images/coffeescript.png)
![LESS Logo](images/less.png)
![Sass Logo](images/sass.png)
![React Logo](images/react.png)

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

However, precompiling them is highly recommended in production (`./skinny package` does that).

<hr/>
## CoffeeScript
<hr/>

![CoffeeScript Logo](images/coffeescript.png)

http://coffeescript.org/

Skinny tries to find the native compiler (`npm install -g coffee-script`) at first.
If it's absent, Skinny uses its own compiler on the Rhino JS engine. So you don't need to prepare a CoffeeScript compiler in advance.

Easy to start! Just put *.coffee files under `WEB-INF/assets/coffee`:

```coffeescript
# src/main/webapp/WEB-INF/assets/coffee/echo.coffee
echo = (v) -> console.log v
echo "foo"
```

You can access the latest compiled JavaScript code at `http://localhost:8080/assets/js/echo.js`.

<hr/>
## LESS
<hr/>

![LESS Logo](images/less.png)

http://lesscss.org/

Skinny tries to find the native compiler (`npm install -g less`) at first.
If it's absent, Skinny uses its own compiler on the Rhino JS engine. So you don't need to prepare a LESS compiler in advance.

Easy to start! Just put *.less files under `WEB-INF/assets/less`:

```less
// src/main/webapp/WEB-INF/assets/less/box.less
@base: #f938ab;
.box {
  color: saturate(@base, 5%);
  border-color: lighten(@base, 30%);
}
```

You can access the latest compiled CSS file at `http://localhost:8080/assets/css/box.css`.

<hr/>
## Sass
<hr/>

![Sass Logo](images/sass.png)

http://sass-lang.com/

Sass is implemented in Ruby and it works on the Ruby runtime. You will need to prepare a Ruby runtime and Sass native compiler in advance.

And then, just put *.scss files under `WEB-INF/assets/scss` or `WEB-INF/assets/sass`.

If you use Sass Indented Syntax, put *.sass files under `WEB-INF/assets/sass`.

```scss
// src/main/webapp/WEB-INF/assets/scss/main.scss
$font-stack:    Helvetica, sans-serif;
$primary-color: #333;
body {
  font: 100% $font-stack;
  color: $primary-color;
}
```

You can access the latest compiled CSS file at `http://localhost:8080/assets/css/main.css`.


<hr/>
## JSX for React
<hr/>

![React Logo](images/react.png)

http://facebook.github.io/react/

Skinny tries to find the native compiler (`npm install -g react-tools`) at first.
If it's absent, Skinny uses its own compiler on the Rhino JS engine. So you don't need to prepare a JSX compiler in advance.

Easy to start! Just put *.jsx files under `WEB-INF/assets/jsx`:

```xml
// src/main/webapp/WEB-INF/assets/jsx/react-example.jsx
/** @jsx React.DOM */
React.renderComponent(
  <h1>Hello, world!</h1>,
  document.getElementById('example')
);
```

You can access the latest transformed JS file at `http://localhost:8080/assets/js/react-example.js`.

<hr/>
## Adding Other Compilers
<hr/>

If you need other script support, you can add compilers to AssetsController.

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


