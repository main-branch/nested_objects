# frozen_string_literal: true

RSpec.describe NestedObjects::Mixin do
  context 'when included into a class' do
    let(:including_class) do
      Class.new do
        include NestedObjects::Mixin
      end
    end

    let(:instance) { including_class.new }

    let(:path) { double('path') }
    let(:value) { double('value') }
    let(:expected_result) { double('expected_result') }

    describe '#nested_path?' do
      it 'should call NestedObjects.path? and return the result' do
        expect(NestedObjects).to receive(:path?).with(instance, path).and_return(expected_result)
        expect(instance.nested_path?(path)).to eq(expected_result)
      end
    end

    describe '#nested_dig' do
      it 'should call NestedObjects.dig and return the result' do
        expect(NestedObjects).to receive(:dig).with(instance, path).and_return(expected_result)
        expect(instance.nested_dig(path)).to eq(expected_result)
      end
    end

    describe '#nested_bury' do
      it 'should call NestedObjects.bury and return the result' do
        expect(NestedObjects).to receive(:bury).with(instance, path, value).and_return(expected_result)
        expect(instance.nested_bury(path, value)).to eq(expected_result)
      end
    end

    describe '#nested_delete' do
      it 'should call NestedObjects.delete and return the result' do
        expect(NestedObjects).to receive(:delete).with(instance, path).and_return(expected_result)
        expect(instance.nested_delete(path)).to eq(expected_result)
      end
    end

    describe '#nested_deep_copy' do
      it 'should call NestedObjects.deep_copy and return the result' do
        expect(NestedObjects).to receive(:deep_copy).with(instance).and_return(expected_result)
        expect(instance.nested_deep_copy).to eq(expected_result)
      end
    end
  end
end
