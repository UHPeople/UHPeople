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
    params.require(:user).permit(:username, :name, :title, :email, :campus, :faculty, :unit, :about, :profilePicture)
  end

  def edit_user_params
    params.require(:user).permit(:title, :campus, :faculty, :unit, :about, :profilePicture)
  end

  def set_arrays
    @campuses = ['City Centre Campus', 'Kumpula Campus', 'Meilahti Campus', 'Viikki Campus']

    @faculties = ["Faculty of Arts", "Faculty of Behavioural Sciences", "Faculty of Law",
                  "Faculty of Social Sciences", "Faculty of Theology",
                  "Swedish School of Social Science", "Faculty of Science", "Faculty of Medicine",
                  "Faculty of Biological and Environmental Sciences",
                  "Faculty of Agriculture and Forestry", "Faculty of Veterinary Medicine",
                  "Faculty of Pharmacy", "Central administration", "other"
    ]

    @units = [
        {name: "Department of Finnish, Finno-Ugrian and Scandinavian Studies", faculty: "Faculty of Arts"},
        {name: "Department of Modern Languages", faculty: "Faculty of Arts"},
        {name: "Department of World Cultures", faculty: "Faculty of Arts"},
        {name: "Department of Philosophy, History, Culture and Art Studies", faculty: "Faculty of Arts"},
        {name: "Department of Teacher Education", faculty: "Faculty of Behavioural Sciences"},
        {name: "Institute of Behavioural Sciences", faculty: "Faculty of Behavioural Sciences"},
        {name: "Helsingin normaalilyseo (The Normal Lyceum of Helsinki)", faculty: "Faculty of Behavioural Sciences"},
        {name: "Viikki Teacher Training School of Helsinki University", faculty: "Faculty of Behavioural Sciences"},
        {name: "Department of Social Research", faculty: "Faculty of Social Sciences"},
        {name: "Department of Political and Economic Studies", faculty: "Faculty of Social Sciences"},
        {name: "Department of Chemistry", faculty: "Faculty of Science"},
        {name: "Finnish Institute for Verification of the Chemical Weapons Convention (VERIFIN)", faculty: "Faculty of Science"},
        {name: "Department of Computer Science", faculty: "Faculty of Science"},
        {name: "Department of Geosciences and Geography", faculty: "Faculty of Science"},
        {name: "Institute of Seismology", faculty: "Faculty of Science"},
        {name: "Department of Mathematics and Statistics", faculty: "Faculty of Science"},
        {name: "Department of Physics", faculty: "Faculty of Science"},
        {name: "Clinicum", faculty: "Faculty of Medicine"},
        {name: "Medicum", faculty: "Faculty of Medicine"},
        {name: "Research Programs Unit", faculty: "Faculty of Medicine"},
        {name: "Department of Biosciences", faculty: "Faculty of Biological and Environmental Sciences"},
        {name: "Department of Environmental Sciences", faculty: "Faculty of Biological and Environmental Sciences"},
        {name: "Kilpisjärvi Biological Station", faculty: "Faculty of Biological and Environmental Sciences"},
        {name: "Lammi Biological Station", faculty: "Faculty of Biological and Environmental Sciences"},
        {name: "Tvärminne Zoological Station", faculty: "Faculty of Biological and Environmental Sciences"},
        {name: "Department of Food and Environmental Sciences", faculty: "Faculty of Agriculture and Forestry"},
        {name: "Department of Agricultural Sciences", faculty: "Faculty of Agriculture and Forestry"},
        {name: "Viikki Research Farm", faculty: "Faculty of Agriculture and Forestry"},
        {name: "Department of Forest Sciences", faculty: "Faculty of Agriculture and Forestry"},
        {name: "Hyytiälä Forestry Field Station", faculty: "Faculty of Agriculture and Forestry"},
        {name: "Värriö Subartic Research Station", faculty: "Faculty of Agriculture and Forestry"},
        {name: "Department of Economics and Management", faculty: "Faculty of Agriculture and Forestry"},
        {name: "Veterinary Teaching Hospital", faculty: "Faculty of Veterinary Medicine"},

        {name: "Aleksanteri Institute - Finnish Centre for Russian and East European Studies", faculty: "other"},
        {name: "Center for Information Technology (IT Center)", faculty: "other"},
        {name: "Center for Properties and Facilities", faculty: "other"},
        {name: "Finnish Museum of Natural History LUOMUS", faculty: "other"},
        {name: "Helsinki Collegium for Advanced Studies", faculty: "other"},
        {name: "Helsinki Institute for Information Technology", faculty: "other"},
        {name: "Helsinki Institute of Physics (HIP)", faculty: "other"},
        {name: "Helsinki University Library", faculty: "other"},
        {name: "Institute of Biotechnology", faculty: "other"},
        {name: "Institute for Molecular Medicine Finland (FIMM)", faculty: "other"},
        {name: "IPR University Center", faculty: "other"},
        {name: "Language Centre", faculty: "other"},
        {name: "The National Library of Finland", faculty: "other"},
        {name: "Viikki Laboratory Animal Centre", faculty: "other"},
        {name: "Neuroscience Center", faculty: "other"},
        {name: "Open University", faculty: "other"},
        {name: "Palmenia Centre for Continuing Education", faculty: "other"},
        {name: "UniSport", faculty: "other"},
        {name: "The Lahti University Consortium", faculty: "other"},
        {name: "The Mikkeli University Consortium", faculty: "other"},

        {name: "Administrative Services", faculty: "Central administration"},
        {name: "Central Administration", faculty: "Central administration"},
        {name: "Rector's Office", faculty: "Central administration"},
        {name: "University Services", faculty: "Central administration"},
        {name: "Communications and Community Relations", faculty: "Central administration"},
        {name: "Finance", faculty: "Central administration"},
        {name: "Human Resources and Legal Affairs", faculty: "Central administration"},
        {name: "Research and Education", faculty: "Central administration"},
        {name: "Strategic Planning and Quality Assurance", faculty: "Central administration"},
        {name: "University Museum", faculty: "Central administration"},
        {name: "Central Archives", faculty: "Central administration"}
    ]
  end
end
