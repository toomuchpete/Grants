class ConnectDonationsToPayment < ActiveRecord::Migration
  def change
    add_reference :donations, :payment, index: true
  end
end
