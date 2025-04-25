class IdeController < ApplicationController
  before_action :authenticate_user!
  layout "ide"

  def index
    current_project_root!

    @file_tree = build_file_tree(@project_root)

    if params[:file].present?
      @current_file = params[:file]
      full_path = secure_path(@current_file)

      if full_path && File.exist?(full_path)
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
    Rails.logger.warn "📩 Params reçus : #{params.inspect}"
    current_project_root!

    file_path = secure_path(params[:file])
    submitted_mtime = params[:file_mtime].to_i

    unless file_path && File.exist?(file_path)
      redirect_to ide_path, alert: "Fichier introuvable ou non autorisé ❌" and return
    end

    current_mtime = File.mtime(file_path).to_i

    if current_mtime != submitted_mtime
      flash[:alert] = "Le fichier a été modifié ailleurs. Enregistrement annulé ❌"
    else
      File.write(file_path, params[:content])
      flash[:notice] = "Fichier enregistré avec succès ✅"
    end

    redirect_to ide_path(file: params[:file], opened_files: params[:opened_files], project: params[:project])
  end


  private

  IGNORED_FOLDERS = %w[tmp log node_modules vendor storage .git .cache coverage]

  def build_file_tree(path)
    path = Pathname.new(path) unless path.is_a?(Pathname)

    entries = Dir.entries(path) - %w[. ..]
    entries = entries.reject { |e| IGNORED_FOLDERS.include?(e) }

    entries.sort_by! do |entry|
      if entry.start_with?(".")
        [ 2, entry.downcase ]
      elsif File.directory?(path.join(entry))
        [ 0, entry.downcase ]
      else
        [ 1, entry.downcase ]
      end
    end

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
          path: full_path.relative_path_from(@project_root).to_s
        }
      end
    end
  end

  def secure_path(relative_path)
    return nil unless @project_root

    base = File.expand_path(@project_root)
    full = File.expand_path(File.join(base, relative_path))

    # 🔐 Interdiction absolue d’écrire hors du dossier projet
    full.start_with?(base) ? full : nil
  end

  def current_project_root!
    unless params[:project].present?
      redirect_to root_path, alert: "Aucun projet sélectionné ❌" and return
    end

    @project_root = Pathname.new(params[:project])
  end
end
