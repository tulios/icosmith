require "spec_helper"

describe Manifest do
  let(:path) { "path" }

  describe "#initialize" do
    let(:hash) do
      {family: "some family"}
    end

  end

  describe "::exist?" do
    it "should check the existence of Manifest::FILENAME in the given path" do
      File.should_receive(:exist?).with("#{path}/#{Manifest::FILENAME}")
      Manifest.exist?(path)
    end
  end

  describe "::read" do
    let :hash do
      {
        family: "family",
        glyphs: []
      }
    end

    it "should read and parse the Manifest::FILENAME in the given path" do
      File.should_receive(:read).with("#{path}/#{Manifest::FILENAME}").and_return(hash.to_json)
      expect(Manifest.read(path)).to eql hash
    end
  end

  describe "::get_svgs_from" do
    it "should select only .svg files and remove the .svg extension" do
      Dir.should_receive(:entries).with(path).and_return(["a.png", "b.zip", "c.rb", "d.svg"])
      expect(Manifest.get_svgs_from(path)).to eql ["d"]
    end

    it "should accept an exclude list" do
      Dir.should_receive(:entries).with(path).and_return(["a.svg", "b.svg"])
      expect(Manifest.get_svgs_from(path, ["b"])).to eql ["a"]
    end

    it "should return an empty array if the directory does not exist" do
      Dir.should_receive(:entries).and_raise(Errno::ENOENT)
      expect(Manifest.get_svgs_from(path)).to be_empty
    end
  end

  describe "::generate" do
    context "without any manifest" do
      let :hash do
        {family: "my font", glyphs: [glyph]}
      end

      let :glyph do
        {name: "arrow", code: "0xe001"}
      end

      let :entries do
        ["#{glyph[:name]}.svg"]
      end

      before do
        Manifest.should_receive(:exist?).and_return(true)
        Manifest.should_receive(:read).and_return(hash)
        Dir.should_receive(:entries).with(path).and_return(entries)
      end

      it "should fallback name with the family name" do
        manifest = Manifest.generate(path)
        expect(manifest[:name]).to eql hash[:family]
      end

      it "should merge the defaults" do
        manifest = Manifest.generate(path)

        (Manifest::DEFAULT_MANIFEST.keys - [:family, :name]).each do |key|
          expect(manifest[key]).to eql Manifest::DEFAULT_MANIFEST[key]
        end

        expect(manifest[:family]).to eql hash[:family]
      end

      it "should merge the glyph defaults and convert code to integer" do
        manifest = Manifest.generate(path)

        (Manifest::DEFAULT_GLYPH.keys - [:code, :name]).each do |key|
          expect(manifest[:glyphs].first[key]).to eql Manifest::DEFAULT_GLYPH[key]
        end

        expect(manifest[:glyphs].first[:name]).to eql glyph[:name]
        expect(manifest[:glyphs].first[:code]).to eql glyph[:code].to_i(16)
      end

      context "when .zip comes with more than configured svgs" do
        let :entries do
          ["#{glyph[:name]}.svg", "#{new_entry}.svg"]
        end

        let :new_entry do
          "user"
        end

        it "should update the glyphs" do
          manifest = Manifest.generate(path)
          expect(manifest[:glyphs].length).to eql 2

          new_glyph = manifest[:glyphs].last
          expect(new_glyph[:name]).to eql new_entry
          expect(new_glyph[:code]).to eql glyph[:code].to_i(16) + 1
        end
      end
    end
  end
end
