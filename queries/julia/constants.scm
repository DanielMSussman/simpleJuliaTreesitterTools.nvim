(const_statement
  (assignment
    [
     ;;match an identifier, or a tuple / open_tuple, immediately followed by an =
     (identifier) @constant.definition
     (_
       (identifier) @constant.definition)
     ]
    .(operator)))
