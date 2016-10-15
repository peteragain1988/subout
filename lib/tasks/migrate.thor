require './config/environment.rb'

class Migrate < Thor
  desc "change_currency", "Change currency"
  def change_currency
    Mongoid.unit_of_work(disable: :all) do
      Bid.all.each do |bid|
        amount = bid[:amount]
        bid.set(:amount, amount.to_i * 100) if amount.kind_of?(String)
      end

      Opportunity.all.each do |o|
        win_it_now_price = o[:win_it_now_price]
        o.set(:win_it_now_price, win_it_now_price.to_i * 100) if win_it_now_price.kind_of?(String)

        value = o[:value]
        o.set(:value, value.to_i * 100) if value.kind_of?(String)
      end
    end
  end

  desc "update_counter_cache", "Update company counter cache"
  def update_counter_cache
    Company.all.each_with_index do |company, index|
      company.set(:auctions_count, company.auctions.count)
      company.set(:bids_count, company.bids.count)
      bid_ids = company.bids.map(&:id)
      won_bids_count = bid_ids.blank? ? 0 : Opportunity.in(winning_bid_id: bid_ids).count

      won_bids_amount = 0
      Opportunity.in(winning_bid_id: bid_ids).each do |opportunity|
        won_bids_amount+= opportunity.winning_bid.amount
      end
      company.set(:total_won_bids_count, won_bids_count)
      company.set(:total_winnings, won_bids_amount)
      company.set(:auctions_expired_count, company.auctions.where(:bidding_ends_at.lte => Time.now, winning_bid_id: nil).count)
      puts "##{index} updated #{company.name}"
    end
  end

end
