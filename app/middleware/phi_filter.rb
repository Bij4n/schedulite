class PhiFilter
  PATTERNS = [
    /\b\d{3}[-.\s]?\d{2}[-.\s]?\d{4}\b/,         # SSN
    /\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b/,          # Phone
    /\b\d{4}-\d{2}-\d{2}\b/,                       # Date (ISO)
    /\b\d{2}\/\d{2}\/\d{4}\b/,                     # Date (US)
    /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/ # Email
  ].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  end

  def self.scrub(text)
    result = text.dup
    PATTERNS.each do |pattern|
      result.gsub!(pattern, "[FILTERED]")
    end
    result
  end
end
