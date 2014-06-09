class CartItemsController < ApplicationController
  def index
    @items = []
    @total_cost = 0

    session[:shopping_cart] ||= []

    session[:shopping_cart].each do |item|
      line_item = {
        id: item[:item_id],
        product: Product.find(item[:product_id]),
        quantity: item[:quantity]
      }

      @items << line_item
      @total_cost += line_item[:quantity] * line_item[:product].price
    end
  end

  def destroy
    if session[:shopping_cart].is_a? Array
      session[:shopping_cart] = session[:shopping_cart].reject {|i| i[:item_id] == params[:id]}
    end

    redirect_to cart_items_path
  end

  def empty
    session[:shopping_cart] = []
    redirect_to products_path, notice: "Your cart is now empty."
  end

  def create
    error_path = session[:last_product] || products_path

    begin
      quantity = Integer(params[:quantity])
      raise "Can't buy negative things." unless quantity > 0
    rescue
      return redirect_to error_path, alert: "'#{params[:quantity]}' isn't a valid quantity"
    end

    begin
      product = Product.find(params[:product_id])
      #TODO: Check if product is active
    rescue
      return redirect_to error_path, alert: "Product not found."
    end

    item = add_to_cart(product.id, quantity)
    redirect_to cart_items_path, notice: "#{product.name} added!" and return
  end

  def checkout
    # To whom are we selling?
    unless current_user.present? || params[:email].present?
      return redirect_to cart_items_path, alert: "You must provide your email address for purchases."
    end

    if current_user
      purchasing_user = current_user
    else
      purchasing_user = User.find_or_create_by_email params[:email]
    end

    # Sanity check the submitted items against the shopping cart to ensure there was no fuckery
    submitted_items = params[:items]
    return redirect_to cart_items_path, alert: "No producs were submitted for purchase." unless submitted_items.is_a? Hash

    cart_items = session[:shopping_cart].dup
    unless cart_items.is_a?(Array) && cart_items.count > 0
      return redirect_to cart_items_path, alert: "Your cart is empty."
    end

    unless cart_items.count == submitted_items.count
      return redirect_to cart_items_path, alert: "Your shopping cart changed while you were checking out. Please try again."
    end

    purchased_products = []
    purchase_amount = 0
    cart_items.each do |ci|
      this_submitted_item = submitted_items[ci[:item_id]]
      unless this_submitted_item && (ci[:quantity].to_i == this_submitted_item[:quantity].to_i) && (ci[:product_id].to_i == this_submitted_item[:product_id].to_i)
        return redirect_to cart_items_path, alert: "Your shopping cart changed while you were checking out. Please try again."
      end

      this_product = Product.find(ci[:product_id])
      return redirect_to cart_items_path, alert: "Your cart includes items that are no longer available for sale. (#{this_product.name})" unless this_product.purchaseable?

      # Record this stuff for use later, while we have it all loaded
      purchase_amount += this_product.price * this_submitted_item[:quantity].to_i
      purchased_products << {
        quantity: this_submitted_item[:quantity].to_i,
        product_id: this_product.id,
        unit_price: this_product.price
      }
    end

    donation_amount = params[:donation_amount].to_f
    total_amount = purchase_amount + donation_amount

    return redirect_to cart_items_path, alert: "The total price of one or more of your items changed while you were checking out. Please try again. (#{total_amount} != #{params[:total_amount].to_f})" unless total_amount == params[:total_amount].to_f

    ### Do the credit card processing
    cc_result = Braintree::Transaction.sale(
      amount:      total_amount,
      credit_card: {
        number:           params[:number],
        cvv:              params[:cvv],
        expiration_month: params[:month],
        expiration_year:  params[:year],
        cardholder_name:  params[:name]
      },
      options: {
        submit_for_settlement: true
      }
    )

    return redirect_to cart_items_path, alert: cc_result.message unless cc_result.success?

    begin
      payment = Payment.create!(
        amount: total_amount,
        web_request: {
          remote_ip:  request.remote_ip,
          user_agent: request.user_agent
        },
        merchant_details: {
          processor:      'braintree',
          transaction_id: cc_result.transaction.id,
          status:         cc_result.transaction.status,
          type:           cc_result.transaction.type,
          cardholder:     cc_result.transaction.credit_card_details.cardholder_name
        }
      )
    rescue => e
      return redirect_to donate_path, alert: "Transaction succeeded, but saving the local payment detials failed: #{e.message}"
    end

    ### Record the purchase
    purchase = Purchase.new do |p|
      p.price            = purchase_amount
      p.user             = purchasing_user
      p.shipping_address = params[:shipping_address]
      p.comments         = params[:other_comments]
    end

    unless purchase.save
      return redirect_to donate_path, alert: "Transaction succeeded, but saving the local purchase detials failed."
    end

    ### Add line-items to the purchase
    purchased_products.each do |pp|
      pli = PurchaseLineItem.new(pp)
      pli.purchase = purchase
      pli.save
    end

    ### Record the donation
    if donation_amount > 0
      donation          = Donation.new
      donation.user     = purchasing_user
      donation.amount   = donation_amount
      donation.payment  = payment
      donation.comments = params[:other_comments]
      donation.save
    end

    session[:shopping_cart] = []
    redirect_to root_path, notice: "Your purchase was successful! That you for supporting AFDC Grants!"
  end

  private

  def add_to_cart(product_id, quantity)
    session[:shopping_cart] = [] unless session[:shopping_cart].is_a? Array

    session[:shopping_cart].each do |item|
      next unless item[:product_id] == product_id
      item[:quantity] += quantity
      return item[:item_id]
    end

    new_id = SecureRandom.uuid

    session[:shopping_cart] << {
      item_id: new_id,
      product_id: product_id,
      quantity: quantity
    }

    return new_id
  end
end
