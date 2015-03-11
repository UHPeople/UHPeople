Rails.application.config.middleware.use OmniAuth::Builder do
     provider :shibboleth, {
    :shib_session_id_field     => "HTTP_SHIB-SESSION-ID",
    :shib_application_id_field => "HTTP_SHIB_APPLICATION_ID",

    :uid_field                 => "HTTP_EPPN",
    :name_field                => lambda {|request_param| "#{request_param.call('cn')} #{request_param.call('sn')}"},
    :info_fields => {
      :affiliation => lambda {|request_param| "#{request_param.call('affiliation')}@my.localdomain"},
      :email    => "mail",
      :location => "contactAddress",
      :image    => "photo_url",
      :phone    => "contactPhone"
    },
    :debug => false 
  }
end
