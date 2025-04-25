class ProjetsController < ApplicationController
  before_action :authenticate_user!

  def new
    @projet = Projet.new
  end

  require "open3"

  def create
    nom = projet_params[:nom].strip
    return redirect_to new_projet_path, alert: "Nom de projet invalide" unless nom.match?(/\A[a-zA-Z0-9_-]+\z/)

    base_user_dir = "/home/novaterra/users/#{current_user.username}"
    chemin = File.join(base_user_dir, nom)

    FileUtils.mkdir_p(base_user_dir) unless Dir.exist?(base_user_dir)

    if Dir.exist?(chemin)
      redirect_to new_projet_path, alert: "Un projet avec ce nom existe déjà." and return
    end

    # 🧠 Création réelle du projet Rails
    cmd = [ "rails", "new", nom, "--skip-bundle" ]
    stdout_str, stderr_str, status = Open3.capture3(*cmd, chdir: base_user_dir)

    unless status.success?
      Rails.logger.error "Erreur rails new: #{stderr_str}"
      redirect_to new_projet_path, alert: "Erreur à la création du projet : #{stderr_str}" and return
    end

    @projet = current_user.projets.build(nom: nom, chemin: chemin)

    if @projet.save
      redirect_to ide_path(project: chemin), notice: "Projet créé avec succès ✅"
    else
      redirect_to new_projet_path, alert: "Erreur à l’enregistrement du projet."
    end
  end

  def destroy
    @projet = current_user.projets.find(params[:id])
    @projet.destroy
    redirect_to root_path, notice: "Projet supprimé"
  end

  private

  def projet_params
    params.require(:projet).permit(:nom)
  end
end
