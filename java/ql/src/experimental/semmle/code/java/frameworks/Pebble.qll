/** Definitions related to the Pebble Templating library. */

import semmle.code.java.Type

/** The `PebbleEngine` class of Pebble Templating Engine. */
class TypePebbleEngine extends Class {
  TypePebbleEngine() { hasQualifiedName("com.mitchellbosecke.pebble", "PebbleEngine") }
}

/** The `getTemplate` method of Pebble Templating Engine. */
class MethodPebbleGetTemplate extends Method {
  MethodPebbleGetTemplate() {
    getDeclaringType() instanceof TypePebbleEngine and
    hasName("getTemplate") or 
    hasName("getLiteralTemplate")
  }
}
