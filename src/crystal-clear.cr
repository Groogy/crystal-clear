require "./crystal-clear/config.cr"
require "./crystal-clear/*"

module CrystalClear
  macro included
    macro requires(test)
      Contracts.add_contract :requires, \{{test}}
    end
    
    macro ensures(test)
      Contracts.add_contract :ensures, \{{test}}
    end

    macro invariant(test)
      Contracts.add_invariant \{{test}}
    end

    macro assert(test)
      \{% if CrystalClear::Config::IS_ENABLED %}
        Contracts.on_assert_fail(\{{test.stringify}}, \{{@type}}) if (\{{test}}) == false
      \{% end %}
    end
  end

  def self.on_assert_fail(condition)
    raise CrystalClear::AssertError.new "Failed assert: #{condition}"
  end
end

macro assert(test)
  {% if CrystalClear::Config::IS_ENABLED %}
    CrystalClear.on_assert_fail({{test.stringify}}) if ({{test}}) == false
  {% end %}
end
