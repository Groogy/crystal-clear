macro finished
  {% for klass, definition in CrystalClear::CLASS_COMPILE_DATA %}
    class {{klass}}
      CONTRACT_DATA = CrystalClear::ClassData({{klass}}).new()
      {% if CrystalClear::Config::IS_ENABLED %}
        {% for func in definition[0] %}
          def {{func}}
            CONTRACT_DATA.call_depth += 1
            if CONTRACT_DATA.call_depth == 1
              {% for condition in definition[3] %}
                if(({{condition}}) == false)
                  raise CrystalClear::ContractException.new("Failed {{klass}} invariant contract: " + {{condition.stringify}})
                end
              {% end %}
            end
            {% for condition in definition[1] %}
              {% if condition[0] == func %}
                if(({{condition[1]}}) == false)
                  raise CrystalClear::ContractException.new("Failed {{klass}} require contract: " + {{condition[1].stringify}})
                end
              {% end%}
            {% end %}
            return_value = previous_def
            {% for condition in definition[2] %}
              {% if condition[0] == func %}
                if(({{condition[1]}}) == false)
                  raise CrystalClear::ContractException.new("Failed {{klass}} ensure contract: " + {{condition[1].stringify}})
                end
              {% end %}
            {% end %}
            if CONTRACT_DATA.call_depth == 1
              {% for condition in definition[3] %}
                if(({{condition}}) == false)
                  raise CrystalClear::ContractException.new("Failed {{klass}} invariant contract: " + {{condition.stringify}})
                end
              {% end %}
            end
            return return_value
          ensure
            CONTRACT_DATA.call_depth -= 1
          end
        {% end %}
      {% end %}
    end
  {% end %}
end