/** Definitions related to the Jinjava Templating library. */

import semmle.code.java.Type

/** The `Jinjava` class of Jinjava Templating Engine. */
class TypeJinjava extends Class {
  TypeJinjava() { hasQualifiedName("com.hubspot.jinjava", "JinJava") }
}

/** The `render` method of Jinjava Templating Engine. */
class MethodJinjavaRender extends Method {
  MethodJinjavaRender() {
    getDeclaringType() instanceof TypeJinjava and
    hasName("render")
  }
}

/** The `render` method of Jinjava Templating Engine. */
class MethodJinjavaRenderForResult extends Method {
  MethodJinjavaRenderForResult() {
    getDeclaringType() instanceof TypeJinjava and
    hasName("renderForResult")
  }
}
