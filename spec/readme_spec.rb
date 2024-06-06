# frozen_string_literal: true

require_relative "setup"
require "test-cmd"

RSpec.describe "README.md examples" do
  run_example = ->(file) do
    cmd("ruby", "share/ryo.rb/examples/#{file}")
  end

  subject do
    run_example.(file).stdout.chomp
  end

  context "when given 1.0_prototypes_point_object.rb" do
    let(:file) { "1.0_prototypes_point_object.rb" }
    it { is_expected.to eq("[5, 10]") }
  end

  context "when given 1.1_prototypes_ryo_fn.rb" do
    let(:file) { "1.1_prototypes_ryo_fn.rb" }
    it { is_expected.to eq("[10, 20]") }
  end

  context "when given 2.0_iteration_each.rb" do
    let(:file) { "2.0_iteration_each.rb" }
    it { is_expected.to eq(%(["x", 10]\n["y", 20])) }
  end

  context "when given 2.1_iteration_map.rb" do
    let(:file) { "2.1_iteration_map.rb" }
    it { is_expected.to eq("[4, 8]\n[4, 8]") }
  end

  context "when given 2.2_iteration_ancestors.rb" do
    let(:file) { "2.2_iteration_ancestors.rb" }
    it { is_expected.to eq("nil\nnil\n5\n5") }
  end

  context "when given 3.0_recursion_ryo_from.rb" do
    let(:file) { "3.0_recursion_ryo_from.rb" }
    it { is_expected.to eq("[0, 10]") }
  end

  context "when given 3.1_recursion_ryo_from_with_array.rb" do
    let(:file) { "3.1_recursion_ryo_from_with_array.rb" }
    it { is_expected.to eq(%(2\n"foobar"\n4)) }
  end

  context "when given 3.2_recursion_ryo_from_with_openstruct.rb" do
    let(:file) { "3.2_recursion_ryo_from_with_openstruct.rb" }
    it { is_expected.to eq("[5, 10]") }
  end

  context "when given 4.0_basicobject_ryo_basicobject.rb" do
    let(:file) { "4.0_basicobject_ryo_basicobject.rb" }
    it { is_expected.to eq("[0, 0]") }
  end

  context "when given 4.1_basicobject_ryo_basicobject_from.rb" do
    let(:file) { "4.1_basicobject_ryo_basicobject_from.rb" }
    it { is_expected.to eq("[2, 4]") }
  end

  context "when given 5_collisions_resolution_strategy.rb" do
    let(:file) { "5_collisions_resolution_strategy.rb" }
    it { is_expected.to eq("12\n34") }
  end

  context "when given 6_beyond_hash_objects.rb" do
    let(:file) { "6_beyond_hash_objects.rb" }
    it { is_expected.to eq("5\n10") }
  end

  context "when given 7_ryo_memo.rb" do
    let(:file) { "7_ryo_memo.rb" }
    it { is_expected.to eq("point.x = 5\npoint.y = 10\npoint.sum = 15") }
  end
end
