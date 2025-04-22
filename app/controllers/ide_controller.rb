class IdeController < ApplicationController
  before_action :authenticate_user!
  layout "ide"
  def index
    @models = Dir.glob(Rails.root.join("app/models/**/*.rb")).map { |f| File.basename(f) }
    @controllers = Dir.glob(Rails.root.join("app/controllers/**/*.rb")).map { |f| File.basename(f) }
    @views = Dir.glob(Rails.root.join("app/views/**/*.html.erb")).map { |f| f.sub("#{Rails.root}/app/views/", "") }
    @others = (Dir.glob(Rails.root.join("config/**/*.rb")) +
               Dir.glob(Rails.root.join("db/migrate/**/*.rb")) +
               Dir.glob(Rails.root.join("app/assets/**/*.js")) +
               Dir.glob(Rails.root.join("app/assets/**/*.css"))).map { |f| File.basename(f) }

    if params[:file]
      @file_path = Rails.root.join(params[:file])
      if File.exist?(@file_path)
        @file_content = File.read(@file_path)
      else
        @file_content = "Fichier introuvable."
      end
    end
  end
end
