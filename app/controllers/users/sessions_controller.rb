class Users::SessionsController < Devise::SessionsController
  def destroy
    flash[:notice] = "À bientôt sur NovaTerra-Hub ! 🚀"
    super
  end
end
