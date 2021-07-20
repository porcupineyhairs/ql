/** Definitions related to the Thymeleaf Templating library. */

import semmle.code.java.Type

/** The `TemplateEngine` class of Thymeleaf Templating Engine. */
class TypeThymeleafTemplateEngine extends Class {
  TypeThymeleafTemplateEngine() { hasQualifiedName("org.thymeleaf", "TemplateEngine") }
}

/** The `IResourceResolver` class of Thymeleaf Templating Engine. */
class TypeThymeleafIResourceResolver extends Class {
  TypeThymeleafIResourceResolver() {
    hasQualifiedName("org.thymeleaf.resourceresolver", "IResourceResolver")
  }
}

/** The `process` method of Thymeleaf Templating Engine. */
class MethodThymeleafProcess extends Method {
  MethodThymeleafProcess() {
    getDeclaringType() instanceof TypeThymeleafTemplateEngine and
    hasName("process")
  }
}

/** The `getResourceAsStream` method of Thymeleaf Templating Engine. */
class MethodThymeleafGetResourceAsStream extends Method {
  MethodThymeleafGetResourceAsStream() {
    getDeclaringType().getASupertype*() instanceof TypeThymeleafIResourceResolver and
    hasName("getResourceAsStream")
  }
}
