/** Definitions related to the Apache Velocity Templating library. */

import semmle.code.java.Type

/** The `org.apache.velocity.VelocityContext` class of Velocity Templating Engine. */
class TypeVelocityContext extends Class {
  TypeVelocityContext() { hasQualifiedName("org.apache.velocity", "VelocityContext") }
}

/** The `org.apache.velocity.context.AbstractContext` class of Velocity Templating Engine. */
class TypeVelocityAbstractContext extends Class {
  TypeVelocityAbstractContext() {
    hasQualifiedName("org.apache.velocity.context", "AbstractContext")
  }
}

/** The `org.apache.velocity.runtime.RuntimeServices` class of Velocity Templating Engine. */
class TypeVelocityRuntimeRuntimeServices extends Class {
  TypeVelocityRuntimeRuntimeServices() {
    hasQualifiedName("org.apache.velocity.runtime", "RuntimeServices")
  }
}

/** The `org.apache.velocity.runtime.RuntimeSingleton` class of Velocity Templating Engine. */
class TypeVelocityRuntimeRuntimeSingleton extends Class {
  TypeVelocityRuntimeRuntimeSingleton() {
    hasQualifiedName("org.apache.velocity.runtime", "RuntimeSingleton")
  }
}

/** The `org.apache.velocity.VelocityEngine` class of Velocity Templating Engine. */
class TypeVelocityVelocityEngine extends Class {
  TypeVelocityVelocityEngine() { hasQualifiedName("org.apache.velocity", "VelocityEngine") }
}

/** The `org.apache.velocity.app.VelocityEngine` class of Velocity Templating Engine. */
class TypeVelocityAppVelocityEngine extends Class {
  TypeVelocityAppVelocityEngine() { hasQualifiedName("org.apache.velocity.app", "VelocityEngine") }
}

/** The `org.apache.velocity.app.Velocity` class of Velocity Templating Engine. */
class TypeVelocityAppVelocity extends Class {
  TypeVelocityAppVelocity() { hasQualifiedName("org.apache.velocity.app", "Velocity") }
}

/**
 * The `org.apache.velocity.runtime.resource.util.StringResourceRepository` class
 * of Velocity Templating Engine.
 */
class TypeVelocityStringResourceRepo extends Class {
  TypeVelocityStringResourceRepo() {
    hasQualifiedName("org.apache.velocity.runtime.resource.util", "StringResourceRepository")
  }
}

/** The `internalPut` and `put` methods of Velocity Templating Engine. */
class MethodVelocityContextPut extends Method {
  MethodVelocityContextPut() {
    getDeclaringType().getASupertype*() instanceof TypeVelocityAbstractContext and
    (hasName("put") or hasName("internalPut"))
  }
}

/** The `internalPut` method of Velocity Templating Engine. */
class MethodVelocityContextInternalPut extends Method {
  MethodVelocityContextInternalPut() {
    getDeclaringType().getASupertype*() instanceof TypeVelocityContext and
    hasName("internalPut")
  }
}

/** The `evaluate` method of Velocity Templating Engine. */
class MethodVelocityEvaluate extends Method {
  MethodVelocityEvaluate() {
    // static boolean evaluate(Context context, Writer out, String logTag, String instring)
    // static boolean evaluate(Context context, Writer writer, String logTag, Reader reader)
    (
      getDeclaringType() instanceof TypeVelocityAppVelocity or
      getDeclaringType() instanceof TypeVelocityAppVelocityEngine or
      getDeclaringType().getASupertype*() instanceof TypeVelocityRuntimeRuntimeServices
    ) and
    hasName("evaluate")
  }
}

/** The `mergeTemplate` method of Velocity Templating Engine. */
class MethodVelocityMergeTemplate extends Method {
  MethodVelocityMergeTemplate() {
    // static boolean	mergeTemplate(String templateName, String encoding, Context context, Writer writer)
    getDeclaringType() instanceof TypeVelocityAppVelocity and
    hasName("mergeTemplate")
  }
}

/** The `parse` method of Velocity Templating Engine. */
class MethodVelocityParse extends Method {
  MethodVelocityParse() {
    (
      getDeclaringType().getASupertype*() instanceof TypeVelocityRuntimeRuntimeSingleton or
      getDeclaringType().getASupertype*() instanceof TypeVelocityRuntimeRuntimeServices
    ) and
    hasName("parse")
  }
}

/** The `putStringResource` method of Velocity Templating Engine. */
class MethodVelocityPutStringResource extends Method {
  MethodVelocityPutStringResource() {
    getDeclaringType().getASupertype*() instanceof TypeVelocityStringResourceRepo and
    hasName("putStringResource")
  }
}

/** The `addVelocimacro` method of Velocity Templating Engine. */
class MethodVelocityAddVelocimacro extends Method {
  MethodVelocityAddVelocimacro() {
    (
      getDeclaringType().getASupertype*() instanceof TypeVelocityRuntimeRuntimeSingleton or
      getDeclaringType().getASupertype*() instanceof TypeVelocityRuntimeRuntimeServices
    ) and
    hasName("addVelocimacro")
  }
}
