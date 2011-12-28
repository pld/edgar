class Result
  attr_accessor :title, :abstract, :url, :date

  def initialize(options)
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end
end

