class DonationsController < ApplicationController
  before_action :set_donation, only: [:show, :edit, :update, :destroy]

  def index
    @donations = Donation.all
  end

  def show
  end

  def new
    @donation = Donation.new
  end

  def edit
  end

  def create
    # Make sure the amount is sane
    begin
      donation_amount = Float(donation_params[:amount])
      raise "Can't donate negative money, obviously." unless donation_amount > 0
    rescue
      return redirect_to new_donation_path, alert: "'#{donation_params[:amount]}' isn't a valid donation amount"
    end

    @donation  = Donation.new(donation_params)
    @donation.amount = donation_amount

    cc_result = Braintree::Transaction.sale(
      amount:      donation_amount,
      credit_card: {
        number: donation_cc_params[:number],
        cvv:    donation_cc_params[:cvv],
        expiration_month: donation_cc_params[:month],
        expiration_year:  donation_cc_params[:year]
      },
      options: {
        submit_for_settlement: true
      }
    )

    return redirect_to new_donation_path, alert: cc_result.message unless cc_result.success?

    #figure out who this is
    if current_user
        @donation.user = current_user
    else
      email = donation_cc_params[:email] || 'anon@afdc.com'
      user  = User.find_by_email(email.downcase)
      unless user
        user = User.new({email: email.downcase, crypted_password: '', salt: ''})
        user.save(validate: false) # Otherwise password checks will fail
      end
    end
    @donation.user = user

    @donation  = Donation.new(donation_params)


    if @donation.save
      redirect_to root_path, notice: 'Donation was successfully created.'
    else
      render :new
    end
  end

  def update
    if @donation.update(donation_params)
      redirect_to @donation, notice: 'Donation was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @donation.destroy
    redirect_to donations_url, notice: 'Donation was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_donation
      @donation = Donation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def donation_params
      params.require(:donation).permit(:amount, :user_id, :comments)
    end

    def donation_cc_params
      params.permit(:number, :cvv, :month, :year, :email)
    end
end
