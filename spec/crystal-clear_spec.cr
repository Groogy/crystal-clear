require "./spec_helper"

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

  ensures(break_internally, return_value == "Hello world!")
  def break_internally
    @val = nil
    "Hello world!"
  end

  enforce_contracts(fixes_internally)
  def fixes_internally
    val = break_internally
    @val = 5
    val
  end
end

describe CrystalClear do

  it "should wrap methods properly" do
    obj = FooBar.new
    obj.test_meth(10).should eq(11)
  end

  it "should throw exception for failed requirement" do
    obj = FooBar.new

    expect_raises(CrystalClear::ContractException) do 
      obj.test_meth(0)
    end
  end

  it "should throw exception for failed ensurance" do
    obj = FooBar.new

    expect_raises(CrystalClear::ContractException) do 
      obj.test_meth(-10)
    end
  end

  it "should throw exception for failed invariant" do
    obj = FooBar.new
    expect_raises(CrystalClear::ContractException) do 
      obj.break_internally()
    end
  end

  it "should not throw an excpetion when internal state is fixed before call ending" do
    obj = FooBar.new
    obj.fixes_internally
  end

  it "should register constant with contract data" do
    FooBar::CONTRACT_DATA.type.should eq(FooBar)
  end

  it "should register centrally a contracted class" do
    CrystalClear::CLASS_RUNTIME_DATA.empty?.should be_false
  end

  it "should be the same object centrally and locally" do
    CrystalClear::CLASS_RUNTIME_DATA[0].should eq(FooBar::CONTRACT_DATA)
  end
end
