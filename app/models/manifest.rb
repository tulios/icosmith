class Manifest
  FIRST_CHAR = 57345

  DEFAULT_MANIFEST = {
    name: nil,
    family: "FontSmith Font",
    weight: "Regular",
    ascent: 800,
    descent: 200,
    version: "1.0",
    copyright: "",
    baseline: nil,
    scale: nil,
    offset: nil
  }

  DEFAULT_GLYPH = {
    code: nil,
    name: nil,
    left_side_bearing: 15,
    right_side_bearing: 15,
    scale: nil,
    offset: nil
  }

  def self.generate upload_path
    char = FIRST_CHAR
    svgs = Dir.entries(upload_path).select {|f| f =~ /\.svg$/}.map {|f| f.gsub(/\.svg$/, '')}

    if File.exist?("#{upload_path}/manifest.json")
      manifest = JSON.parse(File.read("#{upload_path}/manifest.json")).symbolize_keys
      manifest = DEFAULT_MANIFEST.merge(manifest)
      manifest[:glyphs] = manifest[:glyphs].map {|glyph| DEFAULT_GLYPH.merge(glyph.symbolize_keys)}
      char = manifest[:glyphs].last[:code].to_i(16) + 1

      already_configured = manifest[:glyphs].collect {|h| h[:name]}
      svgs.reject! {|name| already_configured.include?(name)}
    else
      manifest = DEFAULT_MANIFEST
      manifest[:glyphs] = []
    end

    svgs.each do |name|
      manifest[:glyphs] << new_glyph(name, char)
      char += 1
    end

    manifest[:name] = manifest[:family] unless manifest[:name]
    manifest
  end

  def self.new_glyph name, char
    DEFAULT_GLYPH.merge({name: name, code: "0x#{char.to_s(16)}"})
  end

end
