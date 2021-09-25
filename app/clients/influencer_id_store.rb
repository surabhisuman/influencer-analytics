class InfluencerIdStore
    
    def read()
        raise NotImplementedError.new("should be implemented by child class")
    end

    def write(id)
        raise NotImplementedError.new("should be implemented by child class")
    end
end
