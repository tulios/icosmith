require "rubygems"
require 'bundler/setup'

require "zip/zip"
require "sinatra"
require "fileutils"
require "blacksmith"
require "json"
require "active_support/core_ext/hash"
require "active_support/core_ext/string"

require "./zip_file_generator"
require "debugger"

class Blacksmith
  class << self
    def support_directory
      File.join(File.expand_path(File.dirname(__FILE__)), 'support')
    end
  end
end

get "/upload" do
  erb :upload
end

post "/upload" do
  file = params["file"]
  file_name = file[:filename]
  dir_name = file_name.gsub(/\.zip$/, '')
  temp_file = file[:tempfile].path

  Dir.mktmpdir do |dir|
    upload_path = "#{dir}/#{dir_name}"
    unzip! temp_file, upload_path
    manifest = load_manifest(upload_path)
    forge_font! manifest, upload_path

    filename = zip_name(manifest)
    result_path = zip! upload_path, filename

    send_file result_path, filename: filename
  end
end

private
def unzip! file, destination
  Zip::ZipFile.open(file) do |zip_file|

    zip_file.reject {|f| f.name =~ /^[_|\.]/}.each do |f|
      dir_path = File.dirname File.join(destination, f.name)
      FileUtils.mkdir_p(dir_path) unless File.exist?(dir_path)
      zip_file.extract(f, File.join(dir_path, f.name))
    end

  end
end

def zip! path, filename
  diretory_to_zip = "#{path}/build"
  output_file = "#{path}/#{filename}"
  destination = "tmp/#{filename}"

  zip_file = ZipFileGenerator.new diretory_to_zip, output_file
  zip_file.write

  FileUtils.mv output_file, destination
  File.expand_path(destination)
end

def zip_name manifest
  "#{manifest[:name].parameterize}-v#{manifest[:version]}-#{Time.now.to_i}.zip"
end

def load_manifest path
  manifest = JSON.parse(File.read("#{path}/manifest.json")).symbolize_keys
  manifest = default_manifest.merge(manifest)
  manifest[:glyphs] = manifest[:glyphs].map {|glyph| default_glyph.merge(glyph.symbolize_keys)}

  manifest[:name] = manifest[:family] unless manifest[:name]
  manifest
end

def forge_font! manifest, source_path
  build_path = File.expand_path(File.join(source_path, "build"))
  FileUtils.mkdir_p(build_path) unless File.exist?(build_path)

  glyphs = manifest.delete(:glyphs)
  Blacksmith.forge do
    target build_path
    source File.expand_path(source_path)

    manifest.each_pair do |key, value|
      self.send(key, value) if value
    end

    glyphs.each do |g|
      name = "#{g.delete(:name)}.svg"
      code = g.delete(:code).to_i(16)
      glyph name, {code: code}.merge(g)
    end
  end
end

def default_manifest
  {
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
end

def default_glyph
  {
    code: nil,
    name: nil,
    left_side_bearing: 15,
    right_side_bearing: 15,
    scale: nil,
    offset: nil
  }
end
