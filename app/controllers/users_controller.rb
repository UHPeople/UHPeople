class UsersController < ApplicationController
  before_action :require_non_production, only: [:new, :create]
  before_action :require_login, only: [:show, :edit, :update]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :set_arrays, only: [:new, :show, :edit, :update, :shibboleth_callback]
  before_action :user_is_current, only: [:edit, :update]

  def index
    @users = User.all
    respond_to do |format|
      format.json do
        render json: 'Not logged in' if current_user.nil?

        users = @users.collect do |user|
          { id: user.id, name: user.name, avatar: user.profile_picture_url }
        end

        render json: users
      end

      format.html { require_non_production }
    end
  end

  def new
    request.env['omniauth.auth'] = {}
    request.env['omniauth.auth']['info'] = {}

    request.env['omniauth.auth']['uid'] = random_string
    request.env['omniauth.auth']['info']['name'] = ''
    request.env['omniauth.auth']['info']['mail'] = ''

    shibboleth_callback
  end

  def update
    if @user.update(edit_user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to feed_index_path
    else
      redirect_to action: 'new'
    end
  end

  def set_first_time_use
    value = params[:value]
    current_user.update_attribute(:first_time, value)

    if value
      redirect_to feed_index_path
    else
      redirect_to notifications_path
    end
  end

  def set_profile_picture
    id = params[:pic_id].to_i
    photo = Photo.find(id)

    if photo.nil?
      redirect_to :back, alert: 'Invalid photo!'
    else
      current_user.update_attribute(:profilePicture, id)
      redirect_to current_user, notice: 'Profile picture changed.'
    end
  end

  def shibboleth_callback
    uid = request.env['omniauth.auth']['uid']
    @user = User.find_by username: uid

    if @user.nil?
      name = request.env['omniauth.auth']['info']['name'].force_encoding('utf-8')
      mail = request.env['omniauth.auth']['info']['mail']

      @user = User.new username: uid, name: name, email: mail
      render action: 'new'
    else
      session[:user_id] = @user.id
      redirect_to feed_index_path
    end
  end

  private

  def random_string
    # from http://codereview.stackexchange.com/questions/15958/
    range = ((48..57).to_a + (65..90).to_a + (97..122).to_a)
    5.times { ([nil] * 8).map { range.sample.chr }.join }
  end

  def user_is_current
    redirect_to root_path unless params[:id].to_s === session[:user_id].to_s
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :name, :title, :email, :campus, :unit, :about, :profilePicture)
  end

  def edit_user_params
    params.require(:user).permit(:title, :campus, :unit, :about, :profilePicture)
  end

  def set_arrays
    @campuses = ['City Centre Campus', 'Kumpula Campus', 'Meilahti Campus', 'Viikki Campus']

    @units = [
        faculty: "Faculty of Arts", units: {
                                      name: "Department of Finnish, Finno-Ugrian and Scandinavian Studies",
                                      name: "Department of Modern Languages",
                                      name: "Department of World Cultures",
                                      name: "Department of Philosophy, History, Culture and Art Studies"
                                  },
        faculty: "Faculty of Behavioural Sciences", units: {
                                      name: "Department of Teacher Education",
                                      name: "Institute of Behavioural Sciences",
                                      name: "Helsingin normaalilyseo (The Normal Lyceum of Helsinki)",
                                      name: "Viikki Teacher Training School of Helsinki University"
                                  },
        faculty: "Faculty of Law",

        faculty: "Faculty of Social Sciences", units: {
                                      name: "Department of Social Research",
                                      name: "Department of Political and Economic Studies"
                                  },
        faculty: "Faculty of Theology",
        faculty: "Swedish School of Social Science",
        faculty: "Faculty of Science", units: {
                                      name: "Department of Chemistry",
                                      name: "Finnish Institute for Verification of the Chemical Weapons Convention (VERIFIN)",
                                      name: "Department of Computer Science",
                                      name: "Department of Geosciences and Geography",
                                      name: "Institute of Seismology",
                                      name: "Department of Mathematics and Statistics",
                                      name: "Department of Physics"
                                  },
        faculty: "Faculty of Medicine", units: {
                                      name: "Clinicum",
                                      name: "Medicum",
                                      name: "Research Programs Unit"
                                  },
        faculty: "Faculty of Biological and Environmental Sciences", units: {
                                      name: "Department of Biosciences",
                                      name: "Department of Environmental Sciences",
                                      name: "Kilpisjärvi Biological Station",
                                      name: "Lammi Biological Station",
                                      name: "Tvärminne Zoological Station"
                                  },
        faculty: "Faculty of Agriculture and Forestry", units: {
                                      name: "Department of Food and Environmental Sciences",
                                      name: "Department of Agricultural Sciences",
                                      name: "Viikki Research Farm",
                                      name: "Department of Forest Sciences",
                                      name: "Hyytiälä Forestry Field Station",
                                      name: "Värriö Subartic Research Station",
                                      name: "Department of Economics and Management"
                                  },
        faculty: "Faculty of Veterinary Medicine", units: {
                                      name: "Veterinary Teaching Hospital"
                                  },
        faculty: "Faculty of Pharmacy",

        faculty: "other", units: {
                                      name: "Aleksanteri Institute - Finnish Centre for Russian and East European Studies",
                                      name: "Center for Information Technology (IT Center)",
                                      name: "Center for Properties and Facilities",
                                      name: "Finnish Museum of Natural History LUOMUS",
                                      name: "Helsinki Collegium for Advanced Studies",
                                      name: "Helsinki Institute for Information Technology",
                                      name: "Helsinki Institute of Physics (HIP)",
                                      name: "Helsinki University Library",
                                      name: "Institute of Biotechnology",
                                      name: "Institute for Molecular Medicine Finland (FIMM)",
                                      name: "IPR University Center",
                                      name: "Language Centre",
                                      name: "The National Library of Finland",
                                      name: "Viikki Laboratory Animal Centre",
                                      name: "Neuroscience Center",
                                      name: "Open University",
                                      name: "Palmenia Centre for Continuing Education",
                                      name: "UniSport",
                                      name: "The Lahti University Consortium",
                                      name: "The Mikkeli University Consortium"
                                  },
        faculty: "Central administration", units: {
                                      name: "Administrative Services",
                                      name: "Central Administration",
                                      name: "Rector's Office",
                                      name: "University Services",
                                      name: "Communications and Community Relations",
                                      name: "Finance",
                                      name: "Human Resources and Legal Affairs",
                                      name: "Research and Education",
                                      name: "Strategic Planning and Quality Assurance",
                                      name: "University Museum",
                                      name: "Central Archives"
                                  }
    ]
  end
end
