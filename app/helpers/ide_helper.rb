# app/helpers/ide_helper.rb
module IdeHelper
  def build_file_tree(path, base_path = "")
    tree = []

    Dir.entries(path).sort.each do |entry|
      next if entry.starts_with?(".") # ignorer . et ..

      full_path = File.join(path, entry)
      relative_path = File.join(base_path, entry)

      if File.directory?(full_path)
        tree << { name: entry, type: :directory, path: relative_path, children: build_file_tree(full_path, relative_path) }
      else
        tree << { name: entry, type: :file, path: relative_path }
      end
    end

    tree
  end
end
