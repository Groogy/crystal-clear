module CrystalClear
  macro included
    def test_invariant_contracts(method="")
      {% verbatim do %}
        {% for c in Contracts::INVARIANTS %}
          {% str = c[0]; condition = c[1] %}
          test = CrystalClear.perform_test(self) {{condition}}
          if !test
            Contracts.on_contract_fail(:invariant, {{str}}, {{@type}}, method)
          end
        {% end %}
      {% end %}
    end

    macro method_added(method)
      {% verbatim do %}
        {% name = method.name %}
        {% args = method.args %}
        {% return_type = method.return_type %}
        {% return_type = return_type ? ": " + return_type.stringify : "" %}
        {% args_call = args.map { |arg| arg.name } %}
        {% hash = name.stringify + "(" + args.splat.stringify + ")" %}
        {% if  !Contracts::CONTRACTED_METHODS.includes?(hash) && 
                !Contracts::IGNORED_METHODS.includes?(name.stringify) &&
                !Contracts::IGNORED_METHODS.includes?(hash) %}
          {% if Contracts::CONTRACTS[:next_def] == nil %}
            {% Contracts::CONTRACTED_METHODS << hash %}
            {% if CrystalClear::Config::IS_ENABLED %}
              def {{name}}({{args.splat}}) {{return_type.id}}
                begin
                  Contracts::CLASS_DATA.call_depth += 1
                  {% if name.stringify != "initialize" %}
                    if Contracts::CLASS_DATA.call_depth == 1
                      test_invariant_contracts({{name.stringify}})
                    end
                  {% end %}
                  return_value = previous_def
                  if Contracts::CLASS_DATA.call_depth == 1
                    test_invariant_contracts({{name.stringify}})
                  end
                  return return_value
                ensure
                  Contracts::CLASS_DATA.call_depth -= 1
                end
              end
            {% end %}
          {% else %}
            {% Contracts::CONTRACTED_METHODS << hash %}
            {% contracts = Contracts::CONTRACTS[:next_def] %}
            {% safe_name = name.gsub(/\=/, "assign") %}
            Contracts.ignore_method contract_pre_{{safe_name}}
            Contracts.ignore_method contract_post_{{safe_name}}
            Contracts.ignore_method contract_requires_{{safe_name}}
            Contracts.ignore_method contract_ensures_{{safe_name}}

            def contract_pre_{{safe_name}}(check_depth, {{args.splat}})
              if check_depth == false || Contracts::CLASS_DATA.call_depth == 1
                test_invariant_contracts({{hash}})
              end
              contract_requires_{{safe_name}}({{args_call.splat}})
            end

            def contract_post_{{safe_name}}(check_depth, return_value, {{args.splat}})
              contract_ensures_{{safe_name}}(return_value, {{args_call.splat}})
              if check_depth == false || Contracts::CLASS_DATA.call_depth == 1
                test_invariant_contracts({{hash}})
              end
            end

            def contract_requires_{{safe_name}}({{args.splat}})
              {% for c in contracts %}
                {% stage = c[0]; str = c[1]; condition = c[2] %}
                {% if stage == :requires %}
                  test = CrystalClear.perform_test(self) {{condition}}
                  if !test
                    Contracts.on_contract_fail(:requires, {{str}}, {{@type}}, {{hash}})
                  end
                {% end %}
              {% end %}
            end

            def contract_ensures_{{safe_name}}(return_value, {{args.splat}})
              {% for c in contracts %}
                {% stage = c[0]; str = c[1]; condition = c[2] %}
                {% if stage == :ensures %}
                  test = CrystalClear.perform_test(self) {{condition}}
                  if !test
                    Contracts.on_contract_fail(:ensures, {{str}}, {{@type}}, {{hash}})
                  end
                {% end %}
              {% end %}
            end

            {% if CrystalClear::Config::IS_ENABLED %}
              def {{name}}({{args.splat}}) {{return_type.id}}
                begin
                  Contracts::CLASS_DATA.call_depth += 1
                  contract_pre_{{safe_name}}(true, {{args_call.splat}})
                  return_value = previous_def
                  contract_post_{{safe_name}}(true, return_value, {{args_call.splat}})
                  return return_value
                ensure
                  Contracts::CLASS_DATA.call_depth -= 1
                end
              end
            {% end %}
            {% Contracts::CONTRACTS[:next_def] = nil %}
            {% Contracts::CONTRACTS[method] = contracts %}
          {% end %}
        {% end %}
      {% end %}
    end
  end

  def self.perform_test(obj)
    with obj yield
  end
end