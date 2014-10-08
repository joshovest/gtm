require 'google/api_client'
require 'google/api_client/service'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'

class GtmController < ApplicationController
  def index
    @result = client.execute(api_method: gtm.accounts.list).data.accounts
  end

  private
    def gtm
      gtm = client.discovered_api('tagmanager','v1beta')
      return gtm
    end

    def client
      client = Google::APIClient.new(authorization: authorization)
      doc = File.read('config/gtm/discovery.json')
      client.register_discovery_document('tagmanager','v1beta',doc)
      return client
    end

    def authorization
      storage = Google::APIClient::FileStorage.new('config/gtm/gtm.json')
      if storage.authorization.nil?
        client_secrets = Google::APIClient::ClientSecrets.load('config/gtm/client_secret.json')
        flow = Google::APIClient::InstalledAppFlow.new(
          client_id: client_secrets.client_id,
          client_secret: client_secrets.client_secret,
          scope: 'https://www.googleapis.com/auth/tagmanager'
        )
        authorization = flow.authorize(storage)
      else
        authorization = storage.authorization
      end
      return authorization
    end
end