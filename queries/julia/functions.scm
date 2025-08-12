[
 ;; Matches `function my_func(...) ... end`
 (function_definition
   (signature
     (call_expression
       (identifier) @function.definition)
     ))
 ;; handles where expressions
 (function_definition
   (signature
     (where_expression
       (call_expression
         (identifier) @function.definition)
       )))
 ;; handles `MyModule.my_func(...)
 (function_definition
   (signature
     (where_expression
       (call_expression
         (field_expression
           (identifier)
           (identifier) @function.definition)
         ))))
 ;; handles `MyModule.my_func(...) where{}
 (function_definition
   (signature
     (call_expression
       (field_expression
         (identifier)
         (identifier) @function.definition)
       )))

 ;; matches operator symbols
 (function_definition
   (signature
     (call_expression
       (operator) @function.definition
       )))
 ;; Matches `my_func(x) = ...`, but not x = other_func(z), by demanding an operator
 (assignment
   (call_expression
     (identifier) @function.definition)
   .
   (operator)
   )
 ;; Matches `my_func = x-> ...
 (assignment
   (identifier) @function.definition
   (operator)
   (arrow_function_expression)
   )
 ;; matches `"operator symbol"(x,y)...
 (assignment
   (call_expression
     (operator) @function.definition)
   .
   (operator)
   )
 ;; matches ("operator symbol")(x,y) =...
 (assignment
   (call_expression
     (parenthesized_expression
       (operator) @function.definition)
     ))
 ]
