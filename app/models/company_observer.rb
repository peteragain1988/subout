class CompanyObserver < Mongoid::Observer
  observe :company

  private

end
