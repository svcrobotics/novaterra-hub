class IdeController < ApplicationController
  before_action :authenticate_user!
  layout "ide"

  def index
    @file_tree = build_file_tree(Rails.root)

    if params[:file].present?
      @current_file = params[:file]
      full_path = Rails.root.join(@current_file)

      if File.exist?(full_path)
        @file_content = File.read(full_path)
        @file_mtime = File.mtime(full_path).to_i
      end

      @opened_files = (params[:opened_files] || "").split(",").push(@current_file).uniq
    else
      @file_content = nil
      @current_file = nil
      @opened_files = []
      @file_mtime = nil
    end
  end

  def update
    file_path = Rails.root.join(params[:file])
    current_mtime = File.exist?(file_path) ? File.mtime(file_path).to_i : nil
    submitted_mtime = params[:file_mtime].to_i

    puts "DEBUG → file_path: #{file_path}"
    puts "DEBUG → current_mtime: #{current_mtime}"
    puts "DEBUG → submitted_mtime: #{submitted_mtime}"

    if !File.exist?(file_path)
      flash[:alert] = "Le fichier n'existe pas ❌"
    elsif current_mtime != submitted_mtime
      flash[:alert] = "Ce fichier a été modifié depuis votre dernière ouverture. Modification bloquée pour éviter d'écraser des données ❌"
    else
      File.write(file_path, params[:content])
      flash[:notice] = "Fichier sauvegardé avec succès ✅"
    end

    redirect_to ide_path(file: params[:file], opened_files: params[:opened_files])
  end


  private

  IGNORED_FOLDERS = %w[tmp log node_modules vendor storage .git .cache coverage]

  def build_file_tree(path)
    entries = Dir.entries(path) - %w[. ..]
    entries = entries.reject { |e| IGNORED_FOLDERS.include?(e) }

    entries.map do |entry|
      full_path = path.join(entry)
      if File.directory?(full_path)
        {
          name: entry,
          type: :folder,
          children: build_file_tree(full_path)
        }
      else
        {
          name: entry,
          type: :file,
          path: full_path.to_s.sub("#{Rails.root}/", "")
        }
      end
    end
  end
end
