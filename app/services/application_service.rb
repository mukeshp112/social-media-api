class ApplicationService
  def initialize
    @data = {}
    @errors = []
  end

  def self.call(*args, &block)
    new(*args, &block).call
  end

  def call
    begin
      execute
    rescue StandardError => e
      @errors << e
    end

    log_errors if @errors.present?
    Response.new(data: @data, errors: @errors)
  end

  private

  def log_errors
    Rails.logger.info @errors
  end
end
