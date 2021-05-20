/**
 * @name Server Side Template Injection
 * @description Untrusted input used as a template parameter can lead to RCE.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @id java/server-side-template-injection
 * @tags security
 *       external/cwe/cwe-094
 */

import java
import TemplateInjection::TemplateInjection
import semmle.code.java.dataflow.DataFlow

from TemplateInjectionFlowConfig config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink)
select source, sink