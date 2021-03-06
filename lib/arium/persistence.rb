module Arium
  module Persistence
    def read_generation(filename)
      JSON.parse(File.read(filename))
    end

    def write_generation(filename, generation)
      File.open(filename, 'w') do |f|
        f.write(JSON.generate(generation))
      end
    end
  end
end
