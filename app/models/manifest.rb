class Manifest

  FILENAME = "manifest.json"
  FIRST_CHAR = 57345

  DEFAULT_MANIFEST = {
    name: nil,
    family: "FontSmith Font",
    weight: "Regular",
    ascent: 800,
    descent: 200,
    version: nil,
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

  def initialize params = {}
    super params
  end

  def self.generate path
    hash = exist?(path) ? generate_by_file(path) : generate_new
    # font name needs to be the same as family name
    # to prevent IE8 from not rendering eot format
    hash[:name] = hash[:family]
    hash[:version] = (hash[:version] || "1").ljust(3, ".0")

    last_glyph = hash[:glyphs].last
    first_char = last_glyph ? last_glyph[:code] + 1 : FIRST_CHAR
    update_glyphs! hash, path, first_char

    hash
  end

  def self.exist? path
    File.exist?("#{path}/#{FILENAME}")
  end

  def self.read path
    JSON.parse(File.read("#{path}/#{FILENAME}")).deep_symbolize_keys
  end

  def self.get_svgs_from path, exclude = []
    Dir.entries(path).
      select {|f| f =~ /\.svg$/}.
      map {|f| f.gsub(/\.svg$/, '')}.
      reject {|name| exclude.include?(name)}
  rescue Errno::ENOENT
    []
  end

  def self.filter_to_save hash
    glyphs = hash.delete :glyphs
    result = {}

    (DEFAULT_MANIFEST.keys - [:baseline, :scale, :offset, :copyright]).each do |key|
      value = hash[key]
      result[key] = value if value
    end

    result[:copyright] = hash[:copyright] unless hash[:copyright].blank?
    result[:glyphs] = glyphs.map {|g| {code: "0x#{g[:code].to_s(16)}", name: g[:name]}}
    JSON.pretty_generate result
  end

  private
  def self.generate_by_file path
    hash = DEFAULT_MANIFEST.merge read(path)
    hash[:glyphs] = hash[:glyphs].map {|hash| new_glyph_by_hex(hash.deep_symbolize_keys)}
    hash
  end

  def self.generate_new
    hash = DEFAULT_MANIFEST
    hash[:glyphs] = []
    hash
  end

  def self.update_glyphs! hash, path, first_char
    char = first_char
    already_configured = hash[:glyphs].collect {|h| h[:name]}
    get_svgs_from(path, already_configured).each do |name|
      hash[:glyphs] << new_glyph(name, char)
      char += 1
    end
  end

  def self.new_glyph name, char
    DEFAULT_GLYPH.merge(name: name, code: char)
  end

  def self.new_glyph_by_hex hash
    code = hash[:code].to_i(16)
    DEFAULT_GLYPH.merge(hash.merge(code: code))
  end
end
