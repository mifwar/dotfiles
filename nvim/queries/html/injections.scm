;; extends

; Alpine.js directives: highlight attribute values as JavaScript.
; <div x-data="{ open: false }" @click="open = !open" :class="{ hidden: !open }">
; Skips non-JS directives such as x-transition, x-ref and x-cloak.
(attribute
  (attribute_name) @_name
  (#match? @_name "\\v^([@:]|x-on:|x-bind|x-(data|init|effect|intersect|show|text|html|if|for|model|modelable|id|trap|anchor|lucide|dropdown-bind))")
  (quoted_attribute_value
    (attribute_value) @injection.content)
  (#set! injection.language "javascript"))
