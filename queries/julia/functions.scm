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
 ]
