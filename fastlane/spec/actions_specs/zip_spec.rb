describe Fastlane do
  describe Fastlane::FastFile do
    before do
      allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
      @fixtures_path = "./fastlane/spec/fixtures/actions/zip"
      @path = @fixtures_path + "/file.txt"
      @output_path_with_zip = @fixtures_path + "/archive_file.zip"
      @output_path_without_zip = @fixtures_path + "/archive_file"
    end

    describe "zip" do
      it "generates a valid zip command" do
        expect(Fastlane::Actions).to receive(:sh).with(["zip", "-r", "#{File.expand_path(@path)}.zip", "file.txt"])

        result = Fastlane::FastFile.new.parse("lane :test do
          zip(path: '#{@path}')
        end").runner.execute(:test)
      end

      it "generates a valid zip command without verbose output" do
        expect(Fastlane::Actions).to receive(:sh).with(["zip", "-rq", "#{File.expand_path(@path)}.zip", "file.txt"])

        result = Fastlane::FastFile.new.parse("lane :test do
          zip(path: '#{@path}', verbose: false)
        end").runner.execute(:test)
      end

      it "generates an output path given no output path" do
        result = Fastlane::FastFile.new.parse("lane :test do
          zip(path: '#{@path}', output_path: '#{@path}')
        end").runner.execute(:test)

        expect(result).to eq(File.absolute_path("#{@path}.zip"))
      end

      it "generates an output path with zip extension (given zip extension)" do
        result = Fastlane::FastFile.new.parse("lane :test do
          zip(path: '#{@path}', output_path: '#{@output_path_with_zip}')
        end").runner.execute(:test)

        expect(result).to eq(File.absolute_path(@output_path_with_zip))
      end

      it "generates an output path with zip extension (not given zip extension)" do
        result = Fastlane::FastFile.new.parse("lane :test do
          zip(path: '#{@path}', output_path: '#{@output_path_without_zip}')
        end").runner.execute(:test)

        expect(result).to eq(File.absolute_path(@output_path_with_zip))
      end

      it "encrypts the contents of the zip archive using a password" do
        password = "5O#RUKp0Zgop"
        expect(Fastlane::Actions).to receive(:sh).with(["zip", "-rq", "-P", password, "#{File.expand_path(@path)}.zip", "file.txt"])

        result = Fastlane::FastFile.new.parse("lane :test do
          zip(path: '#{@path}', verbose: false, password: '#{password}')
        end").runner.execute(:test)
      end

      it "archives a directory" do
        expect(Fastlane::Actions).to receive(:sh).with(["zip", "-r", "#{File.expand_path(@fixtures_path)}.zip", "zip"])

        result = Fastlane::FastFile.new.parse("lane :test do
          zip(path: '#{@fixtures_path}')
        end").runner.execute(:test)
      end

      it "archives a directory with shell escaped path" do
        expected_input_path = "escaped()_input_folder_path".shellescape
        expected_output_path = "output()_path".shellescape

        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:expand_path).and_return("..")
        expect(Fastlane::Actions).to receive(:sh).with(["zip", "-r", "#{File.expand_path(expected_output_path)}.zip", expected_input_path])

        Fastlane::FastFile.new.parse("lane :test do
          zip(path: 'fake/escaped()_input_folder_path', output_path: 'output()_path')
        end").runner.execute(:test)
      end

      it "supports excluding specific files or directories" do
        expect(Fastlane::Actions).to receive(:sh).with(["zip", "-r", "#{File.expand_path(@fixtures_path)}.zip", "zip", "-x", "zip/.git/*", "zip/README.md"])

        Fastlane::FastFile.new.parse("lane :test do
          zip(path: '#{@fixtures_path}', exclude: ['.git/*', 'README.md'])
        end").runner.execute(:test)
      end

      it "supports including specific files or directories" do
        expect(Fastlane::Actions).to receive(:sh).with(["zip", "-r", "#{File.expand_path(@fixtures_path)}.zip", "zip", "-i", "zip/**/*.rb"])

        Fastlane::FastFile.new.parse("lane :test do
          zip(path: '#{@fixtures_path}', include: ['**/*.rb'])
        end").runner.execute(:test)
      end
    end
  end
end
