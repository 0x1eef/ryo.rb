# frozen_string_literal: true

require_relative "setup"

RSpec.describe "Prototypes" do
  context "when there is one prototype" do
    let(:root) { Ryo(name: "root") }
    let(:node) { Ryo({}, root) }

    context "when traversing to a property on the root prototype" do
      subject { node.name }
      it { is_expected.to eq("root") }
    end

    context "when a property is deleted from the root prototype" do
      subject { node.name }
      before { Ryo.delete(root, "name") }
      it { is_expected.to be_nil }
    end
  end

  context "when there are two prototypes" do
    let(:root) { Ryo(name: "root") }
    let(:node_1) { Ryo({}, root) }
    let(:node_2) { Ryo({}, node_1) }

    context "when traversing to a property on the root prototype" do
      subject { node_2.name }
      it { is_expected.to eq("root") }
    end

    context "when traversing to a property on the middle prototype" do
      subject { node_2.name }
      let(:node_1) { Ryo({name: "Node 1"}, root) }
      it { is_expected.to eq("Node 1") }
    end

    context "when a property is deleted from the middle prototype" do
      subject { node_2.name }
      let(:node_1) { Ryo({name: "Node 1"}, root) }
      before { Ryo.delete(node_1, "name") }
      it { is_expected.to be_nil }
    end
  end
end
