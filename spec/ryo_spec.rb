require_relative "setup"

RSpec.describe Ryo do
  let(:obj) { Ryo::BasicObject.create(nil) }

  describe "#delete" do
    before { obj.foo = 1 }

    context "when a propery is deleted" do
      before { described_class.delete(obj, "foo") }
      subject { obj.foo }

      it { is_expected.to be_nil }
    end
  end
end
