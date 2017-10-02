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
  end
end
