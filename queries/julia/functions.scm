[
 ; function blah blah end
 (function_definition
   (signature
     [
      ;; Matches `function my_func end`
      (identifier) @function.definition
      ;; Matches `function my_func(...) ... end`
      (call_expression
        (identifier) @function.definition)
      (call_expression
        (operator) @function.definition)
      ;; function f(x::T) where {T}
      (where_expression
        (call_expression
          (identifier) @function.definition
          ))
      ]
     ));;end function defs
 ;; f = blah blah 
 (assignment
   [
    ;; Matches `my_func = x-> ...
    ((identifier) @function.definition
                  (operator)
                  (arrow_function_expression))
    ;; Matches `my_func(x) = ...`, but not x = other_func(z), by demanding an operator
    ((call_expression
       (identifier) @function.definition)
     . (operator))
    ;; matches `"operator symbol"(x,y)...
    ((call_expression
       (operator) @function.definition)
     . (operator))
    ;; matches ("operator symbol")(x,y) =...
    ((call_expression
       (parenthesized_expression
         (operator) @function.definition)))
    ])
 ]
