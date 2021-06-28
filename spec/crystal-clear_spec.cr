require "./spec_helper"

class FooBar
  include CrystalClear

  invariant @val != nil

  @parent : FooBar?
  def initialize(@val)
  end

  requires val > 0
  ensures return_value > 0
  def test_meth(val : Int32)
    100 / val + 1
  end

  ensures return_value == "Hello world!"
  def break_internally
    @val = nil
    "Hello world!"
  end

  def fixes_internally
    val = break_internally
    @val = 5
    val
  end

  requires(arg > 0)
  def meth_with_default(arg = 5)
    if val = @val
      arg / val
    else
      0
    end
  end

  requires self.parent.nil? || foo.nil?
  requires foo != self
  def parent=(foo)
    @parent = foo
  end

  def parent
    @parent
  end
end

class Person
  include CrystalClear
  property age : Int32
  def initialize(@age)
  end
  def get_older
    @age += 1
  end
end

class Child < Person
  invariant @age < 18
end

describe CrystalClear do

  it "should wrap methods properly" do
    obj = FooBar.new 5
    obj.test_meth(10).should eq(11)
  end

  it "should throw exception for failed requirement" do
    obj = FooBar.new 5

    expect_raises(CrystalClear::ContractError) do 
      obj.test_meth(0)
    end
  end

  it "should throw exception for failed ensurance" do
    obj = FooBar.new 5

    expect_raises(CrystalClear::ContractError) do 
      obj.test_meth(-10)
    end
  end

  it "should throw exception for failed invariant" do
    obj = FooBar.new 5
    expect_raises(CrystalClear::ContractError) do 
      obj.break_internally()
    end
  end

  it "should not throw an excpetion when internal state is fixed before call ending" do
    obj = FooBar.new 5
    obj.fixes_internally
  end

  it "should throw an exception when #initialize puts object in invalid state" do
    expect_raises(CrystalClear::ContractError) do 
      FooBar.new nil
    end
  end

  it "should not override provided argument with default value" do
    obj = FooBar.new 5
    obj.meth_with_default(10).should eq 2
  end

  it "should not throw when assigning new parent" do
    a = FooBar.new 1
    b = FooBar.new 2
    a.parent = b
  end

  it "should not throw when we make parent nil again" do
    a = FooBar.new 1
    b = FooBar.new 2
    a.parent = b
    a.parent = nil
  end

  it "should throw when we assign parent to ourselves" do
    a = FooBar.new 1
    expect_raises(CrystalClear::ContractError) do
      a.parent = a
    end
  end

  it "should throw when we assign new parent when we already have one" do
    a = FooBar.new 1
    b = FooBar.new 2
    c = FooBar.new 3
    a.parent = b
    expect_raises(CrystalClear::ContractError) do
      a.parent = c
    end
  end

  it "should allow types inheriting from crystal-clear types to use contracts" do
    child = Child.new 17
    expect_raises(CrystalClear::ContractError) do
      child.get_older
    end
  end
end
