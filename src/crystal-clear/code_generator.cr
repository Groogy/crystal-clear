module CrystalClear
  macro included
    def test_invariant_contracts(method="")
      \{% for condition in Contracts::INVARIANTS %}
        if (\{{condition}}) == false
          Contracts.on_contract_fail(:invariant, \{{condition.stringify}}, {{@type}}, method)
        end
      \{% end %}
    end

    macro method_added(method)
      \{% name = method.name %}
      \{% args = method.args %}
      \{% args_call = args.map { |arg| arg.name } %}
      \{% hash = name.stringify + "(" + args.splat.stringify + ")" %}
      \{% if  !Contracts::CONTRACTED_METHODS.includes?(hash) && 
              !Contracts::IGNORED_METHODS.includes?(name.stringify) &&
              !Contracts::IGNORED_METHODS.includes?(hash) %}
        \{% if Contracts::CONTRACTS[:next_def] == nil %}
          \{% Contracts::CONTRACTED_METHODS << hash %}
          \{% if CrystalClear::Config::IS_ENABLED %}
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
          \{% end %}
        \{% else %}
          \{% Contracts::CONTRACTED_METHODS << hash %}
          \{% contracts = Contracts::CONTRACTS[:next_def] %}
          \{% safe_name = name.gsub(/\=/, "assign") %}
          Contracts.ignore_method contract_pre_\{{safe_name}}
          Contracts.ignore_method contract_post_\{{safe_name}}
          Contracts.ignore_method contract_requires_\{{safe_name}}
          Contracts.ignore_method contract_ensures_\{{safe_name}}

          def contract_pre_\{{safe_name}}(check_depth, \{{args.splat}})
            if check_depth == false || Contracts::CLASS_DATA.call_depth == 1
              test_invariant_contracts(\{{hash}})
            end
            contract_requires_\{{safe_name}}(\{{args_call.splat}})
          end

          def contract_post_\{{safe_name}}(check_depth, return_value, \{{args.splat}})
            contract_ensures_\{{safe_name}}(return_value, \{{args_call.splat}})
            if check_depth == false || Contracts::CLASS_DATA.call_depth == 1
              test_invariant_contracts(\{{hash}})
            end
          end

          def contract_requires_\{{safe_name}}(\{{args.splat}})
            \{% for c in contracts %}
              \{% stage = c[0]; condition = c[1] %}
              \{% if stage == :requires %}
                if (\{{condition}}) == false
                  Contracts.on_contract_fail(:requires, \{{condition.stringify}}, {{@type}}, \{{hash}})
                end
              \{% end %}
            \{% end %}
          end

          def contract_ensures_\{{safe_name}}(return_value, \{{args.splat}})
            \{% for c in contracts %}
              \{% stage = c[0]; condition = c[1] %}
              \{% if stage == :ensures %}
                if (\{{condition}}) == false
                  Contracts.on_contract_fail(:ensures, \{{condition.stringify}}, {{@type}}, \{{hash}})
                end
              \{% end %}
            \{% end %}
          end

          \{% if CrystalClear::Config::IS_ENABLED %}
            def \{{name}}(\{{args.splat}})
              begin
                Contracts::CLASS_DATA.call_depth += 1
                contract_pre_\{{safe_name}}(true, \{{args_call.splat}})
                return_value = previous_def
                contract_post_\{{safe_name}}(true, return_value, \{{args_call.splat}})
                return return_value
              ensure
                Contracts::CLASS_DATA.call_depth -= 1
              end
            end
          \{% end %}
          \{% Contracts::CONTRACTS[:next_def] = nil %}
          \{% Contracts::CONTRACTS[method] = contracts %}
        \{% end %}
      \{% end %}
    end
  end
end