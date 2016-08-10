class CASino::LoginAttempt < ActiveRecord::Base
  include CASino::ModelConcern::BrowserInfo

  belongs_to :user

  def failed?
    !successful?
  end
end
