# crystal-clear

Crystal Clear is a small little library with minimal overhead for you who is bad at maintaining the specs for your project. It does this by moving that into be more inline on the project and keep the specs source local. It implements the Design by Contract approach which let's you define what the behaviour for a method, even a whole class, is supposed to be. Most of the code is generated at compile time and you can opt out performance intensive code from the tests.

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

Everything else happens magically with metaprogramming in the library. All you now need to do is provide the contracts that will specify how the class and its methods are supposed to behave. The tools you need to keep in mind are `requires`, `ensures`, `invariants`. These macros are where the magic happens. 

* `requires(condition)` describes something a method expects to be true before calling it, usually used with incoming arguments. It is the expection of the contract when using that method. 
* `ensures(condition)` is the expectation you can put on the method, what it ensures to be true when the method returns (no matter from what branch in the method returns from). The return value of the method is available in the variable `return_value`.
* `invariants(condition)` define something that must always be true and is done on a class level, it is a contract promising when entering or leaving its methods that something will be true. 

```crystal
require "crystal-clear"

class FooBar
  include CrystalClear

  invariant(@val != nil)

  def initialize(@val)
  end

  requires val > 0
  ensures return_value > 0
  def test_method(val)
    100 / val + 1
  end

  requires val > 0
  ensures return_value > 0
  def bad_method(val)
    @val = nil # Will throw an exception because this is not okay!
    100 / val + 1
  end

  def break_internally
    @val = nil # Will throw an exception because this is not okay! 
  end

  def fixes_internally
    break_internally 
    @val = 5 # Invariants are only run when you leave the object completly so this is fine
  end
end
```

## Future Features

I've added some future proofing structure so that I can add more cool features but it needs a lot more work from me. THough as I add features it should not break the interface you work towards so it is still safe to use without risk of breakage.

* Better integration with the built in spec command in Crystal. Add expects\_contract_pass macros and other similar ones to let you hook in to the already built in tests for your spec.
* Better configuration, should be able to set yourself from your own code if the contracts should be enabled or not at compile time, or even runtime.
* Add more hooks that proves wanted in the generated Contracts module in the contracted classes.


## Contributing

If you have ideas on how to develop this library more or what features it is missing, I would love to hear about it. You can always contact me on IRC #crystal-lang at freenode.

1. Fork it ( https://github.com/Groogy/crystal-clear/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Groogy](https://github.com/Groogy)  - creator, maintainer
