require "./spec_helper"

class FooBar
  include CrystalClear

  invariant @val != nil

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
end
