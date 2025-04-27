# frozen_string_literal: true

RSpec.describe NestedObjects do
  describe '#deep_copy' do
    context 'when the data is an immediate value' do
      let(:data) { 42 }
      it 'should return the same value' do
        expect(described_class.deep_copy(data)).to eq(data)
      end
    end

    context 'when the value is an object that is not an immediate value' do
      let(:data) { 'test' }
      it 'should return a different but equivalent object' do
        expect(described_class.deep_copy(data)).to eq('test')
        expect(described_class.deep_copy(data).object_id).not_to eq(data.object_id)
      end
    end

    context 'when the data is a hash' do
      let(:data) { { 'a' => 1, 'b' => 2 } }
      it 'should return a different but equivalent hash' do
        expect(described_class.deep_copy(data)).to eq(data)
        expect(described_class.deep_copy(data).object_id).not_to eq(data.object_id)
      end
    end

    context 'when the data can not be marshaled' do
      let(:data) { StringIO.new('test') } # IO objects cannot be marshaled
      it 'should raise a TypeError' do
        expect { described_class.deep_copy(data) }.to raise_error(TypeError)
      end
    end

    context 'when the data is a nested hash' do
      let(:data) { { 'a' => { 'b' => 'test' } } }
      it 'should return a different but equivalent hash' do
        expect(described_class.deep_copy(data)).to eq(data)
        expect(described_class.deep_copy(data).object_id).not_to eq(data.object_id)
        expect(described_class.deep_copy(data)['a'].object_id).not_to eq(data['a'].object_id)
        expect(described_class.deep_copy(data)['a']['b'].object_id).not_to eq(data['a']['b'].object_id)
      end
    end

    context 'when the data contains hashes and arrays' do
      let(:data) { { 'a' => ['one', { 'b' => 'two' }] } }
      it 'should return a different but equivalent hash' do
        expect(described_class.deep_copy(data)).to eq(data)
        expect(described_class.deep_copy(data).object_id).not_to eq(data.object_id)
        expect(described_class.deep_copy(data)['a'].object_id).not_to eq(data['a'].object_id)
        expect(described_class.deep_copy(data)['a'][1].object_id).not_to eq(data['a'][1].object_id)
        expect(described_class.deep_copy(data)['a'][1]['b'].object_id).not_to eq(data['a'][1]['b'].object_id)
      end
    end
  end

  describe '#path?' do
    context 'when the path is found' do
      context 'when the path is empty' do
        let(:data) { { 'a' => 1 } }
        let(:path) { [] }
        it 'should return true' do
          expect(described_class.path?(data, path)).to be true
        end
      end

      context 'when the path is a single hash key' do
        let(:data) { { 'a' => 1 } }
        let(:path) { %w[a] }
        it 'should return true' do
          expect(described_class.path?(data, path)).to be true
        end
      end

      context 'when the path is a single array index' do
        let(:data) { [1, 2, 3] }
        let(:path) { %w[0] }
        it 'should return true' do
          expect(described_class.path?(data, path)).to be true
        end
      end

      context 'when path is a nested hash key' do
        let(:data) { { 'a' => { 'b' => 1 } } }
        let(:path) { %w[a b] }
        it 'should return true' do
          expect(described_class.path?(data, path)).to be true
        end
      end

      context 'when path is a nested array index' do
        let(:data) { [[10, 11, 12], [20, 21, 22]] }
        let(:path) { %w[0 1] }
        it 'should return true' do
          expect(described_class.path?(data, path)).to be true
        end
      end

      context 'when path is a mix of hash keys and array indices' do
        let(:data) { { 'a' => [{ 'b' => 0 }, { 'c' => 1 }] } }
        let(:path) { %w[a 0 b] }
        it 'should return true' do
          expect(described_class.path?(data, path)).to be
        end
      end
    end

    context 'when the path is not found' do
      context 'when the path is a non-existent hash key' do
        let(:data) { { 'a' => 1 } }
        let(:path) { %w[b] }
        it 'should return false' do
          expect(described_class.path?(data, path)).to be false
        end
      end

      context 'when the path is a non-existent nested hash key' do
        let(:data) { { 'a' => 1 } }
        let(:path) { %w[a b] }
        it 'should return false' do
          expect(described_class.path?(data, path)).to be false
        end
      end

      context 'when the path is a non-existent array index' do
        let(:data) { [1, 2, 3] }
        let(:path) { %w[4] }
        it 'should return false' do
          expect(described_class.path?(data, path)).to be false
        end
      end

      context 'when the path is a non-existent nested hash key' do
        let(:data) { { 'a' => { 'b' => 1 } } }
        let(:path) { %w[a c] }
        it 'should return false' do
          expect(described_class.path?(data, path)).to be false
        end
      end

      context 'when the path is a non-existent nested array index' do
        let(:data) { [[10, 11, 12], [20, 21, 22]] }
        let(:path) { %w[0 4] }
        it 'should return false' do
          expect(described_class.path?(data, path)).to be false
        end
      end

      context 'when trying to traverse through an array with a non-integer key' do
        let(:data) { [10, 11, 12] }
        let(:path) { %w[a] }
        it 'should raise a BadPathError' do
          expect { described_class.path?(data, path) }.to raise_error(NestedObjects::BadPathError)
        end
      end
    end
  end

  describe '#delete' do
    context 'when the data is a value' do
      let(:data) { 42 }
      let(:path) { %w[a] }
      it 'should raise a BadPathError' do
        expect { described_class.delete(data, path) }.to raise_error(NestedObjects::BadPathError)
      end
    end

    context 'when the path is empty' do
      let(:data) { { 'a' => 1 } }
      let(:path) { %w[] }
      it 'should raise a BadPathError' do
        expect { described_class.delete(data, path) }.to raise_error(NestedObjects::BadPathError)
      end
    end

    context 'when the path is a non-existant hash key' do
      let(:data) { { 'a' => 1 } }
      let(:path) { %w[b] }
      it 'should raise a BadPathError' do
        expect { described_class.delete(data, path) }.to raise_error(NestedObjects::BadPathError)
      end
    end

    context 'when the path is a hash key' do
      let(:data) { { 'a' => 1 } }
      let(:path) { %w[a] }
      it 'should remove the key from the hash' do
        expected_result = 1
        expected_data = {}
        expect(described_class.delete(data, path)).to eq(expected_result)
        expect(data).to eq(expected_data)
      end
    end

    context 'when the path is a nested hash key' do
      let(:data) { { 'a' => { 'b' => 1 } } }
      let(:path) { %w[a b] }
      it 'should remove the key from the hash' do
        expected_result = 1
        expected_data = { 'a' => {} }
        expect(described_class.delete(data, path)).to eq(expected_result)
        expect(data).to eq(expected_data)
      end
    end

    context 'when the path is a non-existant array index' do
      let(:data) { [1, 2, 3] }
      let(:path) { %w[4] }
      it 'should raise a BadPathError' do
        expect { described_class.delete(data, path) }.to raise_error(NestedObjects::BadPathError)
      end
    end

    context 'when the path is an array index' do
      let(:data) { [10, 11, 12] }
      let(:path) { %w[1] }
      it 'should remove the index from the array' do
        expected_result = 11
        expected_data = [10, 12]
        expect(described_class.delete(data, path)).to eq(expected_result)
        expect(data).to eq(expected_data)
      end
    end

    context 'when the path is a nested array index' do
      let(:data) { [[10, 11, 12], [20, 21, 22]] }
      let(:path) { %w[0 1] }
      it 'should remove the index from the array' do
        expected_result = 11
        expected_data = [[10, 12], [20, 21, 22]]
        expect(described_class.delete(data, path)).to eq(expected_result)
        expect(data).to eq(expected_data)
      end
    end

    context 'trying to traverse through an array with a non-integer key' do
      let(:data) { [10, 11, 12] }
      let(:path) { %w[a] }
      it 'should raise a BadPathError' do
        expect { described_class.delete(data, path) }.to raise_error(NestedObjects::BadPathError)
      end
    end
  end

  describe '#dig' do
    context 'when given an empty path' do
      let(:data) { { 'a' => 1 } }
      let(:path) { [] }
      it 'should return the data and true' do
        expect(described_class.dig(data, path)).to eq(data)
      end
    end

    context 'when given a hash key' do
      let(:data) { { 'a' => 1 } }
      let(:path) { ['a'] }
      it 'should return the value and true' do
        expect(described_class.dig(data, path)).to eq(1)
      end
    end

    context 'when given a nested hash key' do
      let(:data) { { 'a' => { 'b' => 1 } } }
      let(:path) { %w[a b] }
      it 'should return the value and true' do
        expect(described_class.dig(data, path)).to eq(1)
      end
    end

    context 'when given an array index' do
      let(:data) { [1, 2, 3] }
      let(:path) { ['0'] }
      it 'should return the value and true' do
        expect(described_class.dig(data, path)).to eq(1)
      end
    end

    context 'when given a nested array index' do
      let(:data) { [[10, 11, 12], [20, 21, 22]] }
      let(:path) { %w[0 1] }
      it 'should return the value and true' do
        expect(described_class.dig(data, path)).to eq(11)
      end
    end

    context 'when given a non-existent array index' do
      let(:data) { [10, 11, 12] }
      let(:path) { %w[4] }
      it 'should raise a BadPathError' do
        expect { described_class.dig(data, path) }.to raise_error(NestedObjects::BadPathError)
      end
    end

    context 'when given a non-existent hash key' do
      let(:data) { { 'a' => 1 } }
      let(:path) { ['b'] }
      it 'should raise a BadPathError' do
        expect { described_class.dig(data, path) }.to raise_error(NestedObjects::BadPathError)
      end
    end

    context 'trying to traverse through an array with a non-integer key' do
      let(:data) { [10, 11, 12] }
      let(:path) { %w[a] }
      it 'should raise a BadPathError' do
        expect { described_class.dig(data, path) }.to raise_error(NestedObjects::BadPathError)
      end
    end
  end

  describe '#bury' do
    let(:value) { 42 }

    context 'when given an empty path' do
      let(:data) { { 'a' => 1 } }
      let(:path) { [] }
      it 'should raise an BadPathError and not change the data' do
        expect { described_class.bury(data, path, value) }.to raise_error(NestedObjects::BadPathError)
        expect(data).to eq({ 'a' => 1 })
      end
    end

    context 'when given an existing hash key' do
      let(:path) { ['a'] }
      it 'should set the hash value' do
        data = { 'a' => 1 }
        expected_result = { 'a' => value }
        expected_data = expected_result
        expect(described_class.bury(data, path, value)).to eq(expected_result)
        expect(data).to eq(expected_data)
      end
    end

    context 'when given a non-existant path that includes an integer' do
      let(:path) { %w[a 0] }
      it 'should create intermediate hashes' do
        data = {}
        expected_result = { 'a' => { '0' => value } }
        expect(described_class.bury(data, path, value)).to eq(expected_result)
        expect(data).to eq(expected_result)
      end
    end

    context 'when given a path ending at a value' do
      let(:path) { %w[a b] }
      it 'should raise BadPathError' do
        data = { 'a' => 1 }
        expect { described_class.bury(data, path, value) }.to raise_error(NestedObjects::BadPathError)
      end
    end

    context 'when given an existing nested hash key' do
      let(:data) { { 'a' => { 'b' => 1 } } }
      let(:path) { %w[a b] }
      it 'should set the hash value' do
        expected_result = { 'a' => { 'b' => 42 } }
        expect(described_class.bury(data, path, value)).to eq(expected_result)
        expect(data).to eq(expected_result)
      end
    end

    context 'when given an existing array index' do
      let(:data) { [1, 2, 3] }
      let(:path) { ['0'] }
      it 'should set the array value' do
        expected_result = [value, 2, 3]
        expect(described_class.bury(data, path, value)).to eq(expected_result)
        expect(data).to eq(expected_result)
      end
    end

    context 'when traversing over an array to set a value' do
      let(:data) { { 'a' => [{ 'b' => 0 }, { 'b' => 1 }] } }
      let(:path) { %w[a 1 b] }
      it 'should set the value' do
        expected_result = { 'a' => [{ 'b' => 0 }, { 'b' => value }] }
        expect(described_class.bury(data, path, value)).to eq(expected_result)
        expect(data).to eq(expected_result)
      end
    end

    context 'when traversing over a value' do
      let(:data) { { 'a' => 0 } }
      let(:path) { %w[a b] }
      it 'should raise an BadPathError and not change the data' do
        expected_result = { 'a' => 0 }
        expect { described_class.bury(data, path, value) }.to raise_error(NestedObjects::BadPathError)
        expect(data).to eq(expected_result)
      end
    end

    context 'when given an array index that is the length of the array' do
      let(:data) { [1, 2, 3] }
      let(:path) { %w[3] }
      it 'should extend the array by one element' do
        expected_result = [1, 2, 3, value]
        expect(described_class.bury(data, path, value)).to eq(expected_result)
        expect(data).to eq(expected_result)
      end
    end

    context 'when given an array index that is greater than the length of the array' do
      let(:data) { [1, 2, 3] }
      let(:path) { %w[4] }
      it 'should extend the array by as many elements as needed' do
        expected_result = [1, 2, 3, nil, value]
        expect(described_class.bury(data, path, value)).to eq(expected_result)
        expect(data).to eq(expected_result)
      end
    end

    context 'when given a single-level path that does not exist' do
      let(:data) { {} }
      let(:path) { %w[a] }
      it 'should add the key the hash' do
        expected_result = { 'a' => value }
        expect(described_class.bury(data, path, value)).to eq(expected_result)
        expect(data).to eq(expected_result)
      end
    end

    context 'when given a multi-level path that does not exist' do
      let(:data) { {} }
      let(:path) { %w[a b c] }
      it 'should create a hash for each level' do
        expected_result = { 'a' => { 'b' => { 'c' => 42 } } }
        expect(described_class.bury(data, path, value)).to eq(expected_result)
        expect(data).to eq(expected_result)
      end
    end

    context 'when given a multi-level path that does not exist that traverses through an array' do
      let(:data) { [] }
      let(:path) { %w[0 a] }
      it 'should create a hash for each level' do
        expected_result = [{ 'a' => 42 }]
        expect(described_class.bury(data, path, value)).to eq(expected_result)
        expect(data).to eq(expected_result)
      end
    end

    context 'trying to traverse through an array with a non-integer key' do
      let(:data) { [10, 11, 12] }
      let(:path) { %w[a] }
      it 'should raise a BadPathError' do
        expect { described_class.bury(data, path, value) }.to raise_error(NestedObjects::BadPathError)
      end
    end
  end
end
