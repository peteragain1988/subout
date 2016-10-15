class TestDataGenerator
  def demo_address
    [
      "540 Main St, Hyannis, MA, 02630",
      "2325 Maryland Road, Willow Grove, PA 19090",
      "1084 Shennecossett Road, Groton, CT 06340",
      "Route 1 South Ogunquit, ME 03907",
      "1404 Wheelock Road, Danville, VT 05828",
      "205 14th St NW, Charlottesville, VA 22903",
      "451 Bellevue Road, Newark, DE 19713",
    ].sample
  end

  def demo_vehicle_type
    [
      "4 Pass Sedan", "6 Pass Limo", "8 Pass Limo", "10 Pass Limo",
      "14 Pass SUV", "18 Pass SUV",
      "49 Pass Luxury Coach",
      "56 Pass Luxury Coach",
      "57 Pass Luxury Coach",
      "58 Pass Luxury Coach",
      "59 Pass Luxury Coach",
      "60 Pass Luxury Coach",
      "61 Pass Luxury Coach",
      "55 Pass Luxury Coach",
      "54 Pass Luxury Coach",
      "49 Pass Luxury Coach",
      "49 Pass Luxury Coach",
      "49 Pass Luxury Coach",
      "18 Pass Mini Bus",
      "24 Pass Mini Bus",
      "28 Pass Mini Bus",
      "30 Pass Mini Bus",
      "35 Pass Mini Bus"
    ].sample
  end

  def random_opportunity_type
    [
      "Vehicle Needed",
      "Vehicle for Hire",
      "Special",
      "Emergency",
      "Buy or Sell Parts and Vehicles"
    ].sample
  end

  def create_company(company_name, email, subscription)
    company = Company.create(
      email:            email,
      abbreviated_name: company_name.squeeze[0..5],
      name:             company_name,
      contact_name:     Faker::Name.name,
      fleet_size:       "7 65 PAX bus",
      since:            "1975",
      owner:            Faker::Name.name,
      contact_phone:    Faker::PhoneNumber.phone_number,
      tpa:              rand(99999999).to_s,
      website:          Faker::Internet.http_url,
      prelaunch:        false,
      created_from_subscription: subscription.id
    )
    User.create(email: email, company: company, password: 'password', password_confirmation: 'password')
    company
  end

  def national_subscription
    g = GatewaySubscription.new(product_handle: "subout-national-service")
    g.save(validate: false)
    g
  end

  def state_by_state_subscription
    g = GatewaySubscription.new(product_handle: "state-by-state-service")
    g.regions = demo_regions
    g.save(validate: false)
    g
  end

  def create_subscription(type)
    type == "national" ? national_subscription : state_by_state_subscription
  end

  def create_companies(companies, subscription_type)
    companies.map do |item|
      if Company.where(email: item[:email]).exists?
        puts "Company with email #{item[:email]} exists"
      else
        subscription = create_subscription(subscription_type)
        company = create_company(item[:company_name], item[:email], subscription)
        puts "Just created company for #{item[:email]}"
        puts company.inspect
      end
    end
  end

  def demo_part
    [
      "mirror",
      "tire",
      "seat",
      "brake light",
      "fuel pump"
    ].sample
  end

  def decent_opportunity_name(opportunity_type)
    case opportunity_type
    when "Vehicle Needed"
      "#{Faker::Address.city}, #{demo_vehicle_type}, #{rand(10).days.from_now.to_formatted_s(:short) }"
    when "Vehicle for Hire"
      "#{Faker::Address.city}, #{demo_vehicle_type}"
    when "Special"
      "#{Faker::Address.city}, #{demo_vehicle_type}, #{rand(100)}% OFF"
    when "Emergency"
      "#{Faker::Address.city}, Broken down on I#{rand(9)}95, mile #{rand(100)}"
    when "Buy or Sell Parts and Vehicles"
      "#{Faker::Address.city}, Need a #{demo_part}"
    end
  end

  def demo_regions
    %w{ Pennsylvania Connecticut Vermont Maine Virginia Delaware Massachusetts }
  end

  def generate_opportunities
    Company.all.each do |company|
      25.times do
        opp_type = random_opportunity_type
        opportunity = Opportunity.create(
          name:           decent_opportunity_name(opp_type),
          description:    "#{rand(100)} seats",
          start_location: demo_address,
          end_location:   demo_address,
          start_date:     (2+rand(4)).days.from_now.to_s,
          start_time:     "12:00",
          end_date:       12.days.from_now.to_s,
          end_time:       "12:00",
          bidding_ends:   1.days.from_now.to_s,
          quick_winnable: false,
          type:           opp_type,
          buyer_id:       company.id,
          bidding_duration_hrs: 24,
          notification_type:    'Individual')
          puts opportunity.errors.inspect unless opportunity.valid?
      end
    end
  end

  def generate_bids
    Company.all.each do |company|
      10.times do
        print(".")
        o = Opportunity.all.shuffle.first
        unless o.nil?
          Bid.create(amount: rand(1000), opportunity_id: o.id, bidder_id: company.id)
        end
      end
    end
  end
end
