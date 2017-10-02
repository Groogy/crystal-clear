module CrystalClear
  macro included
    def test_invariant_contracts(method="")
      \{% for condition in Contracts::INVARIANTS %}
        if (\{{condition}}) == false
          Contracts.on_contract_fail(:invariant, \{{condition.stringify}}, method)
        end
      \{% end %}
    end

    {% if CrystalClear::Config::IS_ENABLED %}
      macro method_added(method)
        \{% name = method.name %}
        \{% args = method.args %}
        \{% hash = name.stringify + "(" + args.splat.stringify + ")" %}
        \{% if  !Contracts::CONTRACTED_METHODS.includes?(hash) && 
                !Contracts::IGNORED_METHODS.includes?(name.stringify) &&
                !Contracts::IGNORED_METHODS.includes?(hash) %}
          \{% if Contracts::CONTRACTS[:next_def] == nil %}
            \{% Contracts::CONTRACTED_METHODS << hash %}
            def \{{name}}(\{{args.splat}})
              begin
                Contracts::CLASS_DATA.call_depth += 1
                \{% if name.stringify != "initialize" %}
                  if Contracts::CLASS_DATA.call_depth == 1
                    test_invariant_contracts(\{{name.stringify}})
                  end
                \{% end %}
                return_value = previous_def
                if Contracts::CLASS_DATA.call_depth == 1
                  test_invariant_contracts(\{{name.stringify}})
                end
                return return_value
              ensure
                Contracts::CLASS_DATA.call_depth -= 1
              end
            end
          \{% else %}
            \{% Contracts::CONTRACTED_METHODS << hash %}
            \{% contracts = Contracts::CONTRACTS[:next_def] %}
            Contracts.ignore_method contract_pre_\{{name}}
            Contracts.ignore_method contract_post_\{{name}}
            Contracts.ignore_method contract_requires_\{{name}}
            Contracts.ignore_method contract_ensures_\{{name}}

            def \{{("contract_pre_" + name.stringify).id}}(check_depth, \{{args.splat}})
              if check_depth == false || Contracts::CLASS_DATA.call_depth == 1
                test_invariant_contracts(\{{hash}})
              end
              \{{("contract_requires_" + name.stringify).id}}(\{{args.splat}})
            end

            def \{{("contract_post_" + name.stringify).id}}(check_depth, return_value, \{{args.splat}})
              \{{("contract_ensures_" + name.stringify).id}}(return_value, \{{args.splat}})
              if check_depth == false || Contracts::CLASS_DATA.call_depth == 1
                test_invariant_contracts(\{{hash}})
              end
            end

            def \{{("contract_requires_" + name.stringify).id}}(\{{args.splat}})
              \{% for c in contracts %}
                \{% stage = c[0]; condition = c[1] %}
                \{% if stage == :requires %}
                  if (\{{condition}}) == false
                    Contracts.on_contract_fail(:requires, \{{condition.stringify}}, \{{hash}})
                  end
                \{% end %}
              \{% end %}
            end

            def \{{("contract_ensures_" + name.stringify).id}}(return_value, \{{args.splat}})
              \{% for c in contracts %}
                \{% stage = c[0]; condition = c[1] %}
                \{% if stage == :ensures %}
                  if (\{{condition}}) == false
                    Contracts.on_contract_fail(:ensures, \{{condition.stringify}}, \{{hash}})
                  end
                \{% end %}
              \{% end %}
            end

            def \{{name}}(\{{args.splat}})
              begin
                Contracts::CLASS_DATA.call_depth += 1
                \{{("contract_pre_" + name.stringify).id}}(true, \{{args.splat}})
                return_value = previous_def
                \{{("contract_post_" + name.stringify).id}}(true, return_value, \{{args.splat}})
                return return_value
              ensure
                Contracts::CLASS_DATA.call_depth -= 1
              end
            end
            \{% Contracts::CONTRACTS[:next_def] = nil %}
            \{% Contracts::CONTRACTS[method] = contracts %}
          \{% end %}
        \{% end %}
      end
    {% end %}
  end
end