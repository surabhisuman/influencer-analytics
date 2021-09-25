class InfluencerDataProvider
    def get(id)
        raise NotImplementedError.new("to be implemented by child class")
    end
end
