import csharp

module RequestForgery {
  import semmle.code.csharp.controlflow.Guards
  import semmle.code.csharp.frameworks.system.Web
  import semmle.code.csharp.frameworks.Format
  import semmle.code.csharp.security.dataflow.flowsources.Remote

  /**
   * A data flow source for server side request forgery vulnerabilities.
   */
  abstract private class Source extends DataFlow::Node { }

  /**
   * A data flow sink for server side request forgery vulnerabilities.
   */
  abstract private class Sink extends DataFlow::ExprNode { }

  /**
   * A data flow sanitizer for server side request forgery vulnerabilities.
   */
  abstract private class Sanitizer extends DataFlow::ExprNode { }

  /**
   * A data flow node which does not allow taint to flow into it
   * when analysing server side request forgery vulnerabilities.
   */
  abstract private class SanitizerIn extends DataFlow::ExprNode { }

  /**
   * A data flow node which does not allow taint to flow outside it
   * when analysing server side request forgery vulnerabilities.
   */
  abstract private class SanitizerOut extends DataFlow::ExprNode { }

  /**
   * A data flow BarrierGuard which blocks the flow of taint for
   * server side request forgery vulnerabilities.
   */
  abstract private class SanitizerGuard extends DataFlow::BarrierGuard { }

  /**
   * A taint-tracking configuration for detecting server side request forgery vulnerabilities.
   */
  class RequestForgeryConfiguration extends TaintTracking::Configuration {
    RequestForgeryConfiguration() { this = "Server Side Request forgery" }

    override predicate isSource(DataFlow::Node source) { source instanceof Source }

    override predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

    override predicate isAdditionalTaintStep(DataFlow::Node node1, DataFlow::Node node2) {
      exists(ObjectCreation oc |
        oc.getTarget().getDeclaringType().hasQualifiedName("System.Uri") and
        oc.getArgument(0) = node1.asExpr() and
        oc = node2.asExpr()
      )
    }

    override predicate isSanitizer(DataFlow::Node node) { node instanceof Sanitizer }

    override predicate isSanitizerIn(DataFlow::Node node) { node instanceof SanitizerIn }

    override predicate isSanitizerOut(DataFlow::Node node) { node instanceof SanitizerOut }

    override predicate isSanitizerGuard(DataFlow::BarrierGuard guard) {
      guard instanceof SanitizerGuard
    }
  }

  /**
   * A remote data flow source taken as a source
   * for Server Side Request Forgery(SSRF) Vulnerabilities.
   */
  private class RemoteFlowSourceAsSource extends Source {
    RemoteFlowSourceAsSource() { this instanceof RemoteFlowSource }
  }

  /**
   * An url argument to a `HttpRequestMessage` constructor call
   * taken as a sink for Server Side Request Forgery(SSRF) Vulnerabilities.
   */
  private class SystemWebHttpRequestMessageSink extends Sink {
    SystemWebHttpRequestMessageSink() {
      exists(Class c | c.hasQualifiedName("System.Net.Http.HttpRequestMessage") |
        c.getAConstructor().getACall().getArgument(1) = this.asExpr()
      )
    }
  }

  /**
   * An argument to a `WebRequest.Create` call taken as a
   * sink for Server Side Request Forgery(SSRF) Vulnerabilities. *
   */
  private class SystemNetWebRequestCreateSink extends Sink {
    SystemNetWebRequestCreateSink() {
      exists(Method m |
        m.getDeclaringType().hasQualifiedName("System.Net.WebRequest") and m.hasName("Create")
      |
        m.getACall().getArgument(0) = this.asExpr()
      )
    }
  }

  /**
   * An argument to a new HTTP Request call of a `System.Net.Http.HttpClient` object
   * taken as a sink for Server Side Request Forgery(SSRF) Vulnerabilities.
   */
  private class SystemNetHttpClientSink extends Sink {
    SystemNetHttpClientSink() {
      exists(Method m |
        m.getDeclaringType().hasQualifiedName("System.Net.Http.HttpClient") and
        m.hasName([
            "DeleteAsync", "GetAsync", "GetByteArrayAsync", "GetStreamAsync", "GetStringAsync",
            "PatchAsync", "PostAsync", "PutAsync"
          ])
      |
        m.getACall().getArgument(0) = this.asExpr()
      )
    }
  }

  /**
   * An url argument to a method call of a `System.Net.WebClient` object
   * taken as a sink for Server Side Request Forgery(SSRF) Vulnerabilities.
   */
  private class SystemNetClientBaseAddressSink extends Sink {
    SystemNetClientBaseAddressSink() {
      exists(Property p |
        p.hasName("BaseAddress") and
        p.getDeclaringType()
            .hasQualifiedName(["System.Net.WebClient", "System.Net.Http.HttpClient"])
      |
        p.getAnAssignedValue() = this.asExpr()
      )
    }
  }

  /**
   * A method call which checks the base of the tainted uri is assumed
   * to be a guard for Server Side Request Forgery(SSRF) Vulnerabilities.
   * This guard considers all checks as valid.
   */
  private class BaseUriGuard extends SanitizerGuard, MethodCall {
    BaseUriGuard() {
      this.getTarget().getDeclaringType().hasQualifiedName("System.Uri") and
      this.getTarget().hasName("IsBaseOf")
    }

    override predicate checks(Expr e, AbstractValue v) {
      e = this.getArgument(0) and
      v.(AbstractValues::BooleanValue).getValue() = true
    }
  }

  private class StringFormatSanitizer extends Sanitizer {
    StringFormatSanitizer() {
      exists(FormatCall c, int i | c.getArgument(i) = this.asExpr() | i > 0)
    }
  }

  private class PathCombineSanitizer extends Sanitizer {
    PathCombineSanitizer() {
      exists(MethodCall combineCall, int i |
        combineCall.getTarget().hasQualifiedName("System.IO.Path", "Combine") and
        combineCall.getArgument(i) = this.asExpr()
      |
        i > 0
      )
    }
  }

  private class InterpolatedStringSanitizer extends Sanitizer {
    InterpolatedStringSanitizer() {
      exists(InterpolatedStringExpr i |
        // Dont' allow `$"https://a.com/{repository}/blabla/");"`
        i.getAnInsert() = this.asExpr()
      |
        // allow `$"http://{`taint`}/blabla/");"` or
        // allow `$"https://{`taint`}/blabla/");"`
        not (
          i.getText(0).getValue().matches(["http://", "http://"]) and
          i.getInsert(1) = this.asExpr()
        ) and
        // allow `$"{`taint`}/blabla/");"`
        not i.getInsert(0) = this.asExpr() and
        // This is a hack.
        // The following block of code is used to prevent
        // an otherwise valid taint from being marked sanitized
        // due to it's use in an unrelated interpolated string.
        // Without this, a line of code like the one showed below
        // ```csharp
        // System.Console.WriteLine($"Getting {url}");
        // ```
        // would mark the taint sanitized when it is not.
        // Hence, this block assumes that any interpolated string with a
        // whitespace character is an invalid sanitizer.
        not i.getAText().getValue().matches(["%\n%", "% %", "%\t%"])
      )
    }
  }
}
