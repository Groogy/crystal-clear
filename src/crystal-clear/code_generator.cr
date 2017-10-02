module CrystalClear
  macro included
    def test_invariant_contracts(method="")
      \{% for condition in Contracts::INVARIANTS %}
        if (\{{condition}}) == false
          Contracts.on_contract_fail(:invariant, \{{condition.stringify}}, method)
        end
      \{% end %}
    end

    macro method_added(method)
      \{% name = method.name %}
      \{% args = method.args %}
      \{% if Contracts::CONTRACTED_METHODS.includes?(method) == false %}
        \{% if Contracts::CONTRACTS[:next_def] == nil %}
          \{% Contracts::CONTRACTED_METHODS << method %}
        \{% else %}
          \{% Contracts::CONTRACTED_METHODS << method %}
          \{% contracts = Contracts::CONTRACTS[:next_def] %}

          \{% if (name.starts_with?("contract_pre_") || name.starts_with?("contract_post_") ||
                  name.starts_with?("contract_requires_") || name.starts_with?("contract_ensures_")) == false %}
            def \{{("contract_pre_" + name.stringify).id}}(\{{args.splat}})
            test_invariant_contracts(\{{name.stringify}})
              \{{("contract_requires_" + name.stringify).id}}(\{{args.splat}})
            end

            def \{{("contract_post_" + name.stringify).id}}(return_value, \{{args.splat}})
              \{{("contract_ensures_" + name.stringify).id}}(return_value, \{{args.splat}})
              test_invariant_contracts(\{{name.stringify}})
            end

            def \{{("contract_requires_" + name.stringify).id}}(\{{args.splat}})
              \{% for c in contracts %}
                \{% stage = c[0]; condition = c[1] %}
                \{% if stage == :requires %}
                  if (\{{condition}}) == false
                    Contracts.on_contract_fail(:requires, \{{condition.stringify}}, \{{name.stringify}})
                  end
                \{% end %}
              \{% end %}
            end

            def \{{("contract_ensures_" + name.stringify).id}}(return_value, \{{args.splat}})
              \{% for c in contracts %}
                \{% stage = c[0]; condition = c[1] %}
                \{% if stage == :ensures %}
                  if (\{{condition}}) == false
                    Contracts.on_contract_fail(:ensures, \{{condition.stringify}}, \{{name.stringify}})
                  end
                \{% end %}
              \{% end %}
            end

            def \{{method.name}}(\{{args.splat}})
              \{{("contract_pre_" + name.stringify).id}}(\{{args.splat}})
              return_value = previous_def
              \{{("contract_post_" + name.stringify).id}}(return_value, \{{args.splat}})
              return return_value
            end
            \{% Contracts::CONTRACTS[:next_def] = nil %}
            \{% Contracts::CONTRACTS[method] = contracts %}
          \{% end %}
        \{% end %}
      \{% end %}
    end
  end
end