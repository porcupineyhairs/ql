import java
import experimental.semmle.code.xml.StrutsXML

bindingset[path]
predicate isBadPath(string path) {
  path.matches("%example%") or
  path.matches("%test%") or
  path.matches("%demo%")
}

from ConstantParameter c
where
  c.getNameValue() = "struts.devMode" and
  c.getValueValue() = "true" and
  not isBadPath(c.getFile().getRelativePath())
select c
