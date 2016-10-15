require './config/environment.rb'
require 'pry'

class ChargifySanityChecker < Thor
  desc "check", "Check Chargify sanity"
  def check
    check_chargify_subscription_without_gateway_subscription
    check_duplicate_gateway_subscriptions_with_same_chargify_subscription
    check_duplicate_chargify_subscriptions
  end

  desc "fix_duplicate_gateway_subscriptions", "Fix duplicate gateway subscription"
  def fix_duplicate_gateway_subscriptions
    duplicate_gateway_subscriptions = gateway_subscriptions.group_by(&:subscription_id).select { |k, v| v.size > 1 }
    duplicate_gateway_subscriptions.each do |chargify_id, gateway_subscriptions|
      puts "chargify id: #{chargify_id}"
      sorted_subscriptions = gateway_subscriptions.sort_by do |subscription|
        score = 0
        score += 60 if subscription.created_company
        score += subscription.regions.size
        score += -(1.0/subscription.created_at.to_i)
        -score
      end
      remain_subscription = sorted_subscriptions.shift
      print "remain: "
      display_subscription(remain_subscription)
      sorted_subscriptions.each do |subscription|
        print "delete: "
        display_subscription(subscription)
        subscription.destroy
      end
    end
  end

  desc "set_gateway_subscription_status", "Set gateway subscription status"
  def set_gateway_subscription_state
    chargify_subscriptions_hash = {}
    all_chargify_subscriptions.each do |s|
      chargify_subscriptions_hash[s.id] = s
    end

    gateway_subscriptions.each do |subscription|
      if chargify_subscription = chargify_subscriptions_hash[subscription.subscription_id.to_i]
        subscription.set(:state, chargify_subscription.state)
      end
    end
  end

  private

  def check_chargify_subscription_without_gateway_subscription
    unmatched_chargify_ids = chargify_subscriptions.map(&:id) - gateway_subscriptions.map(&:subscription_id).map(&:to_i)
    puts "# unmatched_chargify_ids"
    puts unmatched_chargify_ids.inspect
  end

  def check_duplicate_chargify_subscriptions
    duplicate_subscriptions = chargify_subscriptions.group_by { |cs| cs.customer.email }.select { |k, v| v.size > 1 }
    puts "# duplicate emails"
    duplicate_subscriptions.each do |email, subscriptions|
      puts email + ':'
      subscriptions.each do |subscription|
        gateway_subscription = GatewaySubscription.where(subscription_id: subscription.id.to_s).first
        print "subscription_id: #{subscription.id} "
        display_subscription(gateway_subscription)
      end
    end
  end

  def display_subscription(gateway_subscription)
    content = "gw_id: #{gateway_subscription.id} "
    content += "plan: #{gateway_subscription.product_handle} "
    content += "regions: #{gateway_subscription.regions.size} "
    content += "created_at: #{gateway_subscription.created_at} "
    content += "company: #{gateway_subscription.created_company.try(:name)} "
    content += "state: #{gateway_subscription.state}"
    puts content
  end

  def check_duplicate_gateway_subscriptions_with_same_chargify_subscription
    puts "# duplicate gatway subscriptions"
    duplicate_gateway_subscriptions = gateway_subscriptions.group_by(&:subscription_id).select { |k, v| v.size > 1 }
    duplicate_gateway_subscriptions.each do |chargify_id, gateway_subscriptions|
      puts "chargify id: #{chargify_id}"
      gateway_subscriptions.each do |subscription|
        display_subscription(subscription)
      end
    end
  end

  def chargify_subscriptions
    @chargify_subscriptions ||= all_chargify_subscriptions.select { |cs| cs.state != "canceled" }
  end

  def all_chargify_subscriptions
    return @all_chargify_subscriptions if defined? @all_chargify_subscriptions

    @all_chargify_subscriptions = []
    page = 1
    loop do
      results = Chargify::Subscription.all(params: { page: page, per_page: 200 })
      page += 1
      @all_chargify_subscriptions += results
      break if results.size < 200 
    end

    @all_chargify_subscriptions
  end

  def gateway_subscriptions
    @gateway_subscriptions ||= GatewaySubscription.all
  end
end
