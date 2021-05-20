/** Definitions related to the FreeMarker Templating library. */

import semmle.code.java.Type

/** The `Template` class of FreeMarker Template Engine */
class TypeFreeMarkerTemplate extends Class {
  TypeFreeMarkerTemplate() { this.hasQualifiedName("freemarker.template", "Template") }
}

/** The `process` method of FreeMarker Template Engine's `Template` class */
class MethodFreeMarkerTemplateProcess extends Method {
  MethodFreeMarkerTemplateProcess() {
    getDeclaringType() instanceof TypeFreeMarkerTemplate and
    hasName("process")
  }
}

/** The `StringTemplateLoader` class of FreeMarker Template Engine */
class TypeFreeMarkerStringLoader extends Class {
  TypeFreeMarkerStringLoader() { this.hasQualifiedName("freemarker.cache", "StringTemplateLoader") }
}

/** The `process` method of FreeMarker Template Engine's `StringTemplateLoader` class */
class MethodFreeMarkerStringTemplateLoaderPutTemplate extends Method {
  MethodFreeMarkerStringTemplateLoaderPutTemplate() {
    getDeclaringType() instanceof TypeFreeMarkerStringLoader and
    hasName("putTemplate")
  }
}
