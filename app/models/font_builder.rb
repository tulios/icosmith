class FontBuilder

  attr_reader :manifest, :source_path, :build_path

  def initialize manifest, source_path
    @manifest = manifest
    @source_path = File.expand_path(source_path)
    @build_path = File.expand_path(File.join(@source_path, "build"))    
  end

  def build!
    FileUtils.mkdir_p(@build_path) unless File.exist?(@build_path)
    builder = self

    Blacksmith.forge do
      target builder.build_path
      source builder.source_path

      builder.header_keys.each do |key|
        value = builder.manifest[key]
        self.send(key, value) if value
      end

      builder.glyphs.each do |g|
        name = "#{g[:name]}.svg"
        glyph name, g
      end
    end
  end

  def header_keys
    @manifest.keys.select {|key| Manifest::DEFAULT_MANIFEST.keys.include?(key)}
  end

  def glyphs
    @manifest[:glyphs]
  end

end
