# Copyright (c) 2014, Evercam.io

module Evercam
  class EvercamError < StandardError
  end

  class AuthenticationError < EvercamError
    def initialize(message=nil)
      super(message || "Unauthenticated")
    end
  end

  class AuthorizationError < EvercamError
    def initialize(message=nil)
      super(message || "Unauthorized")
    end
  end

  class NotFoundError < EvercamError
    def initialize(message=nil)
      super(message || "Not Found")
    end
  end

  class CameraOfflineError < EvercamError
    def initialize(message=nil)
      super(message || "Camera Offline")
    end
  end

  class OutcomeError < EvercamError
    def initialize(outcome)
      @outcome = outcome
    end

    def message
      @outcome.errors.message_list.
        map(&:downcase)
    end
  end

  module WebErrors
    class BadRequestError < EvercamError
      def initialize(message=nil)
        super(message || "Bad Request")
      end
    end

    class ComingSoonError < EvercamError
      def initialize(message=nil)
        super(message || "Coming Soon")
      end
    end

    class ConflictError < EvercamError
      def initialize(message=nil)
        super(message || "Conflict")
      end
    end
  end
end
