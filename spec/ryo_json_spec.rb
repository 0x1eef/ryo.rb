# frozen_string_literal: true

require_relative "setup"
require "json"
require "fileutils"

RSpec.describe Ryo::JSON do
  describe ".from_json" do
    context "with a path" do
      subject(:ryo) { described_class.from_json(path:, object:) }
      before { File.binwrite path, JSON.dump(x: 20, y: 40) }
      after { FileUtils.rm(path) }
      let(:path) { File.join(__dir__, "test.json") }

      context "with Ryo::Object" do
        let(:object) { Ryo::Object }
        it { is_expected.to be_instance_of(Ryo::Object) }
        it { is_expected.to eq("x" => 20, "y" => 40) }
      end

      context "with Ryo::BasicObject" do
        let(:object) { Ryo::BasicObject }
        it { expect(Ryo::BasicObject === ryo).to be(true) }
        it { is_expected.to eq("x" => 20, "y" => 40) }
      end
    end

    context "with a string" do
      subject(:ryo) { described_class.from_json(string: "{\"x\": 20, \"y\": 40}", object:) }

      context "with Ryo::Object" do
        let(:object) { Ryo::Object }
        it { is_expected.to be_instance_of(Ryo::Object) }
        it { is_expected.to eq("x" => 20, "y" => 40) }
      end

      context "with Ryo::BasicObject" do
        let(:object) { Ryo::BasicObject }
        it { expect(Ryo::BasicObject === ryo).to be(true) }
        it { is_expected.to eq("x" => 20, "y" => 40) }
      end
    end
  end
end
