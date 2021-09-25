require 'rails_helper'

RSpec.describe InfluencerIdStore, type: :clients do
    it "#read" do
        expect{ InfluencerIdStore.new.read() }.to raise_error(NotImplementedError)
    end

    it "#write" do
        expect{ InfluencerIdStore.new.write(1) }.to raise_error(NotImplementedError)
    end
end
