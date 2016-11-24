class PaymentsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:buckaroo_return, :buckaroo_callback]

  helper_method :payment_issuers

  # GET /payments
  def index
    @payments = Payment.order(created_at: :desc)
    @payment_methods = [Buckaruby::PaymentMethod::IDEAL, Buckaruby::PaymentMethod::VISA, Buckaruby::PaymentMethod::MASTER_CARD, Buckaruby::PaymentMethod::MAESTRO, Buckaruby::PaymentMethod::SEPA_DIRECT_DEBIT, Buckaruby::PaymentMethod::PAYPAL, Buckaruby::PaymentMethod::BANCONTACT_MISTER_CASH]
  end

  # GET /payments/1
  def show
    @payment = Payment.find(params[:id])
  end

  # GET /payments/new
  def new
    @payment = Payment.new
    @payment.payment_method = params[:payment_method]
    @payment.mode = Buckaruby::Gateway.mode
  end

  # POST /payments
  def create
    @payment = Payment.new(payment_params)
    @payment.mode = Buckaruby::Gateway.mode

    if @payment.save
      transaction_options = @payment.to_transaction(
        amount: @payment.amount,
        description: @payment.description,
        recurring: @payment.recurring,
        return_url: buckaroo_return_payments_url,
        client_ip: request.remote_ip
      )
      response = buckaroo_gateway.setup_transaction(transaction_options)

      @payment.started_at = Time.now
      @payment.transaction_id = response.transaction_id
      @payment.status = response.transaction_status

      if @payment.save
        redirect_url = response.redirect_url || payment_url(@payment)

        redirect_to redirect_url, notice: "Payment was successfully created."
      else
        render action: "new"
      end
    else
      render action: "new"
    end
  rescue Buckaruby::BuckarooException => ex
    flash[:error] = "Buckaroo exception: #{ex.message}"
    render action: "new"
  end

  # DELETE /payments/1
  def destroy
    payment = Payment.find(params[:id])
    payment.destroy

    redirect_to payments_url, notice: "Payment was successfully deleted."
  end

  # POST /payments/1/status
  def status
    payment = Payment.find(params[:id])

    response = buckaroo_gateway.status(transaction_id: payment.transaction_id)

    case response.transaction_type
    when Buckaruby::TransactionType::PAYMENT, Buckaruby::TransactionType::PAYMENT_RECURRENT
      payment.process(response)
    when Buckaruby::TransactionType::REFUND, Buckaruby::TransactionType::REVERSAL
      payment.refund(response)
    end

    redirect_to payment, notice: "Payment status was successfully updated."
  rescue Buckaruby::BuckarooException => ex
    flash[:error] = "Buckaroo exception: #{ex.message}"
    redirect_to payment
  rescue ArgumentError => ex
    flash[:error] = "Argument error: #{ex.message}"
    redirect_to payment
  end

  # GET /payments/1/recur
  def recur
    @original_payment = Payment.find(params[:id])
    @payment = @original_payment.to_recurrent
  end

  # POST /payments/1/recurrent
  def recurrent
    @original_payment = Payment.find(params[:id])
    @payment = @original_payment.to_recurrent
    @payment.assign_attributes(payment_params)

    if @payment.save
      transaction_options = @payment.to_transaction(
        amount: @payment.amount,
        description: @payment.description,
        transaction_id: @original_payment.transaction_id
      )
      response = buckaroo_gateway.recurrent_transaction(transaction_options)

      @payment.started_at = Time.now
      @payment.transaction_id = response.transaction_id
      @payment.status = response.transaction_status

      if @payment.save
        redirect_to payment_url(@payment), notice: "Recurrent payment was successfully created."
      else
        render action: "recur"
      end
    else
      render action: "recur"
    end
  rescue Buckaruby::BuckarooException => ex
    flash[:error] = "Buckaroo exception: #{ex.message}"
    render action: "recur"
  end

  # POST /payments/buckaroo_return
  def buckaroo_return
    response = buckaroo_gateway.callback(params)

    if response.invoicenumber.present?
      payment = Payment.find(response.invoicenumber)

      # Payment status will be updated in async push response (see below)

      redirect_to payment
    else
      head :not_found
    end
  end

  # POST /payments/buckaroo_callback
  def buckaroo_callback
    response = buckaroo_gateway.callback(params)

    if response.invoicenumber.present?
      payment = Payment.find(response.invoicenumber)

      case response.transaction_type
      when Buckaruby::TransactionType::PAYMENT, Buckaruby::TransactionType::PAYMENT_RECURRENT
        payment.process(response)
      when Buckaruby::TransactionType::REFUND, Buckaruby::TransactionType::REVERSAL
        payment.refund(response)
      end

      redirect_to payment
    else
      # Response without invoicenumber, for example transaction costs response
      head :ok
    end
  end

  # GET /payments/buckaroo_mode
  def buckaroo_mode
    mode = params[:mode].to_sym

    if [:test, :production].include?(mode)
      Buckaruby::Gateway.mode = mode
    end

    redirect_to request.referer || root_path
  end

  private

  def payment_params
    params.require(:payment).permit(:amount, :description, :payment_method, :payment_issuer, :payment_account_name, :payment_account_iban, :recurring)
  end

  def buckaroo_gateway
    @buckaroo_gateway ||= Buckaruby::Gateway.new(
      website: BUCKAROO[:website],
      secret: BUCKAROO[:secret],
      hash_method: BUCKAROO[:hash_method]
    )
  end

  def payment_issuers
    @payment_issuers ||= buckaroo_gateway.issuers(Buckaruby::PaymentMethod::IDEAL)
  end
end
