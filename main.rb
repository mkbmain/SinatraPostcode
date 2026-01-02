require 'active_record'
require 'postgresql'
require 'active_model'
require 'sinatra'
require 'json'
require 'unicode_utils'

class Response
  attr_reader :postcode, :longitude, :latitude

  def initialize(postcode, long, lat)
    @postcode = postcode
    @longitude = long
    @latitude = lat
  end
end

class PostCode < ActiveRecord::Base
  self.table_name = "postcode_location"

  # Validations
  validates :postcode, presence: true
  validates :latitude, presence: true, uniqueness: false
  validates :longitude, presence: false, uniqueness: false
  validates :source_id, presence: false, uniqueness: false
end


get '/Postcode/:postcode' do
  postcode = params[:postcode].downcase.delete(' ')
  record = PostCode.where(postcode: postcode).first
  if record.nil?
    return not_found
  end
  return Response.new(record.postcode, record.longitude, record.latitude).to_json
end

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  host: 'postcodedb-4667.6zw.aws-eu-west-1.cockroachlabs.cloud',
  port: 26257,
  database: 'defaultdb',
  username: 'PostCodeUser',
  password: '',
)
