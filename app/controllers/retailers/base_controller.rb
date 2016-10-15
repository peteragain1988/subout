class Retailers::BaseController < ApplicationController
  before_filter :authenticate_retailer!
  layout 'retailer'
end
