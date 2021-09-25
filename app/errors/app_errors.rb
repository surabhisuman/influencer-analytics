module AppErrors
    class Retryable < StandardError; end;

    class MissingAttributes < Retryable; end;

    class NetworkError < Retryable; end;
end