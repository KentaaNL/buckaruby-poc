module ApplicationHelper
  def show_payment_method(payment_method)
    case payment_method
    when Buckaruby::PaymentMethod::IDEAL
      image_tag('payments/ideal.png') + ' iDEAL'
    when Buckaruby::PaymentMethod::IDEAL_PROCESSING
      image_tag('payments/ideal.png') + ' iDEAL (processing)'
    when Buckaruby::PaymentMethod::VISA
      image_tag('payments/visa.png') + ' Visa'
    when Buckaruby::PaymentMethod::MASTER_CARD
      image_tag('payments/mastercard.png') + ' MasterCard'
    when Buckaruby::PaymentMethod::MAESTRO
      image_tag('payments/maestro.png') + ' Maestro'
    when Buckaruby::PaymentMethod::SEPA_DIRECT_DEBIT
      image_tag('payments/directdebit.png') + ' SEPA direct debit'
    when Buckaruby::PaymentMethod::PAYPAL
      image_tag('payments/paypal.png') + ' PayPal'
    when Buckaruby::PaymentMethod::BANCONTACT_MISTER_CASH
      image_tag('payments/bancontact.png') + ' Bancontact / Mister Cash'
    end
  end

  def show_payment_status(payment_status)
    case payment_status
    when Buckaruby::TransactionStatus::SUCCESS
      "Success"
    when Buckaruby::TransactionStatus::FAILED
      "Failed"
    when Buckaruby::TransactionStatus::REJECTED
      "Rejected"
    when Buckaruby::TransactionStatus::CANCELLED
      "Cancelled"
    when Buckaruby::TransactionStatus::PENDING
      "Pending"
    else
      "Unknown"
    end
  end

  def payment_issuers_as_options
    payment_issuers.invert.sort { |a, b| a.first.downcase <=> b.first.downcase }
  end
end
