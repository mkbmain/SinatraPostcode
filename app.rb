require 'active_record'
require 'postgresql'
require 'active_model'
require 'sinatra'
require 'json'
require 'unicode_utils'

class Response
  attr_reader :postcode, :longitude, :latitude, :standard_postcode

  def initialize(postcode, standard_postcode, long, lat)
    @postcode = postcode
    @standard_postcode = standard_postcode
    @longitude = long
    @latitude = lat
  end
end

class PostCode < ActiveRecord::Base
  self.table_name = "postcode_location"
  validates :postcode, presence: true
  validates :latitude, presence: true, uniqueness: false
  validates :longitude, presence: false, uniqueness: false
  validates :source_id, presence: false, uniqueness: false
end

get '/' do
  'Rest Api'
end

get '/Postcode/:postcode' do
  postcode = params[:postcode].downcase.delete(' ')
  record = PostCode.where(postcode: postcode).first
  if record.nil?
    return not_found
  end
  return Response.new(params[:postcode],record.postcode, record.longitude, record.latitude).to_json
end

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  host: ENV["PostgresPostCodeDbHost"],
  port: ENV["PostgresPostCodeDbPort"],
  database: ENV["PostgresPostCodeDbName"],
  username: ENV["PostgresPostCodeUser"],
  password: ENV["PostgresPostCodeUserKey"]
)

