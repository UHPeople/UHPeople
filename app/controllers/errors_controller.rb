class ErrorsController < ApplicationController
 
  def not_found
     render file: "#{Rails.root}/app/views/errors/404.html", layout: false, status: 404
  end
 
  def unacceptable
    render file: "#{Rails.root}/app/views/errors/422.html", layout: false, status: 422
  end
 
  def internal_error
    render file: "#{Rails.root}/app/views/errors/500.html", layout: false, status: 500
  end

 
end