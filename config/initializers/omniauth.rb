Rails.application.config.middleware.use OmniAuth::Builder do
  provider :shibboleth, {
    :shib_session_id_field     => "HTTP_SHIB-SESSION-ID",
    :shib_application_id_field => "HTTP_SHIB_APPLICATION_ID",

    :uid_field                 => "HTTP_UID",
    :name_field                => "HTTP_CN",
    :info_fields => {
      :mail	       => "HTTP_MAIL",
    },

    :debug => false,
  }
end
