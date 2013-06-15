class Blacksmith
  class << self
    def support_directory
      File.join(File.expand_path(Rails.root), 'app/templates')
    end
  end
end
