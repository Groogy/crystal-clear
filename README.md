# crystal-clear

Crystal Clear is a small little library with minimal overhead for you who is bad at maintaining the specs for your project. It does this by moving that into be more inline on the project and keep the specs source local. It implements the Design by Contract approach which let's you define what the behaviour for a method, even a whole class, is supposed to be. Most of the code is gneerated at compile time but the little that has an overhead at runtime will not generate if you turn on the --release flag to Crystal.

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

Everything else happens magically with metaprogramming in the library. All you now need to do is provide the contracts that will specify how the class and its methods are supposed to behave. The tools you need to keep in mind are `requires`, `ensures`, `invariants` and `enforce_contracts`. These macros are where the magic happens. 

* `requires(method, condition)` describes something a method expects to be true before calling it, usually used with incoming arguments. It is the expection of the contract when using that method. 
* `ensures(method, condition)` is the expectation you can put on the method, what it ensures to be true when the method returns (no matter from what branch in the method returns from). The return value of the method is available in the variable `return_value`.
* `invariants(condition)` define something that must always be true and is done on a class level, it is a contract promising when entering or leaving its methods that something will be true. 
* `enforce_contract(method)` is a helper macro for when you want to test the invariant contracts but don't have any requires or ensures for this specific method.

```crystal
require "crystal-clear"

class FooBar
  invariant(@val != nil)

  def initialize(@val = nil)
    @val = 5
  end

  requires(test_method(val), val > 0)
  ensures(test_method(val), return_value > 0)
  def test_method(val)
    100 / val + 1
  end

  requires(bad_method(val), val > 0)
  ensures(test_method(val), return_value > 0)
  def bad_method(val)
    @val = nil # Will throw an exception because this is not okay!
    100 / val + 1
  end

  enforce_contracts(break_internally)
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

## Future Features

I've added some future proofing structure so that I can add more cool features but it needs a lot more work from me. THough as I add features it should not break the interface you work towards so it is still safe to use without risk of breakage.

* Spec-like breakdown of failed and fullfilled contracts. You should be able to run the contracts in a non-defensive method (i.e not throw exceptions) which then instead provides a breakdown in a logged format of what contracts are broken.
* Better configuration, should be able to set yourself from your own code if the contracts should be enabled or not at compile time, or even runtime.


## Contributing

If you have ideas on how to develop this library more or what features it is missing, I would love to hear about it. You can always contact me on IRC #crystal-lang at freenode.

1. Fork it ( https://github.com/Groogy/crystal-clear/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Groogy(https://github.com/Groogy)  - creator, maintainer
