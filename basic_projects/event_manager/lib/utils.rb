# Adding a method for safe reading
class File

  def self.read_safe(file_name)
    begin File.exist? file_name
      contents = File.read(file_name)
    rescue StandardError => e
      puts e
      puts "Check that #{file_name} exist in the directory #{__dir__}"
      exit
    end
  end

end
