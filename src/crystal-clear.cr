require "./crystal-clear/*"

macro requires(func, condition)
  {% definition = {[] of _, [] of _, [] of _, [] of _} %}
  {% definition = CrystalClear::CLASS_COMPILE_DATA[@type] || definition %}
  {% definition[1] << {func, condition} %}
  {% found_definition = false %}
  {% for val in definition[0] %}
    {% if val == func %}
      {% found_definition = true %}
    {% end %}
  {% end %}
  {% if found_definition == false %}
    {% definition[0] << func %}
  {% end %}
  {% CrystalClear::CLASS_COMPILE_DATA[@type] = definition %}
end

macro ensures(func, condition)
  {% definition = {[] of _, [] of _, [] of _, [] of _} %}
  {% definition = CrystalClear::CLASS_COMPILE_DATA[@type] || definition %}
  {% definition[2] << {func, condition} %}
  {% found_definition = false %}
  {% for val in definition[0] %}
    {% if val == func %}
      {% found_definition = true %}
    {% end %}
  {% end %}
  {% if found_definition == false %}
    {% definition[0] << func %}
  {% end %}
  {% CrystalClear::CLASS_COMPILE_DATA[@type] = definition %}
end

macro invariant(condition)
  {% definition = {[] of _, [] of _, [] of _, [] of _} %}
  {% definition = CrystalClear::CLASS_COMPILE_DATA[@type] || definition %}
  {% definition[3] << condition %}
  {% CrystalClear::CLASS_COMPILE_DATA[@type] = definition %}
end

macro enforce_contracts(func)
  {% definition = {[] of _, [] of _, [] of _, [] of _} %}
  {% definition = CrystalClear::CLASS_COMPILE_DATA[@type] || definition %}
  {% found_definition = false %}
  {% for val in definition[0] %}
    {% if val == func %}
      {% found_definition = true %}
    {% end %}
  {% end %}
  {% if found_definition == false %}
    {% definition[0] << func %}
  {% end %}
  {% CrystalClear::CLASS_COMPILE_DATA[@type] = definition %}
end