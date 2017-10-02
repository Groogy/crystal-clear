require "./crystal-clear/*"

module CrystalClear
  macro included
    module Contracts
      CONTRACTS = {} of _ => _
      INVARIANTS = [] of _
      CONTRACTED_METHODS = [] of _

      macro add_contract(stage, test)
        \{% if CONTRACTS[:next_def] == nil %}
          \{% CONTRACTS[:next_def] = [{stage, test}] %}
        \{% else %}
          \{% CONTRACTS[:next_def] << {stage, test} %}
        \{% end %}
      end

      macro add_invariant(test)
        \{% INVARIANTS << test %}
      end

      def self.on_contract_fail(contract, condition, method)
        raise CrystalClear::ContractError.new "Failed {{@type}} #{contract} contract: #{condition}"
      end
    end

    macro requires(test)
      Contracts.add_contract :requires, \{{test}}
    end
    
    macro ensures(test)
      Contracts.add_contract :ensures, \{{test}}
    end

    macro invariant(test)
      Contracts.add_invariant \{{test}}
    end
  end
end
