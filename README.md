# Модуль оплаты для сервиса Onpay.ru

## Требования
Ruby > 1.9.3 

## Как пользоваться
```ruby
def onpay
  @ctrl = Onpay::PayController.new
  check_lambda = ->(pay_for_id){o=Order.find(pay_for_id);return !o.payed?}
  pay_lambda = ->(pay_for_id){o=Order.find(pay_for_id);o.mark_as_payed;return true}
  render :xml => @ctrl.process(params, "secret", check_payment: check_lambda, onpay: pay_lambda)

end
```