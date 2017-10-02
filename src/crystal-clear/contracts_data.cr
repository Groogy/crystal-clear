module CrystalClear
  abstract class ClassDataBase
    property :call_depth

    def initialize()
      @call_depth = 0
    end

    abstract def type
  end

  class ClassData(Type) < ClassDataBase
    def type
      Type
    end
  end

  macro included
    module Contracts
      CONTRACTS = {} of _ => _
      INVARIANTS = [] of _
      CONTRACTED_METHODS = [] of _
      IGNORED_METHODS = [] of _
      CLASS_DATA = ClassData({{@type}}).new

      macro add_contract(stage, test)
        \{% if CrystalClear::Config::IS_ENABLED %}
          \{% if CONTRACTS[:next_def] == nil %}
            \{% CONTRACTS[:next_def] = [{stage, test}] %}
          \{% else %}
            \{% CONTRACTS[:next_def] << {stage, test} %}
          \{% end %}
        \{% end %}
      end

      macro add_invariant(test)
        \{% if CrystalClear::Config::IS_ENABLED %}
          \{% INVARIANTS << test %}
        \{% end %}
      end

      macro ignore_method(method)
        \{% if CrystalClear::Config::IS_ENABLED %}
          \{% IGNORED_METHODS << method.stringify %}
        \{% end %}
      end

      ignore_method finalize

      def self.on_contract_fail(contract, condition, method)
        raise CrystalClear::ContractError.new "Failed {{@type}} #{contract} contract: #{condition}"
      end
    end
  end
end