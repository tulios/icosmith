require "zip_file_generator"

class FontGeneratorController < ApplicationController

  def create
    unless params[:base64zip].blank?
      file = Tempfile.open(["#{Time.now.to_i}", ".zip"], encoding: "ascii-8bit")
      file.write Base64.decode64(params[:base64zip])
      file.close # ensure the write, odd cases :/

      file_name = file.path.scan(/\/([^\/]+)$/).flatten.first
      dir_name = file.path.gsub(file_name, '').gsub(/\/$/, '')
      @temp_file = File.open(file.path)

    else
      file = params["file"]
      file_name = file[:filename]
      dir_name = file_name.gsub(/\.zip$/, '')
      @temp_file = file[:tempfile].path
    end

    Dir.mktmpdir do |dir|
      upload_path = "#{dir}/#{dir_name}"
      unzip! @temp_file, upload_path

      manifest = Manifest.generate(upload_path)
      builder = FontBuilder.new(manifest, upload_path)

      builder.build!
      prepare_package! manifest, builder

      filename = zip_name(manifest)
      result_path = zip! upload_path, filename, builder

      send_file(result_path, {
        filename: filename,
        type: "application/zip",
        disposition: "attachment"
      })
    end
  ensure
    if @temp_file
      @temp_file.close
      @temp_file.unlink if @temp_file.respond_to?(:unlink)
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

  def zip! path, filename, builder
    diretory_to_zip = builder.build_path
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

  def prepare_package! manifest, builder
    FileUtils.cp File.join(File.expand_path(Rails.root), "app/templates/extra/bootstrap.min.css"), builder.build_path
    File.open("#{builder.build_path}/manifest.json", "w") {|f| f.write(Manifest.filter_to_save(manifest))}
  end

end
