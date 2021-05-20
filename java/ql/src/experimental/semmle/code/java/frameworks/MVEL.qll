/** Definitions related to the MVEL Templating library. */

import semmle.code.java.Type

/** The `org.mvel2.templates.TemplateCompiler` class of MVEL Templating Engine. */
class MVELTemplateCompiler extends Class {
  MVELTemplateCompiler() { this.hasQualifiedName("org.mvel2.templates", "TemplateCompiler") }
}

/** The `compileTemplate` methods of MVEL Templating Engine. */
class MethodMVELCompileTemplate extends Method {
  MethodMVELCompileTemplate() {
    this.getName() = "compileTemplate" and
    this.getDeclaringType() instanceof MVELTemplateCompiler
  }
}
