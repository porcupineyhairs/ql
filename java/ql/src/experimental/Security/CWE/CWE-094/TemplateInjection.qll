/** Definitions related to the Server Side Template Injection (SSTI) query. */

import java
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.dataflow.FlowSources
import experimental.semmle.code.java.frameworks.FreeMarker
import experimental.semmle.code.java.frameworks.Velocity
import experimental.semmle.code.java.frameworks.MVEL
import experimental.semmle.code.java.frameworks.JinJava
import experimental.semmle.code.java.frameworks.Pebble
import experimental.semmle.code.java.frameworks.Thymeleaf

/** A module to reason about Server Side Template Injection (SSTI) vulnerabilities */
module TemplateInjection {
  /** A taint tracking configuration to reason about Server Side Template Injection (SSTI) vulnerabilities */
  class TemplateInjectionFlowConfig extends TaintTracking::Configuration {
    TemplateInjectionFlowConfig() { this = "TemplateInjectionFlowConfig" }

    override predicate isSource(DataFlow::Node source) { source instanceof Source }

    override predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

    override predicate isSanitizer(DataFlow::Node node) {
      node.getType() instanceof PrimitiveType or node.getType() instanceof BoxedType
    }

    override predicate isAdditionalTaintStep(DataFlow::Node prev, DataFlow::Node succ) {
      exists(AdditionalFlowStep a | a.isAdditionalTaintStep(prev, succ))
    }
  }

  /**
   * A data flow source for `Configuration`.
   */
  private class Source extends DataFlow::Node {
    Source() { this instanceof RemoteFlowSource }
  }

  /**
   * A data flow sink for `Configuration`.
   */
  abstract private class Sink extends DataFlow::ExprNode { }

  /**
   * A data flow step for `Configuration`.
   */
  private class AdditionalFlowStep extends Unit {
    abstract predicate isAdditionalTaintStep(DataFlow::Node prev, DataFlow::Node succ);
  }

  /**
   * An argument to FreeMarker template engine's `process` method call is a sink for `Configuration`.
   */
  private class FreeMarkerProcessSink extends Sink {
    FreeMarkerProcessSink() {
      exists(MethodAccess m |
        m.getCallee() instanceof MethodFreeMarkerTemplateProcess and
        m.getArgument(0) = this.getExpr()
      )
    }
  }

  /**
   * An reader passed an argument to FreeMarker template engine's `Template`
   *   construtor call is a sink for `Configuration`.
   */
  private class FreeMarkerConstructorSink extends Sink {
    FreeMarkerConstructorSink() {
      // Template(java.lang.String name, java.io.Reader reader)
      // Template(java.lang.String name, java.io.Reader reader, Configuration cfg)
      // Template(java.lang.String name, java.io.Reader reader, Configuration cfg, java.lang.String encoding)
      // Template(java.lang.String name, java.lang.String sourceCode, Configuration cfg)
      // Template(java.lang.String name, java.lang.String sourceName, java.io.Reader reader, Configuration cfg)
      // Template(java.lang.String name, java.lang.String sourceName, java.io.Reader reader, Configuration cfg, ParserConfiguration customParserConfiguration, java.lang.String encoding)
      // Template(java.lang.String name, java.lang.String sourceName, java.io.Reader reader, Configuration cfg, java.lang.String encoding)
      exists(ConstructorCall cc, Expr e |
        cc.getConstructor().getDeclaringType() instanceof TypeFreeMarkerTemplate and
        e = cc.getAnArgument() and
        e.getType().(RefType).hasQualifiedName("java.io", "Reader") and
        this.asExpr() = e
      )
    }
  }

  /**
   * An argument to FreeMarker template engine's `putTemplate` method call is a sink for `Configuration`.
   */
  private class FreeMarkerStringTemplateLoaderPutTemplateSink extends Sink {
    FreeMarkerStringTemplateLoaderPutTemplateSink() {
      exists(MethodAccess ma |
        this.asExpr() = ma.getArgument(1) and
        ma.getMethod() instanceof MethodFreeMarkerStringTemplateLoaderPutTemplate
      )
    }
  }

  /**
   * An argument to Pebble template engine's `getLiteralTemplate` method call is as a sink for `Configuration`.
   */
  private class PebbleGetTemplateSinkTemplateSink extends Sink {
    PebbleGetTemplateSinkTemplateSink() {
      exists(MethodAccess ma |
        this.asExpr() = ma.getArgument(_) and
        ma.getMethod() instanceof MethodPebbleGetTemplate
      )
    }
  }

  /**
   * An argument to JinJava template engine's `render` or `renderForResult` method call is as a sink for `Configuration`.
   */
  private class JinjavaRenderSink extends Sink {
    JinjavaRenderSink() {
      exists(MethodAccess ma |
        this.asExpr() = ma.getArgument(_) and
        (
          ma.getMethod() instanceof MethodJinjavaRenderForResult
          or
          ma.getMethod() instanceof MethodJinjavaRender
        )
      )
    }
  }

  /**
   * An argument to ThymeLeaf template engine's `process` method call is as a sink for `Configuration`.
   */
  private class ThymeLeafRenderSink extends Sink {
    ThymeLeafRenderSink() {
      exists(MethodAccess ma |
        this.asExpr() = ma.getArgument(0) and
        ma.getMethod() instanceof MethodThymeleafProcess
      )
    }
  }

  private class ThymeLeafgetResourceAsStreamSink extends Sink {
    ThymeLeafgetResourceAsStreamSink() {
      exists(MethodAccess ma |
        this.asExpr() = ma.getArgument(0) and
        ma.getMethod() instanceof MethodThymeleafGetResourceAsStream
      )
    }
  }

  /**
   * An argument to MVEL template engine's `compileTemplate` method call is as a sink for `Configuration`.
   */
  private class MVELCompileTemplateSink extends Sink {
    MVELCompileTemplateSink() {
      exists(MethodAccess ma |
        this.asExpr() = ma.getArgument(0) and
        ma.getMethod() instanceof MethodMVELCompileTemplate
      )
    }
  }

  /**
   * An argument to MVEL templating engine's `TemplateCompiler`
   *   construtor call is a sink for `Configuration`.
   */
  private class MVELConstructorSink extends Sink {
    MVELConstructorSink() {
      exists(ConstructorCall cc, Constructor c |
        cc.getConstructor() = c and
        c.getDeclaringType() instanceof MVELTemplateCompiler and
        this.asExpr() = cc.getArgument(0)
      )
    }
  }

  /**
   * Tainted data flowing into a Velocity Context through `put` method taints the context.
   */
  private class VelocityContextFlow extends AdditionalFlowStep {
    override predicate isAdditionalTaintStep(DataFlow::Node prev, DataFlow::Node succ) {
      exists(MethodAccess m | m.getMethod() instanceof MethodVelocityContextPut |
        m.getArgument(1) = prev.asExpr() and
        (succ.asExpr() = m or succ.asExpr() = m.getQualifier())
      )
    }
  }

  /**
   * An argument to Velocity template engine's `mergeTemplate` method call is a sink for `Configuration`.
   */
  private class VelocityMergeTempSink extends Sink {
    VelocityMergeTempSink() {
      exists(MethodAccess m |
        // static boolean	mergeTemplate(String templateName, String encoding, Context context, Writer writer)
        m.getCallee() instanceof MethodVelocityMergeTemplate and
        m.getArgument(2) = this.getExpr()
      )
    }
  }

  /**
   * An argument to Velocity template engine's `evaluate` method call is a sink for `Configuration`.
   */
  private class VelocityEvaluateSink extends Sink {
    VelocityEvaluateSink() {
      exists(MethodAccess m |
        m.getCallee() instanceof MethodVelocityEvaluate and
        m.getArgument([0, 3]) = this.getExpr()
      )
    }
  }

  /**
   * An argument to Velocity template engine's `parse` method call is a sink for `Configuration`.
   */
  private class VelocityParseSink extends Sink {
    VelocityParseSink() {
      exists(MethodAccess ma |
        this.asExpr() = ma.getArgument(0) and
        ma.getMethod() instanceof MethodVelocityParse
      )
    }
  }

  /**
   * An argument to Velocity template engine's `putStringResource` method call is a sink for `Configuration`.
   */
  private class VelocityPutStringResSink extends DataFlow::Node {
    VelocityPutStringResSink() {
      exists(MethodAccess ma |
        this.asExpr() = ma.getArgument(1) and
        ma.getMethod() instanceof MethodVelocityPutStringResource
      )
    }
  }

  /**
   * An argument to Velocity template engine's `addVelocimacro` method call is a sink for `Configuration`.
   */
  private class VelocityAddVelociMacroSink extends Sink {
    VelocityAddVelociMacroSink() {
      exists(MethodAccess ma |
        this.asExpr() = ma.getArgument(1) and
        ma.getMethod() instanceof MethodVelocityAddVelocimacro
      )
    }
  }
}
