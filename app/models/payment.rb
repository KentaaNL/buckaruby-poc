class Payment < ActiveRecord::Base
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, presence: true, on: :create
  validates :payment_issuer, presence: true, if: -> { self.payment_method == Buckaruby::PaymentMethod::IDEAL && !self.recurrent? }, on: :create
  validates :payment_account_name, presence: true, if: -> { self.payment_method == Buckaruby::PaymentMethod::SEPA_DIRECT_DEBIT && !self.recurrent? }, on: :create
  validates :payment_account_iban, presence: true, iban: true, if: -> { self.payment_method == Buckaruby::PaymentMethod::SEPA_DIRECT_DEBIT && !self.recurrent? }, on: :create

  def process(response)
    self.status = response.transaction_status
    self.payment_id = response.payment_id

    case response.transaction_status
    when Buckaruby::TransactionStatus::SUCCESS
      self.paid_at = Time.now
    when Buckaruby::TransactionStatus::FAILED, Buckaruby::TransactionStatus::REJECTED
      self.failed_at = Time.now
    when Buckaruby::TransactionStatus::CANCELLED
      self.cancelled_at = Time.now
    end

    save!
  end

  def refund(response)
    if response.transaction_status == Buckaruby::TransactionStatus::SUCCESS
      self.charged_back_at = Time.now
    end

    save!
  end

  def to_transaction(options = {})
    transaction_options = options.merge(
      payment_method: self.payment_method,
      invoicenumber: self.id
    )

    unless self.recurrent?
      case self.payment_method
      when Buckaruby::PaymentMethod::IDEAL
        transaction_options[:payment_issuer] = self.payment_issuer
      when Buckaruby::PaymentMethod::SEPA_DIRECT_DEBIT
        transaction_options.merge!(
          account_name: self.payment_account_name,
          account_iban: self.payment_account_iban,
          mandate_reference: "#{BUCKAROO[:mandate_prefix]}#{self.id}"
        )
      end
    end

    return transaction_options
  end

  def to_recurrent
    payment = self.dup
    payment.recurrent = true # indicate that this is a recurrent transaction
    payment.recurring = false # this transaction cannot be recurring again

    # Change iDEAL payment to SEPA direct debit
    if self.payment_method == Buckaruby::PaymentMethod::IDEAL
      payment.payment_method = Buckaruby::PaymentMethod::SEPA_DIRECT_DEBIT
    end

    return payment
  end

  # Recurring is supported if the transaction itself is not recurrent
  # and on whitelisted payment methods.
  def recurring_supported?
    return !self.recurrent? && [Buckaruby::PaymentMethod::IDEAL, Buckaruby::PaymentMethod::VISA, Buckaruby::PaymentMethod::MASTER_CARD, Buckaruby::PaymentMethod::MAESTRO, Buckaruby::PaymentMethod::SEPA_DIRECT_DEBIT, Buckaruby::PaymentMethod::PAYPAL].include?(self.payment_method)
  end

  def paid?
    return self.paid_at.present? && self.charged_back_at.nil?
  end
end
