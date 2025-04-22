class DashboardController < ApplicationController
  before_action :authenticate_user!

  def home
    @infos_a_completer = current_user.langue.blank? || current_user.niveau.blank?
  end
end
