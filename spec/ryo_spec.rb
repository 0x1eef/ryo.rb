require_relative "setup"

RSpec.describe Ryo do
  let(:fruit) { Ryo::BasicObject.create(nil) }
  let(:apple) { Ryo::BasicObject.create(fruit, {name: "Apple"}) }

  describe "#delete" do
    before { fruit.foo = 1 }

    context "when a propery is deleted" do
      before { Ryo.delete(fruit, "foo") }
      subject { fruit.foo }

      it { is_expected.to be_nil }
    end
  end

  describe "#assign" do
    it "combines fruit and apple" do
      expect(
        Ryo.assign(fruit, apple)
      ).to eq(name: "Apple")
    end

    it "combines a combination of Ryo and Hash objects" do
      expect(
        Ryo.assign(fruit, {foo: 1}, {bar: 2}, apple)
      ).to eq({foo: 1, bar: 2, name: "Apple"})
    end
  end
end
