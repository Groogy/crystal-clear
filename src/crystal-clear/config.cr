module CrystalClear::Config
    {% if flag?(:DISABLE_CONTRACTS) %}
        IS_ENABLED = false
    {% else %}
        IS_ENABLED = true
    {% end %}
end