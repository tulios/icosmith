require "zip_file_generator"

class FontGeneratorController < ApplicationController

  def create
    unless params[:base64zip].blank?
      @tmp_file = file = Tempfile.open(["#{Time.now.to_i}", ".zip"], encoding: "ascii-8bit")
      file.write Base64.decode64(params[:base64zip])
      file.close

      file_name = file.path.scan(/\/([^\/]+)$/).flatten.first
      dir_name = file.path.gsub(file_name, '').gsub(/\/$/, '')
      temp_file = File.open(file.path)

    else
      file = params["file"]
      file_name = file[:filename]
      dir_name = file_name.gsub(/\.zip$/, '')
      temp_file = file[:tempfile].path
    end

    Dir.mktmpdir do |dir|
      upload_path = "#{dir}/#{dir_name}"
      unzip! temp_file, upload_path
      manifest = load_manifest upload_path
      forge_font! manifest, upload_path
      prepare_package! manifest, upload_path

      filename = zip_name(manifest)
      result_path = zip! upload_path, filename

      send_file(result_path, {
        filename: filename,
        type: "application/zip",
        disposition: "attachment"
      })
    end
  ensure
    if @tmp_file
      @tmp_file.unlink
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
    return manifest[:filename] if manifest[:filename]
    "#{manifest[:name].parameterize}-v#{manifest[:version]}-#{Time.now.to_i}.zip"
  end

  def load_manifest path
    Manifest.generate path
  end

  def forge_font! manifest, source_path
    build_path = File.expand_path(File.join(source_path, "build"))
    FileUtils.mkdir_p(build_path) unless File.exist?(build_path)

    Blacksmith.forge do
      target build_path
      source File.expand_path(source_path)

      header_keys = manifest.keys.select {|key| Manifest::DEFAULT_MANIFEST.keys.include?(key)}
      header_keys.each do |key|
        value = manifest[key]
        self.send(key, value) if value
      end

      manifest[:glyphs].each do |g|
        name = "#{g[:name]}.svg"
        code = g[:code].to_i(16)
        glyph name, g.merge(code: code)
      end
    end
  end

  def prepare_package! manifest, upload_path
    build_directory = "#{upload_path}/build"
    FileUtils.cp File.join(File.expand_path(Rails.root), "app/templates/extra/bootstrap.min.css"), build_directory
    File.open("#{build_directory}/manifest.json", "w") {|f| f.write(JSON.pretty_generate(manifest))}
  end

end
