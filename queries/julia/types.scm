[
  (struct_definition
    (type_head
      [
       ;; Catches `struct MyType`
       (identifier) @type.definition
       ;; Catches `struct MyType{T}`
       (parametrized_type_expression
         (identifier) @type.definition)
       ;; Catches `struct MyType <: Other`
       (binary_expression
         (identifier) @type.definition)
       ]))
  (abstract_definition
  (type_head
    [
     (identifier) @abstracttype.definition
     (parametrized_type_expression
       (identifier) @abstracttype.definition)
     (binary_expression
       (identifier) @abstracttype.definition)
     (binary_expression
     (parametrized_type_expression
       (identifier) @abstracttype.definition))
     ]))

  (primitive_definition
  (type_head
    [
     (identifier) @primitivetype.definition
     (parametrized_type_expression
       (identifier) @primitivetype.definition)
     (binary_expression
       (identifier) @primitivetype.definition)
     ]))
]
