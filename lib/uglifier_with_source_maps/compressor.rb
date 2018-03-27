module UglifierWithSourceMaps
  class Compressor
    def self.call(*args)
      new.call(*args)
    end

    def initialize(options = {})
      @uglifier = Uglifier.new(options)
      # @cache_key = [
      #     'UglifierWithSourceMapsCompressor',
      #     ::Uglifier::VERSION,
      #     ::UglifierWithSourceMaps::VERSION,
      #     options
      #   ]
    end

    def compress(data, context)

      minified_data, sourcemap = @uglifier.compile_with_map(data)

      # write source map
      sourcemap_filename    = [Rails.application.config.assets.prefix, Rails.application.config.assets.sourcemaps_prefix, "#{context.logical_path}-#{digest(minified_data)}.map"].join('/')
      concatenated_filename = [Rails.application.config.assets.prefix, Rails.application.config.assets.uncompressed_prefix, "#{context.logical_path}-#{digest(minified_data)}.js"].join('/')

      result = minified_data

      minified_filename     = [Rails.application.config.assets.prefix, "#{context.logical_path}-#{digest(result)}.js"].join('/')


      map = JSON.parse(sourcemap)
      map['file']    = minified_filename
      map['sources'] = [concatenated_filename]

      FileUtils.mkdir_p File.dirname(File.join(Rails.public_path, sourcemap_filename))
      FileUtils.mkdir_p File.dirname(File.join(Rails.public_path, concatenated_filename))

      # Write sourcemap and uncompressed js
      File.open(File.join(Rails.public_path, sourcemap_filename), "w") { |f| f.puts map.to_json }
      File.open(File.join(Rails.public_path, concatenated_filename), "w") {|f| f.write(data)}

      return result
    end

    def digest(io)
      Rails.application.assets.digest.update(io).hexdigest
    end
  end
end
