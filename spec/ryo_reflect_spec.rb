# frozen_string_literal: true

require_relative "setup"

RSpec.describe Ryo::Reflect do
  describe ".ryo?" do
    subject { Ryo.ryo?(object) }

    context "when given an instance of Ryo::BasicObject" do
      let(:object) { Ryo::BasicObject(x: 1, y: 1) }
      it { is_expected.to be(true) }
    end

    context "when given an instance of Ryo::Object" do
      let(:object) { Ryo::Object(x: 2, y: 2) }
      it { is_expected.to be(true) }
    end

    context "when given an instance of Object" do
      let(:object) { Object.new }
      it { is_expected.to be(false) }
    end

    context "when given an instance of Hash" do
      let(:object) { {} }
      it { is_expected.to be(false) }
    end
  end

  describe ".property?" do
    subject { Ryo.property?(point_b, property) }
    let(:point_a) { Ryo(x: 0) }
    let(:point_b) { Ryo({y: 0}, point_a) }

    context "when given a property belonging to a prototype" do
      let(:property) { "x" }
      it { is_expected.to be(false) }
    end

    context "when given a property belonging to self" do
      let(:property) { "y" }
      it { is_expected.to be(true) }
    end
  end

  describe ".properties_of" do
    context "when properties of a prototype are excluded" do
      subject { Ryo.properties_of(point_b) }
      let(:point_a) { Ryo(x: 0) }
      let(:point_b) { Ryo({y: 0}, point_a) }
      it { is_expected.to eq(["y"]) }
    end
  end

  describe ".set_prototype_of" do
    context "when the prototype of point_c is changed to point_b" do
      subject { point_c.y }
      let(:point_a) { Ryo(x: 0, y: 0) }
      let(:point_b) { Ryo(y: 5) }
      let(:point_c) { Ryo({}, point_a) }

      before { Ryo.set_prototype_of(point_c, point_b) }
      it { is_expected.to eq(5) }
    end
  end

  describe ".prototype_of" do
    let(:point_a) { Ryo(x: 0, y: 0) }
    let(:point_b) { Ryo({y: 5}, point_a) }

    context "when given an object with a prototype" do
      subject { Ryo.prototype_of(point_b) }
      it { is_expected.to be(point_a) }
    end

    context "when given an object without a prototype" do
      subject { Ryo.prototype_of(point_a) }
      it { is_expected.to be(nil) }
    end
  end

  describe ".prototype_chain_of" do
    context "when given the last prototype (point_c)" do
      subject { Ryo.prototype_chain_of(point_c) }
      let(:root) { Ryo({a: 1}) }
      let(:point_a) { Ryo({b: 2}, root) }
      let(:point_b) { Ryo({c: 3}, point_a) }
      let(:point_c) { Ryo({d: 4}, point_b) }

      it { is_expected.to eq([point_b, point_a, root]) }
    end

    context "when given an object without a prototype" do
      subject { Ryo.prototype_chain_of(Ryo({})) }
      it { is_expected.to eq([]) }
    end
  end

  describe ".class_of" do
    context "when given an instance of Ryo::BasicObject" do
      subject { Ryo.class_of Ryo::BasicObject({}) }
      it { is_expected.to eq(Ryo::BasicObject) }
    end

    context "when given an instance of Ryo::Object" do
      subject { Ryo.class_of Ryo::Object({}) }
      it { is_expected.to eq(Ryo::Object) }
    end
  end

  describe ".equal?" do
    let(:point_a) { Ryo::BasicObject(x: 5, y: 5) }
    let(:point_b) { Ryo::BasicObject(x: 5, y: 5) }

    context "when two objects are the same object" do
      subject { Ryo.equal?(point_a, point_a) }
      it { is_expected.to be(true) }
    end

    context "when two objects are distinct objects" do
      subject { Ryo.equal?(point_a, point_b) }
      it { is_expected.to be(false) }
    end
  end

  describe ".assign" do
    let(:point_a) { Ryo(x: 0, y: 0) }
    let(:point_b) { Ryo(y: 10) }

    context "when point_b is assigned to point_a" do
      subject { Ryo.assign(point_a, point_b) }
      it { is_expected.to eq("x" => 0, "y" => 10) }
      it { is_expected.to be_instance_of(Ryo::Object) }
    end

    context "when a Ryo object and Hash object are assigned to point_a" do
      subject { Ryo.assign(point_a, point_b, {move: fn}) }
      let(:fn) { Ryo.fn {} }
      it { is_expected.to eq("x" => 0, "y" => 10, "move" => fn) }
      it { is_expected.to be_instance_of(Ryo::Object) }
      it { is_expected.to be(point_a) }
    end
  end

  describe ".table_of" do
    subject(:table) { Ryo.table_of(ryo, recursive:) }

    context "without recursion" do
      let(:recursive) { false }
      context "when given a Ryo object" do
        let(:ryo) { Ryo(x: 1, y:1) }
        it { is_expected.to be_instance_of(Hash) }
        it { is_expected.to eq("x" => 1, "y" => 1) }
      end
    end

    context "with recursion" do
      let(:recursive) { true }
      context "when a Ryo object nests another Ryo object" do
        let(:ryo) { Ryo(point: Ryo(x: 1, y: 1)) }
        it { expect(table).to be_instance_of(Hash) }
        it { expect(table["point"]).to be_instance_of(Hash) }
        it { is_expected.to eq("point" => {"x" => 1, "y" => 1}) }
      end

      context "when a Ryo object has a nest depth of two" do
        let(:ryo) { Ryo(point: Ryo(point: Ryo(x: 1, y: 1))) }
        it { expect(table).to be_instance_of(Hash) }
        it { expect(table["point"]).to be_instance_of(Hash) }
        it { expect(table["point"]["point"]).to be_instance_of(Hash) }
        it { is_expected.to eq("point" => {"point" => {"x" => 1, "y" => 1}}) }
      end
    end
  end
end
