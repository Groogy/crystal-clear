# crystal-clear

Crystal Clear is a small little library with minimal overhead for you who is bad at maintaining the specs for your project by moving that into be more inline on the project. It implements the Design by Contract approach which let's you define what a method, even a whole class, is supposed to behave. Most of the code is gneerated at compile time but the little that has an overhead at runtime will not generate if you turn on the --release flag to Crystal.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  crystal-clear:
    github: Groogy/crystal-clear
```

## Usage

To include Crystal clear you just have to write this to get started.

```crystal
require "crystal-clear"
```

Everything else happens magically with metaprogramming in the library. All you now need to do is provide the contracts that will specify how the class and its methods are supposed to behave. The tools you need to keep in mind are `requires`, `ensures`, `invariants` and `enforce_contracts`. These macros are where the magic happens. `requires` describes something a method expects to be true before calling it, usually used with incoming arguments. It is the contract that it expects from you when using that method. `ensures` is the methods contract to you, what it ensures to be true when the method returns (no matter from what branch in the method returns from). `invariants` define something that must always be true and is done on a class level, it is a contract promising when entering or leaving its methods that something will be true. `enforce_contract` is a helper macro for when you want to test the invariant contracts but don't have any requires or ensures for this specific method.

```crystal
require "crystal-clear"

class FooBar
  invariant(@val != nil)

  def initialize(@val = nil)
    @val = 5
  end

  requires(test_meth(val), val > 0)
  ensures(test_meth(val), return_value > 0)
  def test_meth(val)
    100 / val + 1
  end

  requires(test_meth(val), val > 0)
  ensures(test_meth(val), return_value > 0)
  def bad_method(val)
    @val = nil # Will throw an exception because this is not okay!
    100 / val + 1
  end

  enforce_contracts(fixes_internally)
  def break_internally
    @val = nil # Will throw an exception because this is not okay! 
  end

  enforce_contracts(fixes_internally)
  def fixes_internally
    break_internally 
    @val = 5 # Invariants are only run when you leave the object completly so this is fine
  end
end
```

## Contributing

If you have ideas on how to develop this library more or what features it is missing, I would love to hear about it. You can always contact me on IRC #crystal-lang at freenode.

1. Fork it ( https://github.com/Groogy/crystal-clear/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Groogy(https://github.com/Groogy)  - creator, maintainer
