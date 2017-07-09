module CrystalClear::Config
    {% if flag?(:release) %}
        IS_ENABLED = false
    {% else %}
        IS_ENABLED = true
    {% end %}
end