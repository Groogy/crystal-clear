module CrystalClear
  abstract class ClassDataBase
    property :call_depth
    getter :type

    def initialize()
      @call_depth = 0

      CLASS_RUNTIME_DATA << self
      CLASS_RUNTIME_DATA.uniq!
    end

    abstract def type()
  end
  
  class ClassData(Type) < ClassDataBase
    def type()
      Type
    end
  end
  
  # Class => {Array of functions, Array of Function, Require pairs, Array of Function, Ensure pairs, Array of Invariants}
  CLASS_COMPILE_DATA = {} of _ => Tuple(Array(_), Array(Tuple(_, _)), Array(Tuple(_, _)), Array(_))
  CLASS_RUNTIME_DATA = [] of ClassDataBase
end